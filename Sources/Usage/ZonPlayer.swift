//
//  ZonPlayer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

/// A namespace with nested type.
public enum ZonPlayer {
    /// Build player by a chain call.
    ///
    /// ```swift
    ///
    /// ZonPlayer
    ///     .player(URLConvertible)
    ///     .session(Sessionable) // Set audio session.
    ///     .remoteControl(RemoteControllable) // Set background control and now playing info.
    ///     .cache(Cacheable) // Set cache policy like downloading before playback.
    ///
    /// ```
    public static func player(_ url: URLConvertible) -> Settable {
        Builder(url: url)
    }
}
