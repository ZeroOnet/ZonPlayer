//
//  ZonPlayer+RemoteControllable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

extension ZonPlayer {
    /// The command of remote control.
    public protocol RemoteCommandable {
        func enable()
        func disable()
    }

    /// The remote control for player in lock screen or control center.
    ///
    /// - Important: The time for playback is rounded.
    public protocol RemoteControllable {
        var commands: [RemoteCommandable] { get nonmutating set }

        var title: String? { get nonmutating set }
        var artist: String? { get nonmutating set }
        var artwork: UIImage? { get nonmutating set }

        var extraInfo: [String: Sendable]? { get nonmutating set }
    }

    public protocol RemoteControlSettable {
        var remoteControl: ZonPlayer.Delegate<RemoteControllable, Void>? { get nonmutating set }
    }
}

extension ZonPlayer.RemoteControllable {
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
    public func extraInfo(_ extraInfo: [String: Sendable]?) -> Self {
        self.extraInfo = extraInfo
        return self
    }

    @discardableResult
    public func playCommand<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> Self {
        commands.append(ZonPlayer.RemoteCommand.play(target, block: block))
        return self
    }

    @discardableResult
    public func pauseCommand<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> Self {
        commands.append(ZonPlayer.RemoteCommand.pause(target, block: block))
        return self
    }

    @discardableResult
    public func previousCommand<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> Self {
        commands.append(ZonPlayer.RemoteCommand.previousTrack(target, block: block))
        return self
    }

    @discardableResult
    public func nextCommand<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> Self {
        commands.append(ZonPlayer.RemoteCommand.nextTrack(target, block: block))
        return self
    }

    @discardableResult
    public func seekCommand<T: AnyObject>(_ target: T, block: ((T, TimeInterval) -> Void)?) -> Self {
        commands.append(ZonPlayer.RemoteCommand.seek(target, block: block))
        return self
    }

    @discardableResult
    public func headsetCommand<T: AnyObject>(_ target: T, block: ((T) -> Void)?) -> Self {
        commands.append(ZonPlayer.RemoteCommand.playOrPauseViaHeadset(target, block: block))
        return self
    }

    @discardableResult
    public func append(command: ZonPlayer.RemoteCommand) -> Self {
        commands.append(command)
        return self
    }
}

extension ZonPlayer.RemoteControlSettable {
    public func remoteControl<T: AnyObject>(_ target: T, block: ((T, ZonPlayer.RemoteControllable) -> Void)?) -> Self {
        remoteControl = (remoteControl ?? .init()).delegate(on: target, block: block)
        return self
    }
}
