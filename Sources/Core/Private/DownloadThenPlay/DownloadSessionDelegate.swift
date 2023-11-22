//
//  DownloadSessionDelegate.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/7.
//

final class DownloadSessionDelegate: NSObject {
    func addDownloadTask(
        with sessionTask: URLSessionDownloadTask,
        context: DownloadTask.Context
    ) -> DownloadTask {
        _lock.around {
            let result = DownloadTask(context: context, task: sessionTask)
            result.onCancelled.delegate(on: self) { [weak result, weak sessionTask] wlf, callback in
                guard let result, let sessionTask else { return }
                let error = ZonPlayer.Error.cacheFailed(.downloadExplicitlyCancelled(context.url))
                result.onCompleted.call((.failure(error), callback))
                wlf._removeDownloadTask(with: sessionTask)
            }
            _taskPairs[sessionTask] = result
            return result
        }
    }

    private func _removeDownloadTask(with sessionTask: URLSessionTask) {
        _lock.around { _taskPairs[sessionTask] = nil }
    }

    private var _taskPairs: [URLSessionTask: DownloadTask] = [:]
    private let _lock = NSLock()
}

extension DownloadSessionDelegate: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let existed = _taskPairs[downloadTask] else { return }

        let context = existed.context
        let result: Result<Void, ZonPlayer.Error>
        let fileManager = FileManager.default
        let destination = context.destination

        do {
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }

            try fileManager.moveItem(at: location, to: destination)
            result = .success(())
        } catch {
            result = .failure(.cacheFailed(.fileStoreFailed(location, error)))
        }

        existed.onCompleted.call((result, context.callback))
        _removeDownloadTask(with: downloadTask)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let existed = _taskPairs[task], let error else { return }
        let context = existed.context
        existed.onCompleted.call((.failure(.cacheFailed(.downloadFailed(context.url, error))), context.callback))
        _removeDownloadTask(with: task)
    }
}
