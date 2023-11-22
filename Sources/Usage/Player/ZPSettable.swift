//
//  ZPSettable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public protocol ZPSettable: ZPObservable,
                            ZPSessionSettable,
                            ZPRemoteControlSettable,
                            ZPCacheSettable {
    var url: URLConvertible { get }
    var maxRetryCount: Int { get nonmutating set }
    var progressInterval: TimeInterval { get nonmutating set }
}

extension ZPSettable {
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

extension ZPSettable {
    public func activate() -> ZonPlayable {
        ZonPlayer.Manager.shared.start(setter: self)
    }

    public func activate(in view: ZonPlayerView) -> ZonPlayable {
        ZonPlayer.Manager.shared.start(setter: self, in: view)
    }
}
