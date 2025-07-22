//
//  Faker.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

struct Faker {}

extension Faker: ZonPlayer.Controllable {
    func takeSnapshot(at time: TimeInterval?, completion: @escaping @MainActor (UIImage?) -> Void) {}
    func seek(to time: TimeInterval, completion: (@MainActor (Bool) -> Void)?) {}
    func play() {}
    func pause() {}
    func setRate(_ value: Float) {}
    func enableBackgroundPlayback() {}
    func disableBackgroundPlayback() {}
    func suspendPlayingInfo() {}
    func resumePlayingInfo() {}
}

extension Faker: ZonPlayer.Gettable {
    var isPlaying: Bool { false }
    var volume: Float { 0 }
    var rate: Float { 0 }
    var currentTime: TimeInterval { 0 }
    var duration: TimeInterval { 0 }
    var url: URL { URL(string: "https://faker").unsafelyUnwrapped }
}
