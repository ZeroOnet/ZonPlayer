//
//  DummyPlayer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

struct DummyPlayer {}

extension DummyPlayer: ZPControllable {
    func takeSnapshot(at time: TimeInterval?, completion: @escaping (UIImage?) -> Void) {}
    func seek(to time: TimeInterval, completion: ((Bool) -> Void)?) {}
    func play() {}
    func pause() {}
    func setRate(_ value: Float) {}
    func enableBackgroundPlayback() {}
    func disableBackgroundPlayback() {}
    func suspendPlayingInfo() {}
    func resumePlayingInfo() {}
}

extension DummyPlayer: ZPGettable {
    var isPlaying: Bool { false }
    var volume: Float { 0 }
    var rate: Float { 0 }
    var currentTime: TimeInterval { 0 }
    var duration: TimeInterval { 0 }
    var url: URL { URL(string: "https://dummy").unsafelyUnwrapped }
}
