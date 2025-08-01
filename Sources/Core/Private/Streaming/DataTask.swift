//
//  DataTask.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/9.
//

struct DataFromStorage: ZPC.Streaming.DataTaskable, @unchecked Sendable {
    let storage: ZPC.Streaming.DataStorable
    let range: NSRange
    let loadingRequest: ZPC.Streaming.LoadingRequestable
    let plugins: [ZPC.Streaming.Pluggable]

    func requestData(
        completion: @escaping @Sendable (Result<Void, ZonPlayer.Error>) -> Void
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

final class DataFromRemote: ZPC.Streaming.DataTaskable, @unchecked Sendable {
    let task: URLSessionTask
    let range: NSRange
    let loadingRequest: ZPC.Streaming.LoadingRequestable
    let onRequest = ZonPlayer.Delegate<Void, Void>()
    var contentOffset: Int
    init(
        task: URLSessionTask,
        range: NSRange,
        loadingRequest: ZPC.Streaming.LoadingRequestable
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
