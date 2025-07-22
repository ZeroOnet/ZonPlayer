//
//  Builder.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

final class Builder: ZonPlayer.Settable, @unchecked Sendable {

    let url: URLConvertible & Sendable
    init(url: URLConvertible & Sendable) {
        self.url = url
    }

    var progressInterval: TimeInterval = 1
    var maxRetryCount: Int = 1

    // MARK: - ZPObservable
    var callbackQueue: DispatchQueue = .main

    var waitToPlay: ZonPlayer.Delegate<(ZonPlayable, ZonPlayer.WaitingReason), Void>?
    var play: ZonPlayer.Delegate<(ZonPlayable, Float), Void>?
    var pause: ZonPlayer.Delegate<ZonPlayable, Void>?
    var finish: ZonPlayer.Delegate<(ZonPlayable, URL), Void>?
    var error: ZonPlayer.Delegate<(ZonPlayable, ZonPlayer.Error), Void>?
    var progress: ZonPlayer.Delegate<(ZonPlayable, TimeInterval, TimeInterval), Void>?
    var duration: ZonPlayer.Delegate<(ZonPlayable, TimeInterval), Void>?
    var background: ZonPlayer.Delegate<(ZonPlayable, Bool), Void>?
    var rate: ZonPlayer.Delegate<(ZonPlayable, Float, Float), Void>?

    var retry: ZonPlayer.Retryable? = ZonPlayer.StepRetry()
    var session: ZonPlayer.Sessionable?
    var cache: ZonPlayer.Cacheable?

    // MARK: - ZPRemoteControlSettable
    var remoteControl: ZonPlayer.Delegate<ZonPlayer.RemoteControllable, Void>?
}
