//
//  InvalidInitializationTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

final class InvalidInitializationTests: QuickSpec {
    override func spec() {
        describe("Test player initialization") {
            it("Invalid url") {
                waitUntil { done in
                    let invalidURL = ""
                    let player = ZonPlayer
                        .player(invalidURL)
                        .onError(self) { wlf, payload in
                            guard case .invalidURL = payload.1 else {
                                wlf.__zon_triggerUnexpectedError()
                                return
                            }
                            done()
                        }
                        .activate()
                    self._players.append(player)
                }
            }

            it("Invalid audio session") {
                waitUntil(timeout: .seconds(5)) { done in
                    struct InvalidSession: ZonPlayer.Sessionable {
                        func apply() throws {
                            throw NSError(domain: "com.zonplayer.error", code: 10101)
                        }
                    }

                    let player = ZonPlayer
                        .player(self._url)
                        .session(InvalidSession())
                        .onError(self) { wlf, payload in
                            guard case .sessionError = payload.1 else {
                                self.__zon_triggerUnexpectedError()
                                return
                            }
                            done()
                        }
                        .activate()
                    self._players.append(player)
                }
            }

            it("Invalid cache") {
                waitUntil(timeout: .seconds(5)) { done in
                    struct InvalidCache: ZonPlayer.Cacheable {
                        func prepare(url: URL, completion: @escaping (Result<AVURLAsset, ZonPlayer.Error>) -> Void) {
                            completion(.failure(.cacheFailed(.downloadFailed(url, NSError(domain: "com.zonplayer.error", code: 113939)))))
                        }
                    }

                    let player = ZonPlayer
                        .player(self._url)
                        .cache(InvalidCache())
                        .onError(self) { wlf, payload in
                            guard case .cacheFailed(.downloadFailed) = payload.1 else {
                                wlf.__zon_triggerUnexpectedError()
                                return
                            }
                            done()
                        }
                        .activate()
                    self._players.append(player)
                }
            }
        }
    }

    private var _players: [ZonPlayable] = []
    private let _url = "https://media-audio1.baydn.com/creeper/listening/33aede75f51823e9f7242cc65d09bc45.8c3bc6434a2d9c9b61f7fe28b519a841.mp3"
}
