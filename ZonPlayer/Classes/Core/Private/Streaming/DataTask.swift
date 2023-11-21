//
//  DataTask.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/9.
//

struct DataFromStorage: ZPCDataTaskable {
    let storage: ZPCDataStorable
    let range: NSRange
    let loadingRequest: ZPCLoadingRequestable
    let plugins: [ZPCStreamingPluggable]

    func requestData(
        completion: @escaping (Result<Void, ZonPlayer.Error>) -> Void
    ) {
        let url = storage.url
        storage.readData(from: range) { data in
            if let data {
                loadingRequest.theDataRequest?.respond(with: data)
                plugins.forEach {
                    $0.didReceive(data, forURL: url, withRange: range, fromRemote: false)
                }
                completion(.success(()))
            } else {
                let error = ZonPlayer.Error.cacheFailed(.invalidDataFromStreamingStorage(url, range))
                let result: Result<Void, ZonPlayer.Error> = .failure(error)
                plugins.forEach {
                    $0.didComplete(result, forURL: url, withRange: range, fromRemote: false)
                }
                completion(result)
            }
        }
    }
}

final class DataFromRemote: ZPCDataTaskable {
    let task: URLSessionTask
    let range: NSRange
    let loadingRequest: ZPCLoadingRequestable
    let onRequest = ZPDelegate<Void, Void>()
    var contentOffset: Int
    init(
        task: URLSessionTask,
        range: NSRange,
        loadingRequest: ZPCLoadingRequestable
    ) {
        self.task = task
        self.range = range
        self.contentOffset = range.location
        self.loadingRequest = loadingRequest
    }

    func completion(_ result: Result<Void, ZonPlayer.Error>) {
        _completion?(result)
    }

    func requestData(
        completion: @escaping (Result<Void, ZonPlayer.Error>) -> Void
    ) {
        onRequest.call(())
        task.resume()
        _completion = completion
    }

    private var _completion: ((Result<Void, ZonPlayer.Error>) -> Void)?
}
