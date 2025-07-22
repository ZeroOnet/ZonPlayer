//
//  DownloadTask.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/7.
//

final class DownloadTask: ZPC.Harvest.Cancellable {
    typealias Callback = ZonPlayer.Delegate<Result<Void, ZonPlayer.Error>, Void>

    let onCancelled = ZonPlayer.Delegate<Callback, Void>()
    let onCompleted = ZonPlayer.Delegate<(Result<Void, ZonPlayer.Error>, Callback), Void>()

    private(set) var isCancelled: Bool = false
    let context: Context
    let task: URLSessionDownloadTask
    init(context: Context, task: URLSessionDownloadTask) {
        self.context = context
        self.task = task
    }

    // Important: Task cannot resume after cancelling.
    func cancel() {
        if isCancelled { return }
        _lock.around { isCancelled = true; task.cancel(); onCancelled.call(context.callback) }
    }

    func resume() {
        if _started { return }
        _lock.around { _started = true; task.resume() }
    }

    private let _lock = NSLock()
    private var _started = false
}

extension DownloadTask {
    struct Context {
        let url: URL
        let request: URLRequest
        let destination: URL
        let callback: Callback
    }
}
