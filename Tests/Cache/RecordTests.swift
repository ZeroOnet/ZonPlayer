//
//  RecordTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/21.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

@testable import ZonPlayer

final class RecordTests: QuickSpec {
    override static func spec() {
        describe("Test cache record") {
            it("Independent fragments") {
                let rangeOne = NSRange(location: 0, length: 10)
                let rangeTwo = NSRange(location: 12, length: 15)
                let rangeThree = NSRange(location: 30, length: 5)
                let record = self._record(fragments: [rangeOne, rangeTwo, rangeThree])

                expect { record.fragments.count } == 3
                expect { record.fragments[0] } == rangeOne
                expect { record.fragments[1] } == rangeTwo
                expect { record.fragments[2] } == rangeThree
            }

            it("Equatable fragments") {
                let rangeOne = NSRange(location: 0, length: 100)
                let rangeTwo = rangeOne
                let rangeThree = rangeOne

                let record = self._record(fragments: [rangeOne, rangeTwo, rangeThree])

                expect { record.fragments.count } == 1
                expect { record.fragments[0] } == rangeOne
            }

            it("Extended fragments") {
                let rangeOne = NSRange(location: 0, length: 100)
                let rangeTwo = NSRange(location: 100, length: 100)
                let rangeThree = NSRange(location: 200, length: 100)
                let record = self._record(fragments: [rangeOne, rangeTwo, rangeThree])

                expect { record.fragments.count } == 1
                expect { record.fragments[0].location } == 0
                expect { record.fragments[0].length } == 300
            }

            it("Intersectant fragments") {
                let rangeOne = NSRange(location: 0, length: 100)
                let rangeTwo = NSRange(location: 150, length: 100)
                let rangeThree = NSRange(location: 50, length: 150)
                let record = self._record(fragments: [rangeOne, rangeTwo, rangeThree])

                expect { record.fragments.count } == 1
                expect { record.fragments[0].location } == 0
                expect { record.fragments[0].length } == 250
            }
        }
    }

    private static func _record(fragments: [NSRange]) -> Record {
        var result = Record()
        fragments.forEach { result.addFragment($0) }
        return result
    }
}
