//
//  ZonPlayer+Controllable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

extension ZonPlayer {
    public protocol Controllable: Sendable {
        func play()

        func pause()

        func seek(to time: TimeInterval, completion: (@Sendable @MainActor (Bool) -> Void)?)

        func setRate(_ value: Float)

        /// Take snapshot for video frame.
        /// - Parameters:
        ///   - time: Specified time interval for video, will replace current time instead of nil.
        ///   - completion: Callback with optional image in main queue.
        func takeSnapshot(at time: TimeInterval?, completion: @escaping @Sendable @MainActor (UIImage?) -> Void)

        /// Let player can playback in background.
        /// - Important: You should set supported audio session at first.
        func enableBackgroundPlayback()

        func disableBackgroundPlayback()

        func suspendPlayingInfo()

        func resumePlayingInfo()
    }
}

extension ZonPlayer.Controllable {
    public func seek(to time: TimeInterval) {
        seek(to: time, completion: nil)
    }

    public func takeSnapshot(completion: @escaping @Sendable @MainActor (UIImage?) -> Void) {
        takeSnapshot(at: nil, completion: completion)
    }
}
