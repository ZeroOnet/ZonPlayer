//
//  ZPC+Streaming.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/7.
//

extension ZPC {
    /// Download during playback base on AVAssetResourceLoader.
    public final class Streaming: NSObject, ZPCacheable {
        public func prepare(url: URL, completion: @escaping (Result<AVURLAsset, ZonPlayer.Error>) -> Void) {
            if url.isFileURL { completion(.success(AVURLAsset(url: url))); return }
            let modifiedURL = URL(string: _addedSchemePrefix + url.absoluteString) ?? url
            completion(.success(AVURLAsset(url: modifiedURL)))
        }

        private lazy var _delegateQueue: DispatchQueue = {
            .init(label: "com.zeroonet.player.streaming.delegate", qos: .userInitiated)
        }()

        private let _addedSchemePrefix = "ZonPlayer:"
    }
}

extension ZPC.Streaming: AVAssetResourceLoaderDelegate {
    public func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard
            let url = loadingRequest.request.url,
            url.scheme?.hasPrefix(_addedSchemePrefix) == true
        else { return false }

        return true
    }

    public func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        didCancel loadingRequest: AVAssetResourceLoadingRequest
    ) {

    }
}
