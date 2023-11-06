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

        public var handler: ZPDelegate<MPRemoteCommandEvent, MPRemoteCommandHandlerStatus>?
        public let command: MPRemoteCommand
        public init(command: MPRemoteCommand) {
            self.command = command
            super.init()
            command.addTarget(self, action: #selector(_commandAction(event:)))
            command.isEnabled = false
        }

        public func enable() {
            command.isEnabled = true
        }

        public func disable() {
            command.isEnabled = false
        }

        fileprivate var action: ZPDelegate<MPRemoteCommandEvent, MPRemoteCommandHandlerStatus> {
            if let handler { return handler }
            let result = ZPDelegate<MPRemoteCommandEvent, MPRemoteCommandHandlerStatus>()
            handler = result
            return result
        }

        @objc
        private func _commandAction(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
            // Your selector should return a MPRemoteCommandHandlerStatus value when
            // possible. This allows the system to respond appropriately to commands that
            // may not have been able to be executed in accordance with the application's
            // current state.
            handler?.call(event) ?? .commandFailed
        }
    }
}

extension ZPRemoteCommand {
    public static func play<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZPRemoteCommand {
        play.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return play
    }

    public static func pause<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZPRemoteCommand {
        pause.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return pause
    }

    public static func previousTrack<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZPRemoteCommand {
        previousTrack.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return previousTrack
    }

    public static func nextTrack<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZPRemoteCommand {
        nextTrack.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return nextTrack
    }

    public static func seek<T: AnyObject>(_ target: T, block: ((T, TimeInterval) -> Void)?) -> ZPRemoteCommand {
        seek.action.delegate(on: target) { wlt, event in
            guard let pvt = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            block?(wlt, pvt.positionTime); return .success
        }
        return seek
    }

    public static func playOrPauseViaHeadset<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZPRemoteCommand {
        headset.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
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
