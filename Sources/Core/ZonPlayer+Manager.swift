//
//  ZonPlayer+Manager.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

extension ZonPlayer {
    public final class Manager: @unchecked Sendable {
        public static let shared = Manager()

        /// Global player activity monitors like ZPObservable.
        ///
        /// - Important: Add monitor before playback.
        public var monitors: [Monitorable] = []

        public var enableConsoleLog: Bool = false {
            didSet {
                if enableConsoleLog {
                    guard !monitors.contains(where: { $0 is Logger }) else { return }
                    monitors.append(Logger(queue: logQueue))
                } else {
                    monitors.removeAll { $0 is Logger }
                }
            }
        }

        lazy var logQueue: DispatchQueue = {
            .init(label: "com.zonplayer.log")
        }()

        private init() {}

        /**
         Note that activating an audio session is a synchronous (blocking) operation.
         Therefore, we recommend that applications not activate their session from a thread where a long
         blocking operation will be problematic. —— From ObjC Audio Session setActive document explanation.

         On the other hand, we captured hang diagnostic because of it with MetricKit.

         So we should not apply audio session under main queue.
         */
        private lazy var _sessionQueue: DispatchQueue = {
            .init(label: "com.zonplayer.session", qos: .userInitiated)
        }()
    }
}

extension ZonPlayer.Manager {
    func start(
        setter: ZonPlayer.Settable,
        in view: ZonPlayerView? = nil
    ) -> some ZonPlayable {
        let url: URL
        do {
            url = try setter.url.asURL()
        } catch {
            url = URL(string: "https://zonplayer.faker").unsafelyUnwrapped
            setter.callbackQueue.async { setter.error?.call((nil, .invalidURL(setter.url))) }
        }
        let observer = CallbackCompositer(observer: setter, monitors: monitors, callbackQueue: logQueue)
        let session: (ZonPlayer.Sessionable, DispatchQueue)? = {
            if let session = setter.session { return (session, _sessionQueue) }
            return nil
        }()
        return Player(
            url: url,
            session: session,
            retry: setter.retry,
            cache: setter.cache,
            observer: observer,
            remoteControl: setter.remoteControl,
            view: view
        )
    }
}
