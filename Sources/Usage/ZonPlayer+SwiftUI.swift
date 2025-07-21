//
//  ZonPlayer+SwiftUI.swift
//  ZonPlayer
//
//  Created by 李文康 on 2025/7/18.
//

public typealias ZPSwiftUI = ZonPlayer.SwiftUI

extension ZonPlayer {
    @MainActor
    public final class SwiftUI: ObservableObject {
        @Published public var isPlaying = false
        @Published public var background = false
        @Published public var finished = false
        @Published public var rate: Float = 0
        @Published public var progress: (current: TimeInterval, total: TimeInterval) = (0, 0)
        @Published public var waitToPlay: ZonPlayer.WaitingReason = .initializing
        @Published public var error: ZonPlayer.Error?

        public private(set) var player: ZonPlayable?

        private var _setter: Settable?

        public init(
            url: URLConvertible,
            builder: ((Settable) -> Settable)? = nil
        ) {
            var setter = ZonPlayer.player(url)
            setter = setter
                .onPlayed(self) { wlf, _ in wlf.isPlaying = true }
                .onPaused(self) { wlf, _ in wlf.isPlaying = false }
                .onBackground(self) { wlf, info in wlf.background = info.1 }
                .onFinished(self) { wlf, _ in wlf.finished = true }
                .onRate(self) { wlf, info in wlf.rate = info.2 }
                .onProgress(self) { wlf, info in wlf.progress = (info.1, info.2) }
                .onDuration(self) { wlf, info in wlf.progress = (0, info.1) }
                .onWaitToPlay(self) { wlf, info in wlf.waitToPlay = info.1 }
                .onError(self) { wlf, info in wlf.error = info.1 }
            _setter = builder?(setter) ?? setter
        }

        public func activate() {
            player = _setter?.activate()
        }

        public func activate(in view: ZonPlayerViewSwiftUI) {
            player = _setter?.activate(in: view.view)
        }
    }
}
