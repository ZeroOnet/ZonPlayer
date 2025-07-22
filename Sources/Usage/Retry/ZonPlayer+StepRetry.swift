//
//  ZonPlayer+StepRetry.swift
//  ZonPlayer
//
//  Created by 李文康 on 2025/7/21.
//

extension ZonPlayer {
    public final class StepRetry: Retryable, @unchecked Sendable {
        public let maxRetryCount: Int
        public let interval: TimeInterval
        public let modifier: ((URL) -> URL?)?
        private var _restRetryCount: Int
        public init(
            maxRetryCount: Int = 3,
            interval: TimeInterval = 3,
            modifier: ((URL) -> URL?)? = nil
        ) {
            self.maxRetryCount = maxRetryCount
            self.interval = interval
            self._restRetryCount = maxRetryCount
            self.modifier = modifier
        }

        public func shouldRetry(for url: URL, callback: @escaping @Sendable (URL?) -> Void) {
            if _restRetryCount <= 0 { callback(nil); return }
            _restRetryCount -= 1
            let seconds = TimeInterval(maxRetryCount - _restRetryCount) * interval
            _queue.asyncAfter(deadline: .now() + seconds) { [weak self] in
                guard let self else { return callback(nil) }
                let newURL = modifier?(url) ?? url
                callback(newURL)
            }
        }

        private lazy var _queue: DispatchQueue = {
            .init(label: "com.zonplayer.retry.step")
        }()
    }
}
