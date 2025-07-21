//
//  ZonPlayer+Gettable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

extension ZonPlayer {
    public protocol Gettable {
        var isPlaying: Bool { get }

        /// The volume for player is greater than or equal to 0 and less than or equal to 1.
        var volume: Float { get }

        var rate: Float { get }

        var currentTime: TimeInterval { get }

        var duration: TimeInterval { get }

        var url: URL { get }
    }
}
