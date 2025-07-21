//
//  CallbackCompositer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

final class CallbackCompositer: ZonPlayer.Observable {
    var callbackQueue: DispatchQueue
    let observer: ZonPlayer.Observable
    let monitors: [ZonPlayer.Monitorable]
    init(
        observer: ZonPlayer.Observable,
        monitors: [ZonPlayer.Monitorable],
        callbackQueue: DispatchQueue
    ) {
        self.observer = observer
        self.monitors = monitors
        self.callbackQueue = callbackQueue
    }

    lazy var waitToPlay: ZonPlayer.Delegate<(ZonPlayable, ZonPlayer.WaitingReason), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.waitToPlay?.call(input) }
            wlf._monitor { $0.player(input.0, didWaitToPlay: input.1) }
        }
    }()

    lazy var play: ZonPlayer.Delegate<(ZonPlayable, Float), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.play?.call(input) }
            wlf._monitor { $0.player(input.0, didPlay: input.1) }
        }
    }()

    lazy var pause: ZonPlayer.Delegate<ZonPlayable, Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.pause?.call(input) }
            wlf._monitor { $0.playerDidPause(input) }
        }
    }()

    lazy var finish: ZonPlayer.Delegate<(ZonPlayable, URL), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.finish?.call(input) }
            wlf._monitor { $0.playerPlayDidFinish(input.0, url: input.1) }
        }
    }()

    lazy var error: ZonPlayer.Delegate<(ZonPlayable, ZonPlayer.Error), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.error?.call(input) }
            wlf._monitor { $0.player(input.0, playFailed: input.1) }
        }
    }()

    lazy var progress: ZonPlayer.Delegate<(ZonPlayable, TimeInterval, TimeInterval), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.progress?.call(input) }
            wlf._monitor { $0.player(input.0, playProgressDidChange: input.1, totalTime: input.2) }
        }
    }()

    lazy var duration: ZonPlayer.Delegate<(ZonPlayable, TimeInterval), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.duration?.call(input) }
            wlf._monitor { $0.player(input.0, playDuration: input.1) }
        }
    }()

    lazy var background: ZonPlayer.Delegate<(ZonPlayable, Bool), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.background?.call(input) }
            wlf._monitor { $0.play(input.0, backgroundPlay: input.1) }
        }
    }()

    lazy var rate: ZonPlayer.Delegate<(ZonPlayable, Float, Float), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.rate?.call(input) }
            wlf._monitor { $0.play(input.0, playRateDidChange: input.1, to: input.2) }
        }
    }()
}

extension CallbackCompositer {
    private func _callback(work: @escaping (ZonPlayer.Observable) -> Void) {
        observer.callbackQueue.async { work(self.observer) }
    }

    private func _monitor(work: @escaping (ZonPlayer.Monitorable) -> Void) {
        monitors.forEach { monitor in monitor.queue.async { work(monitor) } }
    }
}
