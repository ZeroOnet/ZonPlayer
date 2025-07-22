//
//  ZonPlayer+Settable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

extension ZonPlayer {
    public protocol Settable: Observable,
                              SessionSettable,
                              RemoteControlSettable,
                              CacheSettable,
                              RetrySettable,
                              Sendable {
        var url: URLConvertible & Sendable { get }
    }
}

extension ZonPlayer.Settable {
    public func activate() -> ZonPlayable {
        ZonPlayer.Manager.shared.start(setter: self)
    }

    public func activate(in view: ZonPlayerView) -> ZonPlayable {
        ZonPlayer.Manager.shared.start(setter: self, in: view)
    }
}
