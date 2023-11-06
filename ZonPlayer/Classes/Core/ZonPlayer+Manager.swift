//
//  ZonPlayer+Manager.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

extension ZonPlayer {
    public final class Manager {
        public static let shared = Manager()

        /// Global player activity monitors like ZPObservable.
        ///
        /// - Important: Add monitor before playback.
        public var monitors: [ZPMonitorable] = []

        public var enableConsoleLog: Bool = false {
            didSet {
                if enableConsoleLog {
                    guard !monitors.contains(where: { $0 is Logger }) else { return }
                    monitors.append(Logger())
                } else {
                    monitors.removeAll { $0 is Logger }
                }
            }
        }

        private init() {}

        /**
         Note that activating an audio session is a synchronous (blocking) operation.
         Therefore, we recommend that applications not activate their session from a thread where a long
         blocking operation will be problematic. —— From ObjC Audio Session setActive document explanation.

         On the other hand, we captured hang diagnostic because of it with MetricKit.

         So we should not apply audio session under main queue.
         */
        private lazy var _sessionQueue: DispatchQueue = {
            .init(label: "com.zeroonet.player.session", qos: .userInitiated)
        }()
    }
}

extension ZonPlayer.Manager {
    func start(
        setter: ZPSettable,
        in view: ZonPlayerView? = nil
    ) -> ZonPlayable {
        do {
            let url = try setter.url.asURL()
            return Player(
                url: url,
                context: .init(
                    sessionQueue: _sessionQueue,
                    maxRetryCount: setter.maxRetryCount,
                    progressInterval: setter.progressInterval
                ),
                session: setter.session,
                cache: setter.cache,
                observer: CallbackCompositer(observer: setter, monitors: monitors),
                remoteControl: setter.remoteControl,
                view: view
            )
        } catch {
            let dummy = DummyPlayer()
            setter.callbackQueue.async { setter.error?.call((dummy, .invalidURL(setter.url))) }
            return dummy
        }
    }
}
