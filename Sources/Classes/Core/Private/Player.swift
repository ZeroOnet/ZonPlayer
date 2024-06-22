//
//  Player.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

final class Player: NSObject {
    let url: URL
    let context: Context
    let session: ZPSessionable?
    let cache: ZPCacheable?
    let observer: ZPObservable
    let remoteControl: ZPDelegate<ZPRemoteControllable, Void>?
    let view: ZonPlayerView?
    init(
        url: URL,
        context: Context,
        session: ZPSessionable?,
        cache: ZPCacheable?,
        observer: ZPObservable,
        remoteControl: ZPDelegate<ZPRemoteControllable, Void>?,
        view: ZonPlayerView?
    ) {
        self.url = url
        self.context = context
        self.session = session
        self.cache = cache
        self.observer = observer
        self.remoteControl = remoteControl
        self.view = view

        self._restRetryCount = context.maxRetryCount

        super.init()

        _prepare()
    }

    deinit {
        _deinitPlayerIfNeeded()
    }

    private var _shouldResumePlaying = false
    private var _restRetryCount: Int
    private var _rate: Float = 1
    private var _background = false
    private var _player: AVPlayer?
    private var _timeObserver: Any?
    private var _duration: TimeInterval = 0
    private var _playable = false
    private var _pendingCommands: [_Commandable] = []
    private var _asset: AVURLAsset?
    private var _exclusiveCommand: _Commandable?

    private var _remoteController: RemoteController?

    private lazy var _screenshotQueue: DispatchQueue = {
        DispatchQueue(label: "com.zonplayer.screenshot", qos: .background)
    }()

    // swiftlint:disable:next block_based_kvo
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard
            let player = _player,
            let item = player.currentItem,
            let keyPath = keyPath,
            let kvoCase = KVOKeyPath(rawValue: keyPath)
        else { return }

        switch kvoCase {
        case .duration:
            let duration = item.duration.seconds
            guard _duration != duration else { return }
            _duration = duration
            _remoteController?.update { $0.duration(duration) }
            _callback { $0.duration?.call(($1, duration)) }
        case .status:
            if item.status == .failed {
                _playable = false
                let reason: ZonPlayer.Error.TerminationReason = item.error != nil
                ? .playerError(item.error.unsafelyUnwrapped) : .unknownError
                _callback { $0.error?.call(($1, .playerTerminated(reason))) }
                // When you get -11819, it means that a daemon has crashed.
                // Error Domain=AVFoundationErrorDomain Code=-11819 "Cannot Complete Action"
                // UserInfo={NSLocalizedDescription=Cannot Complete Action,
                // NSLocalizedRecoverySuggestion=Try again later.}.
                // https://developer.apple.com/forums/thread/679862
                // When media services were reset, We cannot recreate player before App enter foreground.
                guard (item.error as? NSError)?.code != -11819 else { return }
                _rebuildIfNeeded()
            } else if item.status == .readyToPlay {
                // Important:
                // Set player to view after AVPlayerItem is ready to play,
                // otherwise player cannot playback from beginning on a few device with specified system version.
                // eg: iPad 4 16.5.1
                view?.player = _player

                _playable = true
                _restRetryCount = self.context.maxRetryCount
                _executePendingCommands()
            } else if item.status == .unknown {
                _playable = false
                _callback { $0.waitToPlay?.call(($1, .itemLoading)) }
            }
        case .timeControlStatus:
            let status = player.timeControlStatus
            if status == .playing {
                _callback { $0.play?.call(($1, player.rate)) }
            } else if status == .paused {
                _callback { $0.pause?.call($1) }
            } else if status == .waitingToPlayAtSpecifiedRate {
                let reason: ZPWaitingReason
                if let desc = player.reasonForWaitingToPlay {
                    reason = .init(desc: desc)
                } else {
                    reason = .unknown
                }
                _callback { $0.waitToPlay?.call(($1, reason)) }
            }
        }
    }
}

extension Player: ZPGettable {
    var isPlaying: Bool { (_player?.rate ?? 0) != 0 }

    var volume: Float { _player?.volume ?? 0 }

    var rate: Float { _rate }

    var currentTime: TimeInterval { _player?.currentItem?.currentTime().seconds ?? 0 }

    var duration: TimeInterval { _duration }
}

