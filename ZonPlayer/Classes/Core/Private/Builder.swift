//
//  Builder.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

final class Builder: ZPSettable {
    let url: URLConvertible
    init(url: URLConvertible) {
        self.url = url
    }

    var progressInterval: TimeInterval = 1
    var maxRetryCount: Int = 1

    // MARK: - ZPObservable
    var callbackQueue: DispatchQueue = .main

    var waitToPlay: ZPDelegate<(ZonPlayable, ZPWaitingReason), Void>?
    var play: ZPDelegate<(ZonPlayable, Float), Void>?
    var pause: ZPDelegate<ZonPlayable, Void>?
    var finish: ZPDelegate<(ZonPlayable, URL), Void>?
    var error: ZPDelegate<(ZonPlayable, ZonPlayer.Error), Void>?
    var progress: ZPDelegate<(ZonPlayable, TimeInterval, TimeInterval), Void>?
    var duration: ZPDelegate<(ZonPlayable, TimeInterval), Void>?
    var background: ZPDelegate<(ZonPlayable, Bool), Void>?
    var rate: ZPDelegate<(ZonPlayable, Float, Float), Void>?

    // MARK: - ZPSessionSettable
    var session: ZPSessionable?

    // MARK: - ZPRemoteControlSettable
    var remoteControl: ZPDelegate<ZPRemoteControllable, Void>?

    // MARK: - ZPCacheSettable
    var cache: ZPCacheable?
}
