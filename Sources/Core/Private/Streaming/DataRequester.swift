//
//  DataRequester.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/15.
//

final class DataRequester: ZPC.Streaming.DataRequestable {
    let url: URL
    let plugins: [ZPC.Streaming.Pluggable]
    init(url: URL, plugins: [ZPC.Streaming.Pluggable]) {
        self.url = url
        self.plugins = plugins
    }

    deinit { _session.invalidateAndCancel() }

    func dataTask(
        forRange range: NSRange,
        withLoadingRequest loadingRequest: ZPC.Streaming.LoadingRequestable
    ) -> ZPC.Streaming.DataTaskable {
        let lowerBound = range.location
        let upperBound = range.location + range.length - 1
        var request = plugins.reduce(URLRequest(url: url)) { $1.prepare($0, forRange: range) }
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("bytes=\(lowerBound)-\(upperBound)", forHTTPHeaderField: "Range")
        let task = _session.dataTask(with: request)
        let result = DataFromRemote(task: task, range: range, loadingRequest: loadingRequest)
        result.onRequest.delegate(on: self) { wlf, _ in
            wlf.plugins.forEach { $0.willSend(request, forRange: range) }
        }
        $_pendingTasks.write { $0[task] = result }
        return result
    }

    private lazy var _session: URLSession = {
        let delegate = DataSessionDelegate()
        delegate.onData.delegate(on: self) { wlf, payload in
            let task = payload.0
            let data = payload.1
            wlf.$_pendingTasks.read {
                guard let remote = $0[task], let url = task.originalRequest?.url else { return }
                remote.loadingRequest.theDataRequest?.respond(with: data)
                let length = data.count
                let range = NSRange(location: remote.contentOffset, length: length)
                remote.contentOffset += length
                wlf.plugins.forEach { $0.didReceive(data, forURL: url, withRange: range, fromRemote: true) }
            }
        }
        delegate.onMetaData.delegate(on: self) { wlf, payload in
            wlf.$_pendingTasks.read {
                let task = payload.0
                let metaData = payload.1
                guard let remote = $0[task] else { return }
                remote.loadingRequest.theMetaDataRequest?.metaData = metaData
                guard let url = task.originalRequest?.url else { return }
                wlf.plugins.forEach { $0.didReceive(metaData, forURL: url, fromRemote: true) }
            }
        }
        delegate.onFinished.delegate(on: self) { wlf, task in
            wlf.$_pendingTasks.write {
                guard let remote = $0[task], let url = task.originalRequest?.url else { return }
                remote.completion(.success(()))
                wlf.plugins.forEach {
                    $0.didComplete(.success(()), forURL: url, withRange: remote.range, fromRemote: true)
                }
                $0[task] = nil
            }
        }
        delegate.onFailed.delegate(on: self) { wlf, payload in
            let error = payload.1
            wlf.$_pendingTasks.write {
                let task = payload.0
                guard let remote = $0[task], let url = task.originalRequest?.url else { return }
                remote.completion(.failure(error))
                wlf.plugins.forEach {
                    $0.didComplete(.failure(error), forURL: url, withRange: remote.range, fromRemote: true)
                }
                $0[task] = nil
            }
        }
        let config = URLSessionConfiguration.default
        let delegateQueue = OperationQueue()
        delegateQueue.name = "com.zonplayer.streaming.session"
        return URLSession(
            configuration: config,
            delegate: delegate,
            delegateQueue: delegateQueue
        )
    }()

    @Protected
    private var _pendingTasks: [URLSessionTask: DataFromRemote] = [:]
}
