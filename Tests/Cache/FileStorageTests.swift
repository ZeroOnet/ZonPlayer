//
//  FileStorageTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

final class FileStorageTests: QuickSpec {
    override func spec() {
        describe("Test file storage") {
            it("Invalid cache directory") {
                let config = ZPC.Config(
                    cacheDirectory: URL(string: "https://abc").unsafelyUnwrapped,
                    fileName: ZPC.FileNameMD5BaseOnURL(),
                    ioQueue: .init(label: "")
                )
                let storage = ZPC.DefaultFileStorage(config: config)
                let fileURLResult = storage.fileURL(url: URL(string: "xxx").unsafelyUnwrapped)
                let readResult = storage.read(with: URL(string: "abc").unsafelyUnwrapped)

                waitUntil(timeout: .seconds(5)) { done in
                    storage.create(
                        file: File(location: URL(string: "https://ccc").unsafelyUnwrapped),
                        with: URL(string: "hhh").unsafelyUnwrapped
                    ) { result in
                        guard 
                            case .failure(.cacheFailed(.createCacheDirectoryFailed)) = fileURLResult,
                            case .failure(.cacheFailed(.createCacheDirectoryFailed)) = readResult,
                            case .failure(.cacheFailed(.createCacheDirectoryFailed)) = result
                        else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }
                        done()
                    }
                }
            }

            it("File not found") {
                let storage = ZPC.DefaultFileStorage()
                let result = storage.read(with: URL(string: "FileNotFound\(Int.random(in: 100..<1000))").unsafelyUnwrapped)
                guard case .success(nil) = result else {
                    self.__zon_triggerUnexpectedError()
                    return
                }
            }

            it("Fie cannot store") {
                let file = File(location: URL(string: "https://aaa").unsafelyUnwrapped)
                let storage = ZPC.DefaultFileStorage()
                waitUntil(timeout: .seconds(5)) { done in
                    storage.create(file: file, with: URL(string: "abcded").unsafelyUnwrapped) { result in
                        guard case .failure(.cacheFailed(.fileStoreFailed)) = result else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }
                        done()
                    }
                }
            }

            it("Store, read and delete file") {
                let storage = ZPC.DefaultFileStorage()
                let fileURL = storage.config.cacheDirectory.appendingPathComponent("storeAndReadFile.text", isDirectory: false)
                FileManager.default.createFile(atPath: fileURL.path, contents: "ABCD".data(using: .utf8))
                let file = File(location: fileURL)
                let url = URL(string: "haha").unsafelyUnwrapped
                waitUntil(timeout: .seconds(5)) { done in
                    storage.create(file: file, with: url) { storeResult in
                        guard case .success = storeResult else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }

                        guard 
                            case .success(let storedFile) = storage.read(with: url),
                            let storedFile = storedFile
                        else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }

                        expect { FileManager.default.fileExists(atPath: storedFile.location.path) }.to(beTrue())

                        storage.delete(with: url) {
                            expect { FileManager.default.fileExists(atPath: storedFile.location.path) }.to(beFalse())
                            done()
                        }
                    }
                }
            }
        }
    }
}
