//
//  VideoPlayerScene.swift
//  Example-iOS
//
//  Created by 李文康 on 2023/11/7.
//

class VideoPlayerScene: UIViewController {
    @IBOutlet weak var videoView: ZonPlayerView!
    @IBOutlet weak var playOrPauseButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var timeProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _configureSubviews()
        _buildVideoPlayer()
    }

    @IBAction func rateAction(_ sender: UIButton) {
        let currentRate = _player?.rate ?? 1
        let newRate: Float = currentRate > 2 ? 0.5 : currentRate + 0.5
        _player?.setRate(newRate)
        rateButton.setTitle("Rate:\(newRate)", for: .normal)
    }

    @IBAction func playOrPauseAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            _player?.play()
        } else {
            _player?.pause()
        }
    }

    @IBAction func backwardAction(_ sender: UIButton) {
        guard let _player else { return }
        let time = max(0, _player.currentTime - 10)
        _player.seek(to: time)
    }

    @IBAction func forwardAction(_ sender: UIButton) {
        guard let _player else { return }
        let time = min(_player.duration, _player.currentTime + 10)
        _player.seek(to: time)
    }

    private let _url = URL(string: "https://media-video1.baydn.com/tpfoundation/video-center/9a6725b69a67fa4296c5881017a44866.f68a88fd644ece717d28b1abebec370e.mp4").unsafelyUnwrapped
    private var _player: ZonPlayable?
}

extension VideoPlayerScene {
    private func _configureSubviews() {
        title = "Video Player"
        view.backgroundColor = .white
        playOrPauseButton.setTitle("Play", for: .normal)
        playOrPauseButton.setTitle("Pause", for: .selected)
    }

    private func _buildVideoPlayer() {
        _player = ZonPlayer.player(_url)
            .onDuration(self) { wlf, payload in
                wlf.totalTimeLabel.text = wlf._timeString(value: payload.1)
            }
            .onProgress(self) { wlf, payload in
                wlf.currentTimeLabel.text = wlf._timeString(value: payload.1)
                wlf.timeProgressView.progress = Float(payload.1 / payload.2)
            }
            .onPlayed(self) { wlf, _ in
                wlf.playOrPauseButton.isSelected = true
            }
            .onPaused(self) { wlf, _ in
                wlf.playOrPauseButton.isSelected = false
            }
            .activate(in: videoView)
        _player?.play()
    }

    private func _timeString(value: TimeInterval) -> String {
        let intValue = Int(value)
        let hours = intValue / 3600
        let hoursInSeconds = hours * 3600
        let minutes = (intValue - hoursInSeconds) / 60
        let seconds = intValue - hoursInSeconds - minutes * 60
        let format = "%02i:"

        return (hours != 0 ? String(format: format, hours) : "")
            + (minutes != 0 ? String(format: format, minutes) : "")
            + String(format: "%02i", seconds)
    }
}
