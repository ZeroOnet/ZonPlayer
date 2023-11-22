//
//  ZonPlayer+Session.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public typealias ZPS = ZonPlayer.Session

extension ZonPlayer {
    public enum Session {
        public struct SoloSilencePlayback: ZPSessionable {
            public init() {}

            public func apply() throws {
                try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
                try AVAudioSession.sharedInstance().setActive(true)
            }
        }

        public struct SoloBackgroundPlayback: ZPSessionable {
            public init() {}

            public func apply() throws {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            }
        }
    }
}
