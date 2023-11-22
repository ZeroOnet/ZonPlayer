//
//  DataRequesterTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

@testable import ZonPlayer

final class DataRequesterTests: QuickSpec {
    override func spec() {
        describe("Test data requester") {
            it("Download data with specified range") {
                let url = URL(string: "https://media-video1.baydn.com/tpfoundation/video-center/9a6725b69a67fa4296c5881017a44866.f68a88fd644ece717d28b1abebec370e.mp4").unsafelyUnwrapped
                let range = NSRange(location: 0, length: 1024)
                let loadingRequest = LoadingRequest()

                waitUntil(timeout: .seconds(20)) { done in
                    let plugin = _Plugin()
                    let requester = DataRequester(url: url, plugins: [plugin])
                    let remoteTask = requester.dataTask(forRange: range, withLoadingRequest: loadingRequest)
                    remoteTask.requestData {
                        defer { done() }
                        guard (try? $0.get()) != nil else { return }
                        expect { plugin.prepared }.to(beTrue())
                        expect { plugin.willSend }.to(beTrue())
                        expect { plugin.dataReceived }.toNot(beNil())
                        expect { plugin.metaDataReceived }.toNot(beNil())
                        let dataReceived = plugin.dataReceived.unsafelyUnwrapped
                        let metaDataReceived = plugin.metaDataReceived.unsafelyUnwrapped
                        let metaData = metaDataReceived.0
                        expect { dataReceived.0.count } == range.location + range.length
                        expect { dataReceived.1 } == url
                        expect { dataReceived.2 } == range
                        expect { dataReceived.3 }.to(beTrue())
                        expect { metaData.isByteRangeAccessSupported }.to(beTrue())
                        expect { metaData.contentType } == "public.mpeg-4"
                        expect { metaData.contentLength } == 58425217
                        expect { metaDataReceived.1 } == url
                        expect { metaDataReceived.2 }.to(beTrue())
                    }
                    self._requesters.append(requester)
                }
            }
        }
    }

    private var _requesters: [ZPCDataRequestable] = []
}

extension DataRequesterTests {
    private class _Plugin: ZPCStreamingPluggable {
        var prepared: Bool = false
        var willSend: Bool = false
        var dataReceived: (Data, URL, NSRange, Bool)?
        var metaDataReceived: (ZPC.MetaData, URL, Bool)?

        func prepare(_ request: URLRequest, forRange range: NSRange) -> URLRequest {
            prepared = true
            return request
        }

        func willSend(_ request: URLRequest, forRange range: NSRange) {
            willSend = true
        }

        func didReceive(_ data: Data, forURL url: URL, withRange range: NSRange, fromRemote remoteFlag: Bool) {
            dataReceived = (data, url, range, remoteFlag)
        }

        func didReceive(_ metaData: ZPC.MetaData, forURL url: URL, fromRemote remoteFlag: Bool) {
            metaDataReceived = (metaData, url, remoteFlag)
        }
    }
}
