# ZonPlayer
A library for player base on AVPlayer with cache and remote control support in iOS. For convenience, we defined interfaces can be called by chain.

# Usage

```swift

    let player: ZonPlayable = ZonPlayer.player(URLConvertible)
        .session(ZPSessionable)
        .cache(ZPCacheable)
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

# Cache
- [x] Download url and then play.
- [ ] Download url during playing. // TODO
