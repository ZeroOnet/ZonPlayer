//
//  ZonPlayer+RemoteCommand.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

public typealias ZPRemoteCommand = ZonPlayer.RemoteCommand

extension ZonPlayer {
    public final class RemoteCommand: NSObject, ZPRemoteCommandable {
        public typealias EventHandler = (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus

        public var handler: EventHandler?
        public let command: MPRemoteCommand
        public init(command: MPRemoteCommand) {
            self.command = command
            super.init()
            command.addTarget(self, action: #selector(commandAction(event:)))
            command.isEnabled = false
        }

        public func enable() {
            command.isEnabled = true
        }

        public func disable() {
            command.isEnabled = false
        }

        @objc
        private func commandAction(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
            // Your selector should return a MPRemoteCommandHandlerStatus value when
            // possible. This allows the system to respond appropriately to commands that
            // may not have been able to be executed in accordance with the application's
            // current state.
            handler?(event) ?? .commandFailed
        }
    }
}

extension ZPRemoteCommand {
    public static func play(handler: @escaping () -> Void) -> ZPRemoteCommand {
        play.handler = { _ -> MPRemoteCommandHandlerStatus in
            handler()
            return .success
        }
        return play
    }

    public static func pause(handler: @escaping () -> Void) -> ZPRemoteCommand {
        pause.handler = { _ -> MPRemoteCommandHandlerStatus in
            handler()
            return .success
        }
        return pause
    }

    public static func previousTrack(handler: @escaping () -> Void) -> ZPRemoteCommand {
        previousTrack.handler = { _ -> MPRemoteCommandHandlerStatus in
            handler()
            return .success
        }
        return previousTrack
    }

    public static func nextTrack(handler: @escaping () -> Void) -> ZPRemoteCommand {
        nextTrack.handler = { _ -> MPRemoteCommandHandlerStatus in
            handler()
            return .success
        }
        return nextTrack
    }

    public static func seek(handler: @escaping (TimeInterval) -> Void) -> ZPRemoteCommand {
        seek.handler = { event -> MPRemoteCommandHandlerStatus in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            handler(positionEvent.positionTime)
            return .success
        }
        return seek
    }

    public static func playOrPauseViaHeadset(handler: @escaping () -> Void) -> ZPRemoteCommand {
        headset.handler = { _ -> MPRemoteCommandHandlerStatus in
            handler()
            return .success
        }
        return headset
    }
}

/**
 We noticed that play paused automatically under background playback 
 because of executing `command.removeTarget` in iOS 15.x.x.

 So we wrapped singleton instance for remote command.
 */
extension ZPRemoteCommand {
    public static let play = ZPRemoteCommand(command: MPRemoteCommandCenter.shared().playCommand)
    public static let pause = ZPRemoteCommand(command: MPRemoteCommandCenter.shared().pauseCommand)
    public static let previousTrack = ZPRemoteCommand(command: MPRemoteCommandCenter.shared().previousTrackCommand)
    public static let nextTrack = ZPRemoteCommand(command: MPRemoteCommandCenter.shared().nextTrackCommand)
    public static let seek = ZPRemoteCommand(command: MPRemoteCommandCenter.shared().changePlaybackPositionCommand)
    public static let headset = ZPRemoteCommand(command: MPRemoteCommandCenter.shared().togglePlayPauseCommand)
}
