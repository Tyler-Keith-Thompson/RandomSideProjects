//
//  File.swift
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
import AnyCodable

struct AssertionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let attestation = routes.grouped("verifyAssertion")
        attestation.post(use: verify)
    }

    func verify(req: Request) async throws -> Response {
        let request = try req.content.decode(VerifyAssertionRequest.self)

        // 1. Compute clientDataHash as the SHA256 hash of clientData.
        let clientDataHash = SHA256.hash(data: request.clientData)

        // 2. Concatenate authenticatorData and clientDataHash, and apply a SHA256 hash over the result to form nonce.
        let nonce = SHA256.hash(data: request.assertion.authenticatorData.bytes + clientDataHash)

        // 3. Use the public key that you store from the attestation object to verify that the assertion’s signature is valid for nonce.
        // TODO: Make this pull the key, rather than assuming this one
        let credCert = try P256.Signing.PublicKey(x963Representation: Data([4, 208, 225, 184, 122, 129, 50, 205, 212, 27, 150, 186, 157, 41, 202, 14, 42, 228, 11, 150, 238, 89, 232, 118, 165, 204, 98, 167, 170, 62, 110, 80, 218, 134, 103, 192, 219, 40, 125, 52, 210, 203, 236, 56, 213, 57, 185, 218, 236, 14, 172, 108, 84, 220, 32, 181, 178, 5, 70, 58, 39, 72, 64, 34, 118]))
        
        guard credCert.isValidSignature(try .init(derRepresentation: request.assertion.signature), for: Data(nonce)) else {
            throw Abort(.badRequest, reason: "Invalid signature.")
        }

        // 4. Compute the SHA256 hash of the client’s App ID, and verify that it matches the RP ID in the authenticator data.
        // TODO: Pull this from configuration
        let appID = "9CUJHB48U6.TT.Playground"
        guard request.assertion.authenticatorData.rpID == Data(SHA256.hash(data: Data(appID.utf8))) else {
            throw Abort(.badRequest, reason: "AppID does not match.")
        }

        // 5. Verify that the authenticator data’s counter value is greater than the value from the previous assertion, or greater than 0 on the first assertion.
        // TODO: Pull this from somewhere (should not always be > 0)
        guard request.assertion.authenticatorData.counter > 0 else {
            req.logger.critical("Attempted replay attack")
            throw Abort(.badRequest, reason: "Invalid assertion.")
        }

        // 6. Verify that the embedded challenge in the client data matches the earlier challenge to the client.
        if let embeddedChallenge = request.embeddedChallenge {
            guard embeddedChallenge == request.challenge else {
                throw Abort(.badRequest, reason: "Signed request contains a different challenge")
            }
        } else if let dictionary = try? JSONDecoder().decode(AnyCodable.self, from: request.clientData).value as? [String: AnyCodable] {
            req.logger.debug("Assuming JSON used in clientData")
            guard dictionary["challenge"] == AnyCodable(request.challenge) else {
                throw Abort(.badRequest, reason: "Signed request contains a different challenge")
            }
        }
        
        return .init(status: .ok)
    }
}

extension AssertionController {
    private struct VerifyAssertionRequest: Decodable {
        let challenge: String
        let embeddedChallenge: String?
        let clientId: String
        @DecodeData<AnyStrategy> var clientData: Data
        @DecodeData<AnyBase64Strategy> var keyId: Data
        @DecodeCBOR var assertion: Assertion
    }
}
