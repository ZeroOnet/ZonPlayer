//
//  DataProvider.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/13.
//

final class DataProvider: ZPCStreamingDataProvidable {
    let storage: ZPCDataStorable
    let requester: ZPCDataRequestable
    init(storage: ZPCDataStorable, requester: ZPCDataRequestable) {
        self.storage = storage
        self.requester = requester

        storage.onError.delegate(on: self) { wlf, error in
            wlf.requester.plugins.forEach { $0.anErrorOccurred(in: wlf.storage, error) }
        }
    }

    func addLoadingRequest(_ loadingRequest: ZPCLoadingRequestable) {
        let fetcher = DataFetcher(storage: storage, requester: requester, loadingRequest: loadingRequest)
        fetcher.onCompleted.delegate(on: self) { wlf, payload in
            wlf._pendingFetchers.removeAll { $0.loadingRequest == payload.0.loadingRequest }
        }
        fetcher.fetch()
        _pendingFetchers.append(fetcher)
    }

    func removeLoadingRequest(_ loadingRequest: ZPCLoadingRequestable) {
        _pendingFetchers.removeAll { $0.loadingRequest == loadingRequest }
    }

    private var _pendingFetchers: [DataFetcher] = []
}
