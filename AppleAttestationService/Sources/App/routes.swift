import Vapor
import SwiftCBOR
import X509
import Crypto
import _CryptoExtras
import SwiftASN1

func routes(_ app: Application) throws {
    try app.register(collection: AttestationController())
    try app.register(collection: AssertionController())
}
