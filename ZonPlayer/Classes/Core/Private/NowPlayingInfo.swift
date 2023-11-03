//
//  NowPlayingInfo.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

class NowPlayingInfo {
    // Avoid multi-thread accessing crashs.
    @Protected private(set) var existed: [String: Any] = [:]

    private lazy var _queue: DispatchQueue = {
        .init(label: "com.zeroonet.player.nowplayinginfo", qos: .userInitiated)
    }()
}

extension NowPlayingInfo {
    func update(work: @escaping (NowPlayingInfo) -> Void) {
        work(self)
        $existed.read { [weak self] in self?.set(info: $0) }
    }

    func set(info: [String: Any]?) {
        _queue.async { MPNowPlayingInfoCenter.default().nowPlayingInfo = info }
    }

    func reset() {
        $existed.write { $0 = [:] }
        _queue.async { MPNowPlayingInfoCenter.default().nowPlayingInfo = nil }
    }

    @discardableResult
    func title(_ title: String?) -> Self {
        $existed.write { $0[MPMediaItemPropertyTitle] = title }
        return self
    }

    @discardableResult
    func artist(_ artist: String?) -> Self {
        $existed.write { $0[MPMediaItemPropertyArtist] = artist }
        return self
    }

    @discardableResult
    func artwork(_ artwork: UIImage) -> Self {
        $existed.write {
            $0[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        }
        return self
    }

    @discardableResult
    func rate(_ rate: Float) -> Self {
        $existed.write { $0[MPNowPlayingInfoPropertyPlaybackRate] = rate }
        return self
    }

    @discardableResult
    func duration(_ duration: TimeInterval) -> Self {
        $existed.write { $0[MPMediaItemPropertyPlaybackDuration] = duration }
        return self
    }

    @discardableResult
    func time(_ time: TimeInterval) -> Self {
        $existed.write { $0[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time }
        return self
    }

    @discardableResult
    func extra(_ extra: [String: Any]?) -> Self {
        guard let extra else { return self }
        $existed.write { $0.merge(extra) { $1 } }
        return self
    }
}
