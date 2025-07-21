//
//  ZonPlayer+Session.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public typealias ZPS = ZonPlayer.Session

extension ZonPlayer {
    public protocol Sessionable {
        func apply() throws
    }

    public protocol SessionSettable {
        var session: Sessionable? { get nonmutating set }
    }

    public enum Session {
        public struct SoloSilencePlayback: Sessionable {
            public init() {}

            public func apply() throws {
                try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
                try AVAudioSession.sharedInstance().setActive(true)
            }
        }

        public struct SoloBackgroundPlayback: Sessionable {
            public init() {}

            public func apply() throws {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            }
        }
    }
}

extension ZonPlayer.SessionSettable {
    public func session(_ session: ZonPlayer.Sessionable?) -> Self {
        self.session = session
        return self
    }
}