extension Player: ZPControllable {
    func play() {
        _doOrPending(exclusive: true) {
            $0._main {
                let rate = $0._rate
                let time = $0.currentTime
                $0._player?.playImmediately(atRate: rate)
                $0._remoteController?.update { $0.rate(rate).time(time) }
                $0._shouldResumePlaying = true
            }
        }
    }

    func pause() {
        _doOrPending(exclusive: true) {
            $0._main {
                let time = $0.currentTime
                $0._player?.rate = 0
                // Important: Set rate to 0 to update time for remote control.
                $0._remoteController?.update { $0.rate(0).time(time) }
                $0._shouldResumePlaying = false
            }
        }
    }

    func setRate(_ value: Float) {
        guard value != _rate else { return }

        let old = _rate
        _rate = value

        _doOrPending { player in
            player._callback { $0.rate?.call(($1, old, value)) }
            player._main {
                if $0._player?.rate == 0 { return }
                $0.play()
            }
        }
    }

    func takeSnapshot(at time: TimeInterval?, completion: @escaping (UIImage?) -> Void) {
        _doOrPending { anp in
            let completion = { image in DispatchQueue.__zon_mainAsync { completion(image) } }
            guard let player = anp._player, let asset = player.currentItem?.asset else {
                completion(nil)
                return
            }
            anp._screenshotQueue.async {
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.apertureMode = .encodedPixels
                generator.requestedTimeToleranceAfter = .zero
                generator.requestedTimeToleranceBefore = .zero

                let time = time != nil ? anp._time(seconds: time.unsafelyUnwrapped) : player.currentTime()
                let cgImage = try? generator.copyCGImage(at: time, actualTime: nil)
                let image = cgImage != nil ? UIImage(cgImage: cgImage.unsafelyUnwrapped) : nil
                completion(image)
            }
        }
    }

    func seek(to time: TimeInterval, completion: ((Bool) -> Void)?) {
        if time < 0 { completion?(false); return }

        _doOrPending { player in
            player._player?.seek(
                to: player._time(seconds: time),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            ) { [weak player] finished in
                DispatchQueue.__zon_mainAsync {
                    completion?(finished)
                    player?._remoteController?.update { $0.time(time) }
                }
            }
        }
    }

    func enableBackgroundPlayback() {
        _background = true

        guard _player != nil else { return }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_backgroundAction),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_foregroundAction),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func disableBackgroundPlayback() {
        _background = false

        guard _player != nil else { return }

        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func suspendPlayingInfo() { _remoteController?.suspend() }

    func resumePlayingInfo() { _remoteController?.resume() }
}

extension Player {
    private func _prepare() {
        func setSession(completion: @escaping () -> Void) {
            if let session = session {
                _callback { $0.waitToPlay?.call(($1, .session)) }

                context.sessionQueue.async { [weak self] in
                    do {
                        try session.apply()
                        completion()
                    } catch {
                        if let self = self { self._callback { $0.error?.call(($1, .sessionError(session, error))) } }
                    }
                }
            } else { completion() }
        }

        func setCache(completion: @escaping (AVURLAsset) -> Void) {
            if let cache = cache {
                _callback { $0.waitToPlay?.call(($1, .cache)) }

                cache.prepare(url: url) { [weak self] in
                    switch $0 {
                    case .success(let asset):
                        completion(asset)
                    case .failure(let error):
                        if let self = self { self._callback { $0.error?.call(($1, error)) } }
                    }
                }
            } else { completion(AVURLAsset(url: url)) }
        }

        setSession {
            setCache { [weak self] asset in
                // Important: Hold player to avoid KVO issues.
                guard let self = self else { return }
                self._callback { $0.waitToPlay?.call(($1, .initializing)) }
                DispatchQueue.__zon_mainAsync {
                    self._asset = asset
                    self._initPlayer(asset: asset)
                }
            }
        }
    }

    private func _initPlayer(asset: AVURLAsset) {
        let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        player.actionAtItemEnd = .pause
        let seconds = context.progressInterval > 0 ? context.progressInterval : 1
        // Important: Time scale should be a large value to avoid hang.
        let interval = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: observer.callbackQueue
        ) { [weak self] time in
            guard let self else { return }
            self.observer.progress?.call((self, time.seconds, self._duration))
        }
        if player.currentItem != nil {
            KVOKeyPath.allCases.forEach {
                player.addObserver(self, forKeyPath: $0.rawValue, options: [.initial, .old, .new], context: nil)
            }
        }

