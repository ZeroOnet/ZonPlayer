//
//  FileDownloaderTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

final class FileDownloaderTests: QuickSpec {
    override func spec() {
        describe("Test file downloader") {
            it("Download cancelled") {
                waitUntil(timeout: .seconds(1)) { done in
                    let downloader = ZPC.Harvest.DefaultFileDownloader(timeout: 5)
                    downloader.download(
                        with: URL(string: "https://abc.com").unsafelyUnwrapped,
                        destination: self._downloadDir.appendingPathComponent("1.a")
                    ) { result in
                        guard case .failure(.cacheFailed(.downloadExplicitlyCancelled)) = result else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }
                        done()
                    }.cancel()
                    self._downloaders.append(downloader)
                }
            }

            it("Download finished") {
                waitUntil(timeout: .seconds(10)) { done in
                    let downloader = ZPC.Harvest.DefaultFileDownloader(timeout: 20)
                    let destination = self._downloadDir.appendingPathComponent("2.mp3")
                    downloader.download(
                        with: URL(string: "https://media-audio1.baydn.com/creeper/listening/33aede75f51823e9f7242cc65d09bc45.8c3bc6434a2d9c9b61f7fe28b519a841.mp3")!,
                        destination: destination
                    ) { result in
                        guard case .success = result else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }
                        expect { FileManager.default.fileExists(atPath: destination.path) }.to(beTrue())
                        done()
                    }
                    self._downloaders.append(downloader)
                }
            }

            it("Download failed") {
                waitUntil(timeout: .seconds(10)) { done in
                    let downloader = ZPC.Harvest.DefaultFileDownloader(timeout: 10)
                    downloader.download(
                        with: URL(string: "test://xx").unsafelyUnwrapped,
                        destination: self._downloadDir.appendingPathComponent("3.b")
                    ) { result in
                        guard case .failure(.cacheFailed(.downloadFailed)) = result else {
                            self.__zon_triggerUnexpectedError()
                            return
                        }
                        done()
                    }
                    self._downloaders.append(downloader)
                }
            }
        }
    }

    private let _downloadDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var _downloaders: [ZPC.Harvest.FileDownloadable] = []
}
