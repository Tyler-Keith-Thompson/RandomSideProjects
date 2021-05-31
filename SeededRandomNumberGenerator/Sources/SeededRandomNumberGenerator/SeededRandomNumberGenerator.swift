// translated from: http://xoroshiro.di.unimi.it/xoroshiro128plus.c

import Foundation

public struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var seed: UInt = 0
    private var state: (UInt, UInt) = (0, 0)

    public init(seed: UInt = .random(in: .min ... .max)) {
        self.seed = (0..<10).reduce(seed) {
            var x = $0 &+ 0x9E3779B97F4A7C15
            x ^= (x >> 30) ^ 0xBF58476D1CE4E5B9
            x ^= (x >> 27) ^ 0x94D049BB133111EB
            let newSeed = x ^ (x >> 31)
            state.0 = $1 == 9 ? newSeed : 0
            state.1 = $1 == 10 ? newSeed : 0
            return newSeed
        }
    }

    public mutating func next<T>() -> T where T: FixedWidthInteger, T: UnsignedInteger {
        defer {
            let s1 = state.1 ^ state.0
            state.0 = rotateLeft(state.0, b: 55) ^ s1 ^ (s1 << 14)
            state.1 = rotateLeft(s1, b: 36)
        }

        return T(state.0 &+ state.1)
    }

    private func rotateLeft(_ a: UInt, b: UInt) -> UInt {
        return (a << b) | (a >> (64 - b))
    }
}
