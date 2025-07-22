//
//  ZonPlayer+Monitorable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

extension ZonPlayer {
    public protocol Monitorable: Sendable {
        func player(_ player: ZonPlayable, didWaitToPlay reason: WaitingReason)

        func player(_ player: ZonPlayable, didPlay rate: Float)

        func playerDidPause(_ player: ZonPlayable)

        func playerPlayDidFinish(_ player: ZonPlayable, url: URL)

        func player(_ player: ZonPlayable, playFailed error: ZonPlayer.Error)

        func player(_ player: ZonPlayable, playProgressDidChange currentTime: TimeInterval, totalTime: TimeInterval)

        func player(_ player: ZonPlayable, playDuration duration: TimeInterval)

        func play(_ player: ZonPlayable, backgroundPlay status: Bool)

        func play(_ player: ZonPlayable, playRateDidChange from: Float, to: Float)

        /// The queue for monitor callback.
        var queue: DispatchQueue { get }
    }
}

extension ZonPlayer.Monitorable {
    public func player(_ player: ZonPlayable, didWaitToPlay reason: ZonPlayer.WaitingReason) {}
    public func player(_ player: ZonPlayable, didPlay rate: Float) {}
    public func playerDidPause(_ player: ZonPlayable) {}
    public func playerPlayDidFinish(_ player: ZonPlayable, url: URL) {}
    public func player(_ player: ZonPlayable, playFailed error: ZonPlayer.Error) {}
    public func player(
        _ player: ZonPlayable,
        playProgressDidChange currentTime: TimeInterval,
        totalTime: TimeInterval
    ) {}
    public func player(_ player: ZonPlayable, playDuration duration: TimeInterval) {}
    public func play(_ player: ZonPlayable, backgroundPlay status: Bool) {}
    public func play(_ player: ZonPlayable, playRateDidChange from: Float, to: Float) {}
}
