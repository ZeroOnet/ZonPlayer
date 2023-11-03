//
//  ZPObservable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public protocol ZPObservable {
    var callbackQueue: DispatchQueue { get nonmutating set }

    var waitToPlay: ((ZonPlayable, ZPWaitingReason) -> Void)? { get nonmutating set }
    var play: ((ZonPlayable, Float) -> Void)? { get nonmutating set }
    var pause: ((ZonPlayable) -> Void)? { get nonmutating set }
    var finish: ((ZonPlayable, URL) -> Void)? { get nonmutating set }
    var error: ((ZonPlayable, ZonPlayer.Error) -> Void)? { get nonmutating set }
    var progress: ((ZonPlayable, TimeInterval, TimeInterval) -> Void)? { get nonmutating set }
    var duration: ((ZonPlayable, TimeInterval) -> Void)? { get nonmutating set }
    var background: ((ZonPlayable, Bool) -> Void)? { get nonmutating set }
    var rate: ((ZonPlayable, Float, Float) -> Void)? { get nonmutating set }
}

extension ZPObservable {
    /// Which dispatch queue to callback, the default value is main queue.
    public func callbackQueue(_ queue: DispatchQueue) -> Self {
        self.callbackQueue = queue
        return self
    }

    /// Listen to which reason cause player to wait to play.
    public func onWaitToPlay(_ waitToPlay: @escaping (ZonPlayable, ZPWaitingReason) -> Void) -> Self {
        self.waitToPlay = waitToPlay
        return self
    }

    /// Listen to player is played with specified rate.
    public func onPlayed(_ play: @escaping (ZonPlayable, Float) -> Void) -> Self {
        self.play = play
        return self
    }

    /// Listen to player is paused.
    public func onPaused(_ pause: @escaping (ZonPlayable) -> Void) -> Self {
        self.pause = pause
        return self
    }

    /// Listen to player finished playing a url.
    public func onFinished(_ finish: @escaping (ZonPlayable, URL) -> Void) -> Self {
        self.finish = finish
        return self
    }

    /// Listen to player failed because of an error.
    public func onError(_ error: @escaping (ZonPlayable, ZonPlayer.Error) -> Void) -> Self {
        self.error = error
        return self
    }

    /// Listen to progress for playback with current time and total time.
    public func onProgress(_ progress: @escaping (ZonPlayable, TimeInterval, TimeInterval) -> Void) -> Self {
        self.progress = progress
        return self
    }

    /// Listen to player duration is available.
    public func onDuration(_ duration: @escaping (ZonPlayable, TimeInterval) -> Void) -> Self {
        self.duration = duration
        return self
    }

    /// Listen to player status for background playback.
    public func onBackground(_ background: @escaping (ZonPlayable, Bool) -> Void) -> Self {
        self.background = background
        return self
    }

    /// Listen to player rate changed.
    public func onRate(_ rate: @escaping (ZonPlayable, _ old: Float, _ new: Float) -> Void) -> Self {
        self.rate = rate
        return self
    }
}
