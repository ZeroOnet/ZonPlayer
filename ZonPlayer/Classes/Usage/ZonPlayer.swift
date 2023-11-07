//
//  ZonPlayer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public enum ZonPlayer {
    /// Build player by a chain call.
    ///
    /// ```swift
    ///
    /// ZonPlayer
    ///     .player(ZPSessionable)
    ///     .session() // Set audio session.
    ///     .remoteControl(ZPRemoteControllable) // Set background control and now playing info.
    ///     .cache(ZPCacheable) // Set cache policy like downloading before playback.
    ///
    /// ```
    public static func player(_ url: URLConvertible) -> ZPSettable {
        Builder(url: url)
    }
}
