<p align="center">
<img src="images/logo.png" alt="ZonPlayer" title="ZonPlayer" width="500"/>
</p>

<p align="center">
<a href="https://github.com/ZeroOnet/ZonPlayer/actions/workflows/build.yaml"><img src="https://github.com/ZeroOnet/ZonPlayer/actions/workflows/build.yaml/badge.svg"></a>
<a href="https://codecov.io/gh/ZeroOnet/ZonPlayer"><img src="https://codecov.io/gh/ZeroOnet/ZonPlayer/graph/badge.svg?token=3YD2FBEW4N"/></a>
<a href="https://cocoapods.org/pods/ZonPlayer"><img src="http://img.shields.io/cocoapods/v/ZonPlayer.svg?style=flat"></a>
<a href="https://github.com/ZeroOnet/ZonPlayer"><img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg"></a>
<a href="https://raw.githubusercontent.com/ZeroOnet/ZonPlayer/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black"></a>
</p>

ZonPlayer is a player library base on AVPlayer with cache and remote control support in iOS. For convenience, we defined interfaces can be called by chain.

# Features

- [x] Configure AVAudioSession asynchronously to prevent the main thread from hang.
- [x] Support 3rd-party cache like VIMediaCache. There are presetted with `ZPC.Harvest` and `ZPC.Streaming(base on AVAssetResourceLoader)`.
- [x] Manage now playing info and remote control command.
- [x] Use plugin to intercept progress for streaming playback.
- [x] Retry automatically if then player has an error, eg: media services were reset.

# Usage

```swift

    let player: ZonPlayable = ZonPlayer.player(URLConvertible)
        .session(ZonPlayer.Sessionable)
        .cache(ZonPlayer.Cacheable) // Conform ZonPlayer.Cacheable to customize cache category.
        .remoteControl(self) { wlf, payload in // Conform ZonPlayer.RemoteControllable to customize background playback controller.
            payload.title(String).artist(String)....
        }
        .onPaused(self) { wlf, payload in // Conform ZonPlayer.Observable to listen player.
        }
        .activate(in: ZonPlayerView)

    // Conform ZonPlayer.Controllable to control player instance.
    player.pause()
    player.play()
    player.seek(to: 0)
    // ...

    // Conform ZonPlayer.Gettable to read player status.
    player.currentTime
    player.duration
    player.url
    // ...

```

Integrate 3rd-party cache:

```swift

import VIMediaCache

final class TestCache: ZonPlayer.Cacheable {
    let manager = VIResourceLoaderManager()

    func prepare(url: URL, completion: @escaping (Result<AVURLAsset, ZonPlayer.Error>) -> Void) {
        let item = manager.playerItem(with: url).unsafelyUnwrapped
        let asset = (item.asset as? AVURLAsset).unsafelyUnwrapped
        completion(.success(asset))
    }
}

func play() {
    let player = ZonPlayer.player(url).cache(TestCache())
}

```

**Notice:** before using ZPC.Streaming, it is advisable to ensure that the URL supports random access to avoid potential unexpected issues. Below is the official documentation explanation for `isByteRangeAccessSupported`:
> If this property is not true for resources that must be loaded incrementally, loading of the resource may fail. Such resources include anything that contains media data.

# Compatibility

In iOS 18.0.1, we encountered an issue where video playback sometimes has no sound, occasionally accompanied by video stuttering. The example code is as follows:

```swift

func seekAndPause(to time: TimeInterval) {
    _player?.seek(to: time) { [weak self] _ in
        self?._player.pause()
    }
}

let time: TimeInterval = 10 // Any time
seekAndPause(to: time)
seekAndPause(to: time) // Call repeatedly
```

The official documentation describes the `completionHandler` parameter for `AVPlayer().seek` is:
> The completion handler for any prior seek request that is still in process will be invoked immediately with the finished parameter set to false.
> If the new request completes without being interrupted by another seek request or by any other operation the specified completion handler will be invoked with the finished parameter set to true.

Eventually, we discovered that when the `completionHandler` invocation flag is set to false, playback control encounters this issue. Thus, the fix is quite simple:

```swift
func seekAndPause(to time: TimeInterval) {
    _player?.seek(to: time) { [weak self] in
        guard $0 else { return }
        self?._player.pause()
    }
}
```

# Issues? Features!
## AVPlayer Unexpectedly Pauses After View Controller is Popped
Scenario:
- A UIViewController (Controller A) hosts an AVPlayer for video playback.
- Background audio playback is enabled via AVAudioSession.
- The app enters background → then returns to foreground.
- Immediately after returning to foreground, Controller A is popped from the navigation stack.
- The controller instance is retained manually and not deallocated.
- ❗️ Unexpected behavior: AVPlayer pauses automatically after pop, even though play() was not interrupted and no errors were triggered.

Possible Cause:
When Controller A is popped, its view is removed from the view hierarchy. If the AVPlayerLayer is attached to self.view.layer, it may lose its rendering context.
This could cause AVPlayer to automatically pause, especially after returning from background, because the rendering engine may detect that there is no active video layer available.

Fix Example:
```swift
final class A: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        video.playerView.playerLayer.player = _stashedPlayer
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let playerLayer = video.playerView.playerLayer
        _stashedPlayer = playerLayer?.player
        playerLayer?.player = nil
    }
}
```

# Requirements

- iOS 13.0 or later
- Swift 6.0 or later

# Installation

## CocoaPods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  pod 'ZonPlayer', '~> 1.1.0'
end

```

## Carthage

```
github "ZeroOnet/ZonPlayer" ~> 1.0.0
```

## Swift Package Manager
- File > Swift Packages > Add Package Dependency
- Add `git@github.com:ZeroOnet/ZonPlayer.git`
- Select "Up to Next Major" with "1.0.0"

# Author

ZeroOnet, zeroonetworkspace@gmail.com

# Blogs
[从头撸一个播放器 I —— ZonPlayer 需求分析及接口设计](https://zeroonet.com/2023/11/22/zonplayer-part-1/) <br>
[从头撸一个播放器 II —— 音频会话、远程控制和播放器实现](https://zeroonet.com/2023/11/24/zonplayer-part-2/) <br>
[从头撸一个播放器 III —— 缓存](https://zeroonet.com/2023/12/01/zonplayer-part-3/) <br>
[从头撸一个播放器 IV(终) —— Github Action 与组件发布](https://zeroonet.com/2023/12/05/zonplayer-part-4/)

# Reference
[Alamofire](https://github.com/Alamofire/Alamofire)<br>
[Kingfisher](https://github.com/onevcat/Kingfisher)<br>
[VIMediaCache](https://github.com/vitoziv/VIMediaCache)<br>

# License

ZonPlayer is available under the MIT license. See the LICENSE file for more info.
