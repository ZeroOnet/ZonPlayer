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
                              Sendable {
        var url: URLConvertible & Sendable { get }
        var maxRetryCount: Int { get nonmutating set }
        var progressInterval: TimeInterval { get nonmutating set }
    }
}

extension ZonPlayer.Settable {
    /// Maximum retry time when an error occurred. The default value is 1.
    public func maxRetryCount(_ maxRetryCount: Int) -> Self {
        self.maxRetryCount = maxRetryCount
        return self
    }

    /// The time interval for playback progress callback. The default value is 1.
    public func progressInterval(_ progressInterval: TimeInterval) -> Self {
        self.progressInterval = progressInterval
        return self
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
