//
//  ZPRemoteControllable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

/// The command of remote control.
public protocol ZPRemoteCommandable {
    func enable()
    func disable()
}

/// The remote control for player in lock screen or control center.
///
/// - Important: The time for playback is rounded.
public protocol ZPRemoteControllable {
    var commands: [ZPRemoteCommandable] { get nonmutating set }

    var title: String? { get nonmutating set }
    var artist: String? { get nonmutating set }
    var artwork: UIImage? { get nonmutating set }

    var extraInfo: [String: Any]? { get nonmutating set }
}

extension ZPRemoteControllable {
    @discardableResult
    public func title(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    public func artist(_ artist: String?) -> Self {
        self.artist = artist
        return self
    }

    @discardableResult
    public func artwork(_ artwork: UIImage?) -> Self {
        self.artwork = artwork
        return self
    }

    @discardableResult
    public func extraInfo(_ extraInfo: [String: Any]?) -> Self {
        self.extraInfo = extraInfo
        return self
    }

    @discardableResult
    public func playCommand(_ handler: @escaping () -> Void) -> Self {
        commands.append(ZonPlayer.RemoteCommand.play(handler: handler))
        return self
    }

    @discardableResult
    public func pauseCommand(_ handler: @escaping () -> Void) -> Self {
        commands.append(ZonPlayer.RemoteCommand.pause(handler: handler))
        return self
    }

    @discardableResult
    public func previousCommand(_ handler: @escaping () -> Void) -> Self {
        commands.append(ZonPlayer.RemoteCommand.previousTrack(handler: handler))
        return self
    }

    @discardableResult
    public func nextCommand(_ handler: @escaping () -> Void) -> Self {
        commands.append(ZonPlayer.RemoteCommand.nextTrack(handler: handler))
        return self
    }

    @discardableResult
    public func seekCommand(_ handler: @escaping (TimeInterval) -> Void) -> Self {
        commands.append(ZonPlayer.RemoteCommand.seek(handler: handler))
        return self
    }

    @discardableResult
    public func headsetCommand(_ handler: @escaping () -> Void) -> Self {
        commands.append(ZonPlayer.RemoteCommand.playOrPauseViaHeadset(handler: handler))
        return self
    }

    @discardableResult
    public func append(command: ZonPlayer.RemoteCommand) -> Self {
        commands.append(command)
        return self
    }
}

public protocol ZPRemoteControlSettable {
    var remoteControl: ((ZPRemoteControllable) -> Void)? { get nonmutating set }
}

extension ZPRemoteControlSettable {
    public func remoteControl(_ remoteControl: @escaping (ZPRemoteControllable) -> Void) -> Self {
        self.remoteControl = remoteControl
        return self
    }
}
