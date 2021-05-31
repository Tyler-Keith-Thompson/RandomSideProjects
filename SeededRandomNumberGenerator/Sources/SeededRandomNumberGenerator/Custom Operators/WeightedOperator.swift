//
//  File.swift
//  
//
//  Created by Tyler Thompson on 5/31/21.
//

import Foundation

postfix operator %%

extension FloatLiteralType {
    static postfix func %% (lhs: FloatLiteralType) -> Bool {
        return Double.random(in: 0...100, using: &RNG) <= lhs
    }
}

// One of the few times I've ever opted for a global variable, normally they're evil, but the thing is we needed a reasonably fast way to swap in a generator from tests and this fit the bill surprisingly nicely.
// This could easily be moved into an enum called RandomNumberGenerators or some such if this offends your sensibilities
// Default to a random number using Double.Random which ultimately uses the system random number generator.
var RNG: SeededRandomNumberGenerator = SeededRandomNumberGenerator(seed: UInt.random(in: 0...(.max)))
