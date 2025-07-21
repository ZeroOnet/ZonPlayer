//
//  ZonPlayer+RemoteCommand.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

extension ZonPlayer {
    public final class RemoteCommand: NSObject, RemoteCommandable {
        public typealias EventHandler = (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus

        public var handler: ZonPlayer.Delegate<MPRemoteCommandEvent, MPRemoteCommandHandlerStatus>?
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

        fileprivate var action: ZonPlayer.Delegate<MPRemoteCommandEvent, MPRemoteCommandHandlerStatus> {
            if let handler { return handler }
            let result = ZonPlayer.Delegate<MPRemoteCommandEvent, MPRemoteCommandHandlerStatus>()
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

extension ZonPlayer.RemoteCommand {
    public static func play<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZonPlayer.RemoteCommand {
        play.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return play
    }

    public static func pause<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZonPlayer.RemoteCommand {
        pause.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return pause
    }

    public static func previousTrack<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZonPlayer.RemoteCommand {
        previousTrack.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return previousTrack
    }

    public static func nextTrack<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> ZonPlayer.RemoteCommand {
        nextTrack.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return nextTrack
    }

    public static func seek<T: AnyObject>(_ target: T, block: ((T, TimeInterval) -> Void)?) -> ZonPlayer.RemoteCommand {
        seek.action.delegate(on: target) { wlt, event in
            guard let pvt = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            block?(wlt, pvt.positionTime); return .success
        }
        return seek
    }

    public static func playOrPauseViaHeadset<T: AnyObject>(
        _ target: T,
        block: ((T) -> Void)?
    ) -> ZonPlayer.RemoteCommand {
        headset.action.delegate(on: target) { wlt, _ in block?(wlt); return .success }
        return headset
    }
}

/**
 We noticed that play paused automatically under background playback 
 because of executing `command.removeTarget` in iOS 15.x.x.

 So we wrapped singleton instance for remote command.
 */
extension ZonPlayer.RemoteCommand {
    // swiftlint:disable line_length
    public static let play = ZonPlayer.RemoteCommand(command: MPRemoteCommandCenter.shared().playCommand)
    public static let pause = ZonPlayer.RemoteCommand(command: MPRemoteCommandCenter.shared().pauseCommand)
    public static let previousTrack = ZonPlayer.RemoteCommand(command: MPRemoteCommandCenter.shared().previousTrackCommand)
    public static let nextTrack = ZonPlayer.RemoteCommand(command: MPRemoteCommandCenter.shared().nextTrackCommand)
    public static let seek = ZonPlayer.RemoteCommand(command: MPRemoteCommandCenter.shared().changePlaybackPositionCommand)
    public static let headset = ZonPlayer.RemoteCommand(command: MPRemoteCommandCenter.shared().togglePlayPauseCommand)
    // swiftlint:enable line_length
}
