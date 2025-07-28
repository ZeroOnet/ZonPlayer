//
//  ControllerTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

final class ControllerTests: QuickSpec {
    override static func spec() {
        describe("Test player controller") {
            it("Play") {
                waitUntil(timeout: .seconds(5)) { done in
                    let player = ZonPlayer
                        .player(self._url)
                        .onError(_error) { _, _ in
                            self.__zon_triggerUnexpectedError()
                        }
                        .onPlayed(_play) { _, payload in
                            expect { payload.1 } == 1
                            done()
                        }
                        .activate()
                    player.play()
                    self._players.append(player)
                }
            }

            it("Pause") {
                waitUntil(timeout: .seconds(5)) { done in
                    let player = ZonPlayer
                        .player(self._url)
                        .onError(_error) { _, _ in
                            self.__zon_triggerUnexpectedError()
                        }
                        .onPaused(_pause) { _, _ in
                            done()
                        }
                        .activate()
                    player.play()
                    player.pause()
                    self._players.append(player)
                }
            }

            it("Set playback rate") {
                waitUntil(timeout: .seconds(5)) { done in
                    let rate: Float = 1.5
                    let player = ZonPlayer
                        .player(self._url)
                        .onError(_error) { _, _ in
                            self.__zon_triggerUnexpectedError()
                        }
                        .onRate(_rate) { _, payload in
                            expect { payload.1 } == 1
                            expect { payload.2 } == rate
                            done()
                        }
                        .activate()
                    player.setRate(rate)
                    self._players.append(player)
                }
            }

            it("Seek") {
                waitUntil(timeout: .seconds(5)) { done in
                    let time: TimeInterval = 3
                    let player = ZonPlayer
                        .player(self._url)
                        .onError(_error) { _, _ in
                            self.__zon_triggerUnexpectedError()
                        }
                        .activate()
                    player.play()
                    player.seek(to: time) { _ in
                        expect { player.currentTime } == time
                        done()
                    }
                    self._players.append(player)
                }
            }

            it("Playback in background") {
                waitUntil(timeout: .seconds(5)) { done in
                    var status = [true, false]
                    let player = ZonPlayer
                        .player(self._url)
                        .onError(_error) { _, _ in
                            self.__zon_triggerUnexpectedError()
                        }
                        .onBackground(_background) { _, payload in
                            expect { status.isEmpty }.to(beFalse())
                            expect { status.removeFirst() } == payload.1
                            if status.isEmpty { done() }
                        }
                        .activate()
                    player.play()
                    player.enableBackgroundPlayback()
                    NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
                    NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
                    player.disableBackgroundPlayback()
                    NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
                    NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
                    self._players.append(player)
                }
            }
        }
    }

    private static var _error = ZonPlayer.Delegate<(ZonPlayable, ZonPlayer.Error), Void>()
    private static var _background = ZonPlayer.Delegate<(ZonPlayable, Bool), Void>()
    private static var _play = ZonPlayer.Delegate<(ZonPlayable, Float), Void>()
    private static var _pause = ZonPlayer.Delegate<ZonPlayable, Void>()
    private static var _rate = ZonPlayer.Delegate<(ZonPlayable, Float, Float), Void>()
    private static var _players: [ZonPlayable] = []
    private static let _url = "https://media-audio1.baydn.com/creeper/listening/33aede75f51823e9f7242cc65d09bc45.8c3bc6434a2d9c9b61f7fe28b519a841.mp3"
}
