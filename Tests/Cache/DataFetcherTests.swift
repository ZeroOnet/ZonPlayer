//
//  DataFetcherTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/21.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

@testable import ZonPlayer

final class DataFetcherTests: QuickSpec {
    override func spec() {
        describe("Test data fetcher") {
            it("Fullfill meta data") {
                let url = URL(string: "abcd").unsafelyUnwrapped
                let storage = _Storage(url: url)
                let metaData = ZPC.MetaData(contentType: "ABC", isByteRangeAccessSupported: true, contentLength: 10101393)
                storage.setMetaData(metaData)
                let request = LoadingRequest()
                let fetcher = DataFetcher(storage: storage, requester: _Requester(url: url, plugins: []), loadingRequest: request)
                fetcher.fetch()
                expect { request.theMetaDataRequest?.metaData == metaData }.to(beTrue())
            }

            it("Data from storage") {
                let url = URL(string: "bdce").unsafelyUnwrapped
                let range = NSRange(location: 0, length: 100)
                let data = "ABCEDGF".data(using: .utf8).unsafelyUnwrapped
                let storage = _Storage(url: url)
                storage.writeData(data, to: range)
                let dataRequest = LoadingDataRequest()
                dataRequest.currentOffset = 0
                dataRequest.requestedLength = 100
                let request = LoadingRequest()
                request.theDataRequest = dataRequest
                let fetcher = DataFetcher(storage: storage, requester: _Requester(url: url, plugins: []), loadingRequest: request)
                fetcher.fetch()
                expect { dataRequest.data == data }.to(beTrue())
            }

            it("Data from remote") {
                let url = URL(string: "efg").unsafelyUnwrapped
                let data = "dkdjdjddj".data(using: .utf8).unsafelyUnwrapped
                let storage = _Storage(url: url)
                let metaData = ZPC.MetaData(
                    contentType: "public.mpeg-4",
                    isByteRangeAccessSupported: true,
                    contentLength: data.count
                )
                storage.setMetaData(metaData)
                let range = NSRange(location: 0, length: data.count)
                let dataRequest = LoadingDataRequest()
                dataRequest.requestedOffset = 0
                dataRequest.requestedLength = 1
                dataRequest.requestsAllDataToEndOfResource = true
                let requester = _Requester(url: url, plugins: [])
                let request = LoadingRequest()
                request.theDataRequest = dataRequest
                let fetcher = DataFetcher(storage: storage, requester: requester, loadingRequest: request)
                fetcher.fetch()
                requester.didReceive(data: data, range: range)
                waitUntil(timeout: .seconds(5)) { done in
                    expect { dataRequest.data == data }.to(beTrue())
                    done()
                }
            }

            it("Data from storage and remote") {
                let url = URL(string: "qicqdde").unsafelyUnwrapped
                let storageDataOne = "dfjifjsi".data(using: .utf8).unsafelyUnwrapped
                let remoteData = "djddjdeeieiei".data(using: .utf8).unsafelyUnwrapped
                let storageDataTwo = "amazing".data(using: .utf8).unsafelyUnwrapped
                let mergedData = storageDataOne + remoteData + storageDataTwo
                let storage = _Storage(url: url)
                storage.writeData(storageDataOne, to: NSRange(location: 0, length: storageDataOne.count))
                storage.writeData(storageDataTwo, to: NSRange(location: storageDataOne.count + remoteData.count, length: storageDataTwo.count))
                let range = NSRange(location: 0, length: storageDataOne.count + remoteData.count + storageDataTwo.count)
                let dataRequest = LoadingDataRequest()
                dataRequest.requestedOffset = 0
                dataRequest.requestedLength = range.length
                let requester = _Requester(url: url, plugins: [])
                let request = LoadingRequest()
                request.theDataRequest = dataRequest
                let fetcher = DataFetcher(storage: storage, requester: requester, loadingRequest: request)
                fetcher.fetch()
                requester.didReceive(data: remoteData, range: NSRange(location: storageDataOne.count, length: remoteData.count))
                fetcher.onCompleted.delegate(on: self) { wlf, _ in
                    waitUntil(timeout: .seconds(5)) { done in
                        expect { dataRequest.data == mergedData }.to(beTrue())
                        done()
                    }
                }
                self._fetchers.append(fetcher)
            }
        }
    }

    private var _fetchers: [DataFetcher] = []
}

extension DataFetcherTests {
    private class _Storage: ZPCDataStorable {
        let url: URL
        init(url: URL) {
            self.url = url
            self.record = Record(url: url)
        }
        let onError = ZPDelegate<ZonPlayer.Error, Void>()
        var record: Record
        var pair: [NSRange: Data] = [:]

        func getCacheFragments(completion: @escaping ([NSRange]) -> Void) {
            completion(record.fragments)
        }
        
        func setMetaData(_ metaData: ZPC.MetaData) {
            self.record.metaData = metaData
        }
        
        func getMetaData(completion: @escaping (ZPC.MetaData?) -> Void) {
            completion(self.record.metaData)
        }
        
        func writeData(_ data: Data, to range: NSRange) {
            pair[range] = data
            record.addFragment(range)
        }
        
        func readData(from range: NSRange, completion: @escaping (Data?) -> Void) {
            completion(pair[range])
        }

        func clean(completion: (() -> Void)?) {
            pair = [:]
            record = Record(url: url)
            completion?()
        }
    }

    private class _Requester: ZPCDataRequestable {
        let url: URL
        let plugins: [ZPCStreamingPluggable]
        init(url: URL, plugins: [ZPCStreamingPluggable]) {
            self.url = url
            self.plugins = plugins
        }

        var pair: [NSRange: ZPCLoadingRequestable] = [:]

        func didReceive(data: Data, range: NSRange) {
            pair[range]?.theDataRequest?.respond(with: data)
        }

        func dataTask(forRange range: NSRange, withLoadingRequest loadingRequest: ZPCLoadingRequestable) -> ZPCDataTaskable {
            pair[range] = loadingRequest
            let task = URLSession.shared.dataTask(with: URLRequest(url: url))
            let result = DataFromRemote(task: task, range: range, loadingRequest: loadingRequest)
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                result.completion(.success(()))
            }
            return result
        }
    }
}
