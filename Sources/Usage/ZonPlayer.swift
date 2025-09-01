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
    public static func player(_ url: URLConvertible & Sendable) -> some Settable {
        Builder(url: url)
    }
}

@_unavailableFromAsync(message: "express the closure as an explicit function declared on the specified 'actor' instead")
nonisolated func assumeIsolated<T>(
    _ operation: @MainActor () throws -> T
) rethrows -> T {
    try withoutActuallyEscaping(operation) { (_ fucn: @escaping () throws -> T) throws -> T in
        try fucn()
    }
}
