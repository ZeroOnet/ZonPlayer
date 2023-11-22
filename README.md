<p align="center">
<img src="https://raw.githubusercontent.com/ZeroOnet/ZonPlayer/main/images/logo.png" alt="ZonPlayer" title="ZonPlayer" width="500"/>
</p>

<p align="center">
<a href="https://github.com/ZeroOnet/ZonPlayer/actions/workflows/build.yaml"><img src="https://github.com/ZeroOnet/ZonPlayer/actions/workflows/build.yaml/badge.svg"></a>
<a href="https://cocoapods.org/pods/ZonPlayer"><img src="http://img.shields.io/cocoapods/v/ZonPlayer.svg?style=flat"></a>
<a href="https://github.com/ZeroOnet/ZonPlayer"><img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg"></a>
<a href="https://raw.githubusercontent.com/ZeroOnet/ZonPlayer/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black"></a>
</p>

ZonPlayer is a player library base on AVPlayer with cache and remote control support in iOS. For convenience, we defined interfaces can be called by chain.

# Features

- [x] Configure AVAudioSession asynchronously to prevent the main thread from hang.
- [x] Support 3rd-party cache like VIMediaCache. There are presetted with `ZPC.DownloadThenPlay` and `ZPC.Streaming(base on AVAssetResourceLoader)`.
- [x] Manage now playing info and remote control command.
- [x] Use plugin to intercept progress for streaming playback.
- [x] Retry automatically if then player has an error, eg: media services were reset.

# Usage

```swift

    let player: ZonPlayable = ZonPlayer.player(URLConvertible)
        .session(ZPSessionable)
        .cache(ZPCacheable) // Conform ZPCacheable to customize cache category.
        .remoteControl(self) { wlf, payload in // Conform ZPRemoteControllable to customize background playback controller.
            payload.title(String).artist(String)....
        }
        .onPaused(self) { wlf, payload in // Conform ZPObservable to listen player.
        }
        .activate(in: ZonPlayerView)

    // Conform ZPControllable to control player instance.
    player.pause()
    player.play()
    player.seek(to: 0)
    // ...

    // Conform ZPGettable to read player status.
    player.currentTime
    player.duration
    player.url
    // ...

```

Integrate 3rd-party cache:

```swift

import VIMediaCache

final class TestCache: ZPCacheable {
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

# Requirements

- iOS 12.0 or later
- Swift 5.0 or later

# Installation

## CocoaPods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'ZonPlayer', '~> 1.0.0'
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

# Reference
[Alamofire](https://github.com/Alamofire/Alamofire)<br>
[Kingfisher](https://github.com/onevcat/Kingfisher)<br>
[VIMediaCache](https://github.com/vitoziv/VIMediaCache)<br>

# License

ZonPlayer is available under the MIT license. See the LICENSE file for more info.
