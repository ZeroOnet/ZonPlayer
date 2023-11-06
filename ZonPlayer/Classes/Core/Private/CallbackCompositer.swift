//
//  CallbackCompositer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

final class CallbackCompositer: ZPObservable {
    var callbackQueue: DispatchQueue = .init(label: "com.zeroonet.player.compositecallback")
    let observer: ZPObservable
    let monitors: [ZPMonitorable]
    init(observer: ZPObservable, monitors: [ZPMonitorable]) {
        self.observer = observer
        self.monitors = monitors
    }

    lazy var waitToPlay: ZPDelegate<(ZonPlayable, ZPWaitingReason), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.waitToPlay?.call(input) }
            wlf._monitor { $0.player(input.0, didWaitToPlay: input.1) }
        }
    }()

    lazy var play: ZPDelegate<(ZonPlayable, Float), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.play?.call(input) }
            wlf._monitor { $0.player(input.0, didPlay: input.1) }
        }
    }()

    lazy var pause: ZPDelegate<ZonPlayable, Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.pause?.call(input) }
            wlf._monitor { $0.playerDidPause(input) }
        }
    }()

    lazy var finish: ZPDelegate<(ZonPlayable, URL), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.finish?.call(input) }
            wlf._monitor { $0.playerPlayDidFinish(input.0, url: input.1) }
        }
    }()

    lazy var error: ZPDelegate<(ZonPlayable, ZonPlayer.Error), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.error?.call(input) }
            wlf._monitor { $0.player(input.0, playFailed: input.1) }
        }
    }()

    lazy var progress: ZPDelegate<(ZonPlayable, TimeInterval, TimeInterval), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.progress?.call(input) }
            wlf._monitor { $0.player(input.0, playProgressDidChange: input.1, totalTime: input.2) }
        }
    }()

    lazy var duration: ZPDelegate<(ZonPlayable, TimeInterval), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.duration?.call(input) }
            wlf._monitor { $0.player(input.0, playDuration: input.1) }
        }
    }()

    lazy var background: ZPDelegate<(ZonPlayable, Bool), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.background?.call(input) }
            wlf._monitor { $0.play(input.0, backgroundPlay: input.1) }
        }
    }()

    lazy var rate: ZPDelegate<(ZonPlayable, Float, Float), Void>? = {
        .init().delegate(on: self) { wlf, input in
            wlf._callback { $0.rate?.call(input) }
            wlf._monitor { $0.play(input.0, playRateDidChange: input.1, to: input.2) }
        }
    }()
}

extension CallbackCompositer {
    private func _callback(work: @escaping (ZPObservable) -> Void) {
        observer.callbackQueue.async { work(self.observer) }
    }

    private func _monitor(work: @escaping (ZPMonitorable) -> Void) {
        monitors.forEach { monitor in monitor.queue.async { work(monitor) } }
    }
}
