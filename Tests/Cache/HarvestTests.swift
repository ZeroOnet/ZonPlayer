//
//  HarvestTests.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

final class HarvestTests: QuickSpec {
    override static func spec() {
        describe("Test download then play") {
            it("Downloaded file") {
                waitUntil(timeout: .seconds(20)) { done in
                    let url = URL(string: "https://media-audio1.baydn.com/creeper/listening/33aede75f51823e9f7242cc65d09bc45.8c3bc6434a2d9c9b61f7fe28b519a841.mp3").unsafelyUnwrapped
                    self._cache.prepare(url: url) { result in
                        guard let asset = try? result.get() else { return }
                        expect { FileManager.default.fileExists(atPath: asset.url.path) }.to(beTrue())
                        try? FileManager.default.removeItem(at: asset.url)
                        done()
                    }
                }
            }
        }
    }

    private static let _cache = ZPC.Harvest()
}
