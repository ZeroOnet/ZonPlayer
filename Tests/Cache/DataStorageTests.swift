//
//  DataStorageTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

final class DataStorageTests: QuickSpec {
    override static func spec() {
        describe("Test data storage") {
            it("Set and get meta data") {
                let url = URL(string: "https://test/metadata").unsafelyUnwrapped
                let config = ZPC.Config.config(components: "MetaData")
                let storage = ZPC.Streaming.DefaultDataStorage(url: url, config: config)
                let metaData = ZPC.Streaming.MetaData(contentType: "abcd", isByteRangeAccessSupported: false, contentLength: 10239)
                waitUntil(timeout: .seconds(5)) { done in
                    storage.setMetaData(metaData)
                    storage.getMetaData {
                        guard let stored = $0 else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }
                        expect { metaData.contentType == stored.contentType }.to(beTrue())
                        expect { metaData.isByteRangeAccessSupported == stored.isByteRangeAccessSupported }.to(beTrue())
                        expect { metaData.contentLength == stored.contentLength }.to(beTrue())
                        done()
                    }
                }
            }

            it("Set, get and delete data") {
                let url = URL(string: "https://test/data").unsafelyUnwrapped
                let config = ZPC.Config.config(components: "Data")
                let storage = ZPC.Streaming.DefaultDataStorage(url: url, config: config)
                waitUntil(timeout: .seconds(5)) { done in
                    let data = "ABCDEFG".data(using: .utf8).unsafelyUnwrapped
                    let range = NSRange(location: 0, length: data.count)
                    storage.writeData(data, to: range)
                    storage.readData(from: range) { result in
                        expect { result == data }.to(beTrue())
                        storage.readData(from: NSRange(location: data.count + 10, length: 10)) { result in
                            expect { result }.to(beNil())

                            storage.getCacheFragments { result in
                                expect { result.count } == 1
                                expect { result.first } == range

                                storage.clean {
                                    storage.readData(from: range) { result in
                                        expect { result }.to(beNil())

                                        storage.getCacheFragments() { result in
                                            expect { result }.to(beEmpty())
                                            done()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
