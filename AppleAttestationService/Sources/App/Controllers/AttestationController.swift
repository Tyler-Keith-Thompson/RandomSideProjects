//
//  AttestationController.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation
import X509
import Crypto
import _CryptoExtras
import SwiftASN1
import SwiftCBOR
import Vapor

struct AttestationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let attestation = routes.grouped("verifyAttestation")
        attestation.post(use: verify)
    }

    func verify(req: Request) async throws -> Response {
        // TODO: Expect request to have bundleID/clientID
        // Check that against configuration
        // TODO: Check whether challenge was issued by this server
        // Additionally, make sure it hasn't been used, since they're all usable once only

        let request = try req.content.decode(VerifyAttestationRequest.self)

        // 1. Verify that the x5c array contains the intermediate and leaf certificates for App Attest, starting from the credential certificate in the first data buffer in the array (credcert). Verify the validity of the certificates using Apple’s App Attest root certificate.
        let now = Date()
        var verifier = Verifier(rootCertificates: CertificateStore([try .appAttestRootCertificate])) {
            RFC5280Policy(validationTime: now)
            // TODO: Use OCSP to make sure nothing got revoked
//            OCSPVerifierPolicy(failureMode: .hard, requester: requester, validationTime: now)
        }
        guard let credCert = request.attestation.statement.certificates.first,
              case .validCertificate(let certificates) = await verifier.validate(leafCertificate: credCert, intermediates: CertificateStore(request.attestation.statement.certificates.dropFirst())),
              Set(certificates) == Set(request.attestation.statement.certificates + [try .appAttestRootCertificate]) else {
            throw Abort(.badRequest, reason: "Certificates did not pass RFC5280 verification.")
        }

        // 2. Create clientDataHash as the SHA256 hash of the one-time challenge your server sends to your app before performing the attestation, and append that hash to the end of the authenticator data (authData from the decoded object).
        let clientDataHash = SHA256.hash(data: Data(request.challenge.utf8))

        // 3. Generate a new SHA256 hash of the composite item to create nonce.
        let nonce = SHA256.hash(data: request.attestation.authenticatorData.bytes + clientDataHash)

        // 4. Obtain the value of the credCert extension with OID 1.2.840.113635.100.8.2, which is a DER-encoded ASN.1 sequence. Decode the sequence and extract the single octet string that it contains. Verify that the string equals nonce.
        guard let ext = credCert.extensions.first(where: { $0.oid == [1, 2, 840, 113635, 100, 8, 2]}),
              Data(try SingleOctetSequence(derEncoded: try DER.parse(ext.value)).octet.bytes) == Data(nonce) else {
            throw Abort(.badRequest, reason: "Nonce did not match.")
        }

        // 5. Create the SHA256 hash of the public key in credCert, and verify that it matches the key identifier from your app.
        let publicKeyHash = Data(SHA256.hash(data: {
            if let p256 = P256.Signing.PublicKey(credCert.publicKey) {
                return p256.x963Representation
            } else if let p384 = P384.Signing.PublicKey(credCert.publicKey) {
                return p384.x963Representation
            } else if let p521 = P521.Signing.PublicKey(credCert.publicKey) {
                return p521.x963Representation
            } else if let rsa = _RSA.Signing.PublicKey(credCert.publicKey) {
                return rsa.pkcs1DERRepresentation
            } else {
                return Data()
            }
        }()))

        // TODO: Submit PR to swift-certificates to expose this
        guard publicKeyHash == request.keyId else {
            throw Abort(.badRequest, reason: "KeyID does not match.")
        }

        // 6. Compute the SHA256 hash of your app’s App ID, and verify that it’s the same as the authenticator data’s RP ID hash.
        // TODO: Pull this from configuration
        let appID = "9CUJHB48U6.TT.Playground"
        guard request.attestation.authenticatorData.rpID == Data(SHA256.hash(data: Data(appID.utf8))) else {
            throw Abort(.badRequest, reason: "AppID does not match.")
        }

        // 7. Verify that the authenticator data’s counter field equals 0.
        guard request.attestation.authenticatorData.counter == 0 else {
            throw Abort(.badRequest, reason: "Key has already been used, did you mean to use an assertion instead of an attestation?")
        }

        // 8. Verify that the authenticator data’s aaguid field is either appattestdevelop if operating in the development environment, or appattest followed by seven 0x00 bytes if operating in the production environment.
        guard request.attestation.authenticatorData.aaguid != nil else {
            throw Abort(.badRequest, reason: "AAGUID was neither prod nor dev identifier")
        }

        // 9. Verify that the authenticator data’s credentialId field is the same as the key identifier.
        guard request.attestation.authenticatorData.credentialID == request.keyId else {
            throw Abort(.badRequest, reason: "CredentialID was not the expected key identifier")
        }

        return .init(status: .ok)
    }
}

extension AttestationController {
    private struct VerifyAttestationRequest: Decodable {
        let challenge: String
        let clientId: String
        @DecodeData<AnyBase64Strategy> var keyId: Data
        @DecodeCBOR var attestation: Attestation
    }
}
