//
//  RemoteController.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

@_exported import MediaPlayer

final class RemoteController: ZonPlayer.RemoteControllable, @unchecked Sendable {
    // Hold a singleton now playing info to avoid race condition. https://stackoverflow.com/questions/34867294/mpnowplayinginfocenter-nowplayinginfo-not-updating-at-end-of-track
    var info: NowPlayingInfo { Self._info }

    var commands: [ZonPlayer.RemoteCommandable] = []

    var title: String?
    var artist: String?
    var artwork: UIImage?
    var extraInfo: [String: Sendable]?

    private var _freezed = false
    private var _stashedInfo: [String: Sendable]?

    nonisolated(unsafe)
    private static var _info = NowPlayingInfo()
}

extension RemoteController {
    func suspend() {
        guard _freezed == false else { return }
        commands.forEach { $0.disable() }
        _stashedInfo = Self._info.$existed.read { $0 }
        Self._info.set(info: nil)
        _freezed = true
    }

    func resume() {
        guard _freezed else { return }
        commands.forEach { $0.enable() }
        Self._info.set(info: _stashedInfo)
        _stashedInfo = nil
        _freezed = false
    }

    func update(work: @escaping (NowPlayingInfo) -> Void) {
        guard !_freezed else { return }
        Self._info.update(work: work)
    }

    func setup() {
        commands.forEach { $0.enable() }
        update { [weak self] in
            guard let self else { return }
            $0.title(self.title).artist(self.artist).extra(self.extraInfo)
            if let artwork = self.artwork { $0.artwork(artwork) }
        }
    }

    func reset() {
        commands.forEach { $0.disable() }
        Self._info.reset()
    }
}