        _player = player
        _timeObserver = timeObserver

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_mediaServicesWereResetAction),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )
        // Important: Set the currentItem of player to object.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_playToEndTimeAction),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_interruptionAction),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        if _background { enableBackgroundPlayback() }

        if let remoteControl = remoteControl {
            let remoteController = RemoteController()
            remoteControl.call(remoteController)
            remoteController.setup()
            _remoteController = remoteController
        }
    }

    private func _deinitPlayerIfNeeded() {
        guard let player = _player, player.currentItem != nil else { return }

        if let timeObserver = _timeObserver {
            player.removeTimeObserver(timeObserver)
            _timeObserver = nil
        }

        KVOKeyPath.allCases.forEach {
            player.removeObserver(self, forKeyPath: $0.rawValue, context: nil)
        }

         view?.player = nil
        _player = nil

        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        if _background { disableBackgroundPlayback() }
        _remoteController?.reset()
    }

    private func _rebuildIfNeeded() {
        let currentTime = currentTime
        let isPaused = _player?.rate == 0

        _deinitPlayerIfNeeded()

        if _restRetryCount > 0 {
            _prepare()
            seek(to: currentTime)
            if isPaused { pause() } else { play() }

            _restRetryCount -= 1
        }
    }
}

extension Player {
    @objc
    private func _mediaServicesWereResetAction(notification: NSNotification) {
        _callback { $0.error?.call(($1, .playerTerminated(.mediaServicesWereReset))) }
        _rebuildIfNeeded()
    }

    @objc
    private func _playToEndTimeAction(notification: NSNotification) {
        let url = url; _callback { $0.finish?.call(($1, url)) }
    }

    @objc
    private func _interruptionAction(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let rawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: rawValue)
        else { return }

        switch type {
        case .began: break
        case .ended: if _shouldResumePlaying { play() }
        @unknown default: break
        }
    }

    @objc
    private func _backgroundAction(notification: NSNotification) {
        view?.player = nil
        _callback { $0.background?.call(($1, true)) }
    }

    // https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_basic_video_player_ios_and_tvos/playing_audio_from_a_video_asset_in_the_background
    @objc
    private func _foregroundAction(notification: NSNotification) {
        view?.player = _player
        _callback { $0.background?.call(($1, false)) }
    }
}

extension Player {
    private struct _Command: _Commandable {
        let block: (Player) -> Void
        init(block: @escaping (Player) -> Void) {
            self.block = block
        }

        func execute(player: Player) {
            block(player)
        }
    }
    private func _doOrPending(exclusive: Bool = false, work: @escaping (Player) -> Void) {
        if _playable {
            work(self)
        } else {
            let command = _Command(block: work)
            if exclusive { _exclusiveCommand = command } else { _pendingCommands.append(command) }
        }
    }

    private func _executePendingCommands() {
        _exclusiveCommand?.execute(player: self)
        _exclusiveCommand = nil
        _pendingCommands.forEach { $0.execute(player: self) }
        _pendingCommands = []
    }

    private func _callback(work: @escaping (ZPObservable, Player) -> Void) {
        observer.callbackQueue.async { [weak self] in
            guard let self = self else { return }
            work(self.observer, self)
        }
    }

    private func _main(work: @escaping (Player) -> Void) {
        DispatchQueue.__zon_mainAsync { [weak self] in
            guard let self = self else { return }
            work(self)
        }
    }

    /**
     `preferredTimescale` should be setted with `asset.duration.timescale`.

     https://stackoverflow.com/questions/11462843/avplayer-seektotime-does-not-play-at-correct-position
     */
    private func _time(seconds: TimeInterval) -> CMTime {
        let timeScale = _asset?.duration.timescale ?? 1
        return CMTime(seconds: seconds, preferredTimescale: timeScale)
    }
}

extension Player {
    private enum KVOKeyPath: String, CaseIterable {
        case duration = "currentItem.duration"
        case status = "currentItem.status"
        case timeControlStatus = "timeControlStatus"
    }
}

private protocol _Commandable {
    func execute(player: Player)
}

extension DispatchQueue {
    fileprivate static func __zon_mainAsync(work: @escaping () -> Void) {
        if Thread.isMainThread { work(); return }
        DispatchQueue.main.async(execute: work)
    }
} // swiftlint:disable:this file_length
