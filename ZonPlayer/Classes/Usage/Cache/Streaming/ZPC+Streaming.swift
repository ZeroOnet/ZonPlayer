//
//  ZPC+Streaming.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/7.
//

extension ZPC {
    /// Download during playback base on AVAssetResourceLoader.
    public final class Streaming: NSObject {
        public private(set) var isCancelled: Bool = false
        public let source: ZPCStreamingSourceable
        public init(source: ZPCStreamingSourceable = DefaultStreamingSource()) {
            self.source = source
        }

        private lazy var _delegateQueue: DispatchQueue = {
            .init(label: "com.zonplayer.streaming.delegate")
        }()

        private let _addedSchemePrefix = "ZonPlayer:"
        private var _providerPairs: [URL: ZPCStreamingDataProvidable] = [:]
    }
}

extension ZPC.Streaming: ZPCacheable {
    public func prepare(url: URL, completion: @escaping (Result<AVURLAsset, ZonPlayer.Error>) -> Void) {
        if url.isFileURL { completion(.success(AVURLAsset(url: url))); return }
        let modifiedURL = URL(string: _addedSchemePrefix + url.absoluteString) ?? url
        let result = AVURLAsset(url: modifiedURL)
        result.resourceLoader.setDelegate(self, queue: _delegateQueue)
        completion(.success(result))
    }
}

extension ZPC.Streaming: AVAssetResourceLoaderDelegate {
    public func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard
            let url = loadingRequest.request.url,
            url.absoluteString.hasPrefix(_addedSchemePrefix) == true
        else { return false }

        var aProvider = _providerPairs[url]
        if aProvider == nil {
            let original = url.absoluteString.replacingOccurrences(of: _addedSchemePrefix, with: "")
            guard let originalURL = URL(string: original) else { return false }
            let provider = source.provider(for: originalURL)
            _providerPairs[url] = provider
            aProvider = provider
        }
        aProvider?.addLoadingRequest(loadingRequest)
        return true
    }

    public func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        didCancel loadingRequest: AVAssetResourceLoadingRequest
    ) {
        guard let url = loadingRequest.request.url else { return }
        _providerPairs[url]?.removeLoadingRequest(loadingRequest)
    }
}
