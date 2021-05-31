import XCTest
@testable import SeededRandomNumberGenerator

final class SeededRandomNumberGeneratorTests: XCTestCase {
    func testRandomNumberGenerate_CreatesDeterministicNumbers() {
        var rng = SeededRandomNumberGenerator(seed: 462346254)
        XCTAssertEqual(rng.next(), UInt(7096265112125931742))
        rng = SeededRandomNumberGenerator(seed: 245624567)
        XCTAssertEqual(rng.next(), UInt(7096265111844219373))
        rng = SeededRandomNumberGenerator(seed: 12346)
        XCTAssertEqual(rng.next(), UInt(7096265347738037474))
        rng = SeededRandomNumberGenerator(seed: 0xE24582F)
        XCTAssertEqual(rng.next(), UInt(7096265111789313141))
    }

    func testRandomNumberGenerate_CreatesDeterministicNumbersInRange() {
        var rng = SeededRandomNumberGenerator(seed: 462346254)
        XCTAssertEqual(Int.random(in: 0...100, using: &rng), 38)
        rng = SeededRandomNumberGenerator(seed: 245624567)
        XCTAssertEqual(Int.random(in: 10...100, using: &rng), 45)
        rng = SeededRandomNumberGenerator(seed: 12346)
        XCTAssertEqual(Int.random(in: 30...100, using: &rng), 57)
        rng = SeededRandomNumberGenerator(seed: UInt(0xE24582F))
        XCTAssertEqual(Int.random(in: 19...100, using: &rng), 50)
    }

    func testRandomNumberGenerate_CreatesDeterministicNumberSequences() {
        var rng = SeededRandomNumberGenerator(seed: 462346254)
        XCTAssertEqual(rng.next(), UInt(7096265112125931742))
        XCTAssertEqual(rng.next(), UInt(3954920033006131575))
        XCTAssertEqual(rng.next(), UInt(16503000542491301408))
        XCTAssertEqual(rng.next(), UInt(12521116052407340739))
        XCTAssertEqual(rng.next(), UInt(12487039217301550193))
        XCTAssertEqual(rng.next(), UInt(2747312251570405791))
        XCTAssertEqual(rng.next(), UInt(10948732315967410426))
        XCTAssertEqual(rng.next(), UInt(3920822795917564192))
        XCTAssertEqual(rng.next(), UInt(1297443907077494766))
        XCTAssertEqual(rng.next(), UInt(732884121664043166))
    }

    func testRandomNumberGenerator_WorksWithWeightedOperator() {
        [
            (seed: 1926285723294859049, chance: 0.01),
            (seed: 1927639947335366338, chance: 0.1),
            (seed: 1768472991134143395, chance: 1),
            (seed: 590158482798927793, chance: 5),
            (seed: 430907905381807577, chance: 10),
            (seed: 8438057959384845527, chance: 20),
            (seed: 6028931981654870860, chance: 35),
            (seed: 6906253829635987571, chance: 40),
            (seed: 2377660419244249362, chance: 50),
            (seed: 8364079668445225564, chance: 60),
            (seed: 4544417410174492382, chance: 70),
            (seed: 214044866555974563, chance: 75),
            (seed: 3189668918595760339, chance: 80),
            (seed: 6620096176893334357, chance: 90),
            (seed: 3997663425777832267, chance: 99),
            (seed: 1807148161377964214, chance: 99.99),
            (seed: 4457617203788150289, chance: 99.9999)
        ].forEach {
            RNG = SeededRandomNumberGenerator(seed: UInt($0.seed))
            XCTAssert($0.chance%%)
            XCTAssertFalse(log($0.chance)%%, "Original Chance: \($0.chance), modified chance: \(log($0.chance)) chance to succeed with seed: \($0.seed) should have failed")
        }
    }
}

// Just a quick way of finding a seed, use like: `findSeedFor(20%%)`
@discardableResult func findSeedFor(_ closure: @autoclosure () -> Bool) -> UInt {
    var seed: UInt
    repeat {
        seed = UInt(abs(UUID().hashValue))
        RNG = SeededRandomNumberGenerator(seed: seed)
    } while !closure()
    XCTFail("Found seed: \(seed)")
    return seed
}

@discardableResult func findSeedFor(_ closure: () -> Bool) -> UInt {
    var seed: UInt
    repeat {
        seed = UInt(abs(UUID().hashValue))
        RNG = SeededRandomNumberGenerator(seed: seed)
    } while !closure()
    XCTFail("Found seed: \(seed)")
    return seed
}

@discardableResult func findSeedFor<T>(_ object: @autoclosure () -> T, _ closure: (T) -> Bool) -> UInt {
    var seed: UInt
    repeat {
        seed = UInt(abs(UUID().hashValue))
        RNG = SeededRandomNumberGenerator(seed: seed)
    } while !closure(object())
    XCTFail("Found seed: \(seed)")
    return seed
}
