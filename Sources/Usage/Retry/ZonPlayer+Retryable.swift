//
//  ZonPlayer+Retryable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2025/7/21.
//

extension ZonPlayer {
    public protocol Retryable: Sendable {
        /// Whether to perform a retry when the player fails to play.
        /// - Parameters:
        ///   - url: The original url.
        ///   - callback: The new url to use for playback. If this value is `nil`, no retry will be attempted.
        func shouldRetry(for url: URL, callback: @escaping @Sendable (URL?) -> Void)
    }

    public protocol RetrySettable: Sendable {
        var retry: Retryable? { get nonmutating set }
    }
}

extension ZonPlayer.RetrySettable {
    @discardableResult
    public func retry(_ retry: ZonPlayer.Retryable) -> Self {
        self.retry = retry
        return self
    }
}
