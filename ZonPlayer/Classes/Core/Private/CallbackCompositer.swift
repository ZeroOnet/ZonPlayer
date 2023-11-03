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

    lazy var waitToPlay: ((ZonPlayable, ZPWaitingReason) -> Void)? = { { [weak self] player, reason in
        self?._callback { $0.waitToPlay?(player, reason) }
        self?._monitor { $0.player(player, didWaitToPlay: reason) }
    } }()

    lazy var play: ((ZonPlayable, Float) -> Void)? = { { [weak self] player, rate in
        self?._callback { $0.play?(player, rate) }
        self?._monitor { $0.player(player, didPlay: rate) }
    } }()

    lazy var pause: ((ZonPlayable) -> Void)? = { { [weak self] player in
        self?._callback { $0.pause?(player) }
        self?._monitor { $0.playerDidPause(player) }
    } }()

    lazy var finish: ((ZonPlayable, URL) -> Void)? = { { [weak self] player, url in
        self?._callback { $0.finish?(player, url) }
        self?._monitor { $0.playerPlayDidFinish(player, url: url) }
    } }()

    lazy var error: ((ZonPlayable, ZonPlayer.Error) -> Void)? = { { [weak self] player, error in
        self?._callback { $0.error?(player, error) }
        self?._monitor { $0.player(player, playFailed: error) }
    } }()

    lazy var progress: ((ZonPlayable, TimeInterval, Double) -> Void)? = {
        { [weak self] player, current, percentage in
            self?._callback { $0.progress?(player, current, percentage) }
            self?._monitor { $0.player(player, playProgressDidChange: current, percentage: percentage) }
        }
    }()

    lazy var duration: ((ZonPlayable, TimeInterval) -> Void)? = { { [weak self] player, duration in
        self?._callback { $0.duration?(player, duration) }
        self?._monitor { $0.player(player, playDuration: duration) }
    } }()

    lazy var background: ((ZonPlayable, Bool) -> Void)? = { { [weak self] player, status in
        self?._callback { $0.background?(player, status) }
        self?._monitor { $0.play(player, backgroundPlay: status) }
    } }()

    lazy var rate: ((ZonPlayable, Float, Float) -> Void)? = { { [weak self] player, old, new in
        self?._callback { $0.rate?(player, old, new) }
        self?._monitor { $0.play(player, playRateDidChange: old, to: new) }
    } }()
}

extension CallbackCompositer {
    private func _callback(work: @escaping (ZPObservable) -> Void) {
        observer.callbackQueue.async { work(self.observer) }
    }

    private func _monitor(work: @escaping (ZPMonitorable) -> Void) {
        monitors.forEach { monitor in monitor.queue.async { work(monitor) } }
    }
}
