//
//  RetryTests.swift
//  Tests
//
//  Created by 李文康 on 2025/7/22.
//  Copyright © 2025 Shanbay iOS. All rights reserved.
//

final class RetryTests: QuickSpec {
    override class func spec() {
        describe("Test player retry") {
            it("Step Retry") {
                waitUntil(timeout: .seconds(10)) { done in
                    let retry = ZonPlayer.StepRetry(maxRetryCount: 3, interval: 1) { url -> URL? in
                        expect { url.absoluteString == _urls.first }.to(beTrue())
                        _urls.removeFirst()
                        if _urls.count == 1 { done() }
                        return URL(string: _urls.first ?? "")

                    }
                    _player = ZonPlayer
                        .player(_urls.first ?? "")
                        .retry(retry)
                        .activate()
                    _player?.play()
                }
            }
        }
    }

    private static var _player: ZonPlayable?
    private static var _urls = [
        "https://abc",
        "https://def",
        "https://ghi",
        "https://jkl",
    ]
}
