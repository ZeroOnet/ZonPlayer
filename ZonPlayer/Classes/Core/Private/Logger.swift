//
//  Logger.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

final class Logger: ZPMonitorable {
    let queue = DispatchQueue(label: "com.zeroonet.player.logger", qos: .utility)

    func player(_ player: ZonPlayable, didWaitToPlay reason: ZPWaitingReason) {
        _print("did wait to play: \(reason)")
    }

    func player(_ player: ZonPlayable, didPlay rate: Float) {
        _print("did play, the rate is \(rate)")
    }

    func playerDidPause(_ player: ZonPlayable) {
        _print("did pause")
    }

    func playerPlayDidFinish(_ player: ZonPlayable, url: URL) {
        _print("did finish playback with \(url)")
    }

    func player(_ player: ZonPlayable, playFailed error: ZonPlayer.Error) {
        _print("play failed because of \(error.localizedDescription)")
    }

    func player(_ player: ZonPlayable, playDuration duration: TimeInterval) {
        _print("playback duration is \(duration)")
    }

    func play(_ player: ZonPlayable, backgroundPlay status: Bool) {
        _print("did \(status ? "enter" : "exit") background playback")
    }

    func play(_ player: ZonPlayable, playRateDidChange from: Float, to: Float) {
        _print("playback rate is change to \(to) from \(from)")
    }
}

private func _print(_ message: String) {
    print("ZonPlayer \(message).")
}
