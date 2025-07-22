//
//  ZPC+Harvest+DefaultFileDownloader.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/6.
//

extension ZPC.Harvest {
    public final class DefaultFileDownloader: ZPC.Harvest.FileDownloadable {
        public var timeout: TimeInterval
        public let callbackQueue: DispatchQueue
        public init(timeout: TimeInterval, callbackQueue: DispatchQueue = .main) {
            self.timeout = timeout
            self.callbackQueue = callbackQueue
        }

        deinit {
            // https://stackoverflow.com/questions/28223345/memory-leak-when-using-nsurlsession-downloadtaskwithurl/35757989#35757989
            _session.invalidateAndCancel()
        }

        @discardableResult
        public func download(
            with url: URL,
            destination: URL,
            completion: @escaping @Sendable (Result<Void, ZonPlayer.Error>) -> Void
        ) -> ZPC.Harvest.Cancellable {
            let callback = ZonPlayer.Delegate<Result<Void, ZonPlayer.Error>, Void>()
            callback.delegate(on: self) { _, result in completion(result) }
            let request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: timeout
            )
            let context = DownloadTask.Context(url: url, request: request, destination: destination, callback: callback)
            let sessionTask = _session.downloadTask(with: request)
            let result = _delegate.addDownloadTask(with: sessionTask, context: context)
            result.onCompleted.delegate(on: self) { wlf, pair in
                wlf.callbackQueue.async { pair.1.call(pair.0) }
            }
            result.resume()
            return result
        }

        private lazy var _session: URLSession = {
            let result = URLSession(
                configuration: .default,
                delegate: _delegate,
                delegateQueue: nil
            )
            result.sessionDescription = "com.zonplayer.downloader.session"
            return result
        }()

        private lazy var _delegate: DownloadSessionDelegate = { .init() }()
    }
}
