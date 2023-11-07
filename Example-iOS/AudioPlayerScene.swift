//
//  AudioPlayerScene.swift
//  Example-iOS
//
//  Created by 李文康 on 2023/11/7.
//

class AudioPlayerScene: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _configureSubviews()
        _buildAudioPlayer()
    }

    private let _url = URL(string: "https://media-audio1.baydn.com/creeper/listening/33aede75f51823e9f7242cc65d09bc45.8c3bc6434a2d9c9b61f7fe28b519a841.mp3").unsafelyUnwrapped
    private var _player: ZonPlayable?
}

extension AudioPlayerScene {
    private func _configureSubviews() {
        title = "Audio Player"
        view.backgroundColor = .white
    }

    private func _buildAudioPlayer() {
        _player = ZonPlayer.player(_url)
            .cache(ZPDownloadBeforePlayback())
            .activate()
        _player?.play()
    }
}
