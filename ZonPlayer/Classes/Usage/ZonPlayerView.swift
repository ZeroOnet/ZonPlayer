//
//  ZonPlayerView.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

@_exported import AVFoundation

/// A subclass of UIVIew to show video frame.
/// - https://developer.apple.com/documentation/avfoundation/avplayerlayer
///
/// - Important: Nested type cannot be recognized by IB.
open class ZonPlayerView: UIView {
    public typealias Scale = AVLayerVideoGravity

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setupScale()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupScale()
    }

    public override static var layerClass: AnyClass { AVPlayerLayer.self }

    public var scale: Scale = .resizeAspect {
        didSet { playerLayer.videoGravity = scale }
    }

    public var playerLayer: AVPlayerLayer {
        // swiftlint:disable:next force_cast
        layer as! AVPlayerLayer
    }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    private func _setupScale() {
        scale = .resizeAspect
    }
}
