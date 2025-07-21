//
//  DataProvider.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/13.
//

final class DataProvider: ZPC.Streaming.DataProvidable {
    let storage: ZPC.Streaming.DataStorable
    let requester: ZPC.Streaming.DataRequestable
    init(storage: ZPC.Streaming.DataStorable, requester: ZPC.Streaming.DataRequestable) {
        self.storage = storage
        self.requester = requester

        storage.onError.delegate(on: self) { wlf, error in
            wlf.requester.plugins.forEach { $0.anErrorOccurred(in: wlf.storage, error) }
        }
    }

    func addLoadingRequest(_ loadingRequest: ZPC.Streaming.LoadingRequestable) {
        let fetcher = DataFetcher(storage: storage, requester: requester, loadingRequest: loadingRequest)
        fetcher.onCompleted.delegate(on: self) { wlf, payload in
            wlf._pendingFetchers.removeAll { $0.loadingRequest == payload.0.loadingRequest }
        }
        fetcher.fetch()
        _pendingFetchers.append(fetcher)
    }

    func removeLoadingRequest(_ loadingRequest: ZPC.Streaming.LoadingRequestable) {
        _pendingFetchers.removeAll { $0.loadingRequest == loadingRequest }
    }

    private var _pendingFetchers: [DataFetcher] = []
}
