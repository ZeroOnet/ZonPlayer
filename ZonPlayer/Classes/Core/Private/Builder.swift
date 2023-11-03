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
    var waitToPlay: ((ZonPlayable, ZPWaitingReason) -> Void)?
    var play: ((ZonPlayable, Float) -> Void)?
    var pause: ((ZonPlayable) -> Void)?
    var finish: ((ZonPlayable, URL) -> Void)?
    var error: ((ZonPlayable, ZonPlayer.Error) -> Void)?
    var progress: ((ZonPlayable, TimeInterval, TimeInterval) -> Void)?
    var duration: ((ZonPlayable, TimeInterval) -> Void)?
    var background: ((ZonPlayable, Bool) -> Void)?
    var rate: ((ZonPlayable, Float, Float) -> Void)?

    // MARK: - ZPSessionSettable
    var session: ZPSessionable?

    // MARK: - ZPRemoteControlSettable
    var remoteControl: ((ZPRemoteControllable) -> Void)?

    // MARK: - ZPCacheSettable
    var cache: ZPCacheable?
}
