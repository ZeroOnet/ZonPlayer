//
//  ZPObservable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public protocol ZPObservable {
    var callbackQueue: DispatchQueue { get nonmutating set }

    var waitToPlay: ZPDelegate<(ZonPlayable, ZPWaitingReason), Void>? { get nonmutating set }
    var play: ZPDelegate<(ZonPlayable, Float), Void>? { get nonmutating set }
    var pause: ZPDelegate<ZonPlayable, Void>? { get nonmutating set }
    var finish: ZPDelegate<(ZonPlayable, URL), Void>? { get nonmutating set }
    var error: ZPDelegate<(ZonPlayable, ZonPlayer.Error), Void>? { get nonmutating set }
    var progress: ZPDelegate<(ZonPlayable, TimeInterval, TimeInterval), Void>? { get nonmutating set }
    var duration: ZPDelegate<(ZonPlayable, TimeInterval), Void>? { get nonmutating set }
    var background: ZPDelegate<(ZonPlayable, Bool), Void>? { get nonmutating set }
    var rate: ZPDelegate<(ZonPlayable, Float, Float), Void>? { get nonmutating set }
}

extension ZPObservable {
    /// Which dispatch queue to callback, the default value is main queue.
    public func callbackQueue(_ queue: DispatchQueue) -> Self {
        self.callbackQueue = queue
        return self
    }

    /// Listen to which reason cause player to wait to play.
    public func onWaitToPlay<T: AnyObject>(_ target: T, block: ((T, (ZonPlayable, ZPWaitingReason)) -> Void)?) -> Self {
        waitToPlay = (waitToPlay ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to player is played with specified rate.
    public func onPlayed<T: AnyObject>(_ target: T, block: ((T, (ZonPlayable, Float)) -> Void)?) -> Self {
        play = (play ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to player is paused.
    public func onPaused<T: AnyObject>(_ target: T, block: ((T, ZonPlayable) -> Void)?) -> Self {
        pause = (pause ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to player finished playing a url.
    public func onFinished<T: AnyObject>(_ target: T, block: ((T, (ZonPlayable, URL)) -> Void)?) -> Self {
        finish = (finish ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to player failed because of an error.
    public func onError<T: AnyObject>(_ target: T, block: ((T, (ZonPlayable, ZonPlayer.Error)) -> Void)?) -> Self {
        error = (error ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to progress for playback with current time and total time.
    public func onProgress<T: AnyObject>(
        _ target: T,
        block: ((T, (ZonPlayable, TimeInterval, TimeInterval)) -> Void)?
    ) -> Self {
        progress = (progress ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to player duration is available.
    public func onDuration<T: AnyObject>(_ target: T, block: ((T, (ZonPlayable, TimeInterval)) -> Void)?) -> Self {
        duration = (duration ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to player status for background playback.
    public func onBackground<T: AnyObject>(_ target: T, block: ((T, (ZonPlayable, Bool)) -> Void)?) -> Self {
        background = (background ?? .init()).delegate(on: target, block: block)
        return self
    }

    /// Listen to player rate changed with old and new values.
    public func onRate<T: AnyObject>(_ target: T, block: ((T, (ZonPlayable, Float, Float)) -> Void)?) -> Self {
        rate = (rate ?? .init()).delegate(on: target, block: block)
        return self
    }
}
