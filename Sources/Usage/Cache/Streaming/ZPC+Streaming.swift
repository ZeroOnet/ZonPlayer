//
//  ZPC+Streaming.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/7.
//

extension ZPC {
    /// Download during playback base on AVAssetResourceLoader.
    public final class Streaming: NSObject {
        public protocol Sourceable {
            var plugins: [Pluggable] { get set }

            func storage(for url: URL) -> DataStorable
            func provider(for url: URL) -> DataProvidable
        }

        public protocol DataProvidable {
            func addLoadingRequest(_ loadingRequest: LoadingRequestable)
            func removeLoadingRequest(_ loadingRequest: LoadingRequestable)
        }

        public protocol Pluggable {
            func prepare(_ request: URLRequest, forRange range: NSRange) -> URLRequest
            func willSend(_ request: URLRequest, forRange range: NSRange)
            func didReceive(_ data: Data, forURL url: URL, withRange range: NSRange, fromRemote remoteFlag: Bool)
            func didReceive(_ metaData: MetaData, forURL url: URL, fromRemote remoteFlag: Bool)
            func didComplete(
                _ result: Result<Void,
                ZonPlayer.Error>,
                forURL url: URL,
                withRange range: NSRange,
                fromRemote remoteFlag: Bool
            )
            func anErrorOccurred(in storage: DataStorable, _ error: ZonPlayer.Error)
        }

        public protocol DataTaskable {
            var range: NSRange { get }
            var loadingRequest: LoadingRequestable { get }

            func requestData(completion: @escaping (Result<Void, ZonPlayer.Error>) -> Void)
        }

        public protocol DataRequestable {
            var url: URL { get }
            var plugins: [Pluggable] { get }

            func dataTask(
                forRange range: NSRange,
                withLoadingRequest loadingRequest: LoadingRequestable
            ) -> DataTaskable
        }

        public protocol DataStorable {
            var url: URL { get }
            var onError: ZonPlayer.Delegate<ZonPlayer.Error, Void> { get }

            func getCacheFragments(completion: @escaping ([NSRange]) -> Void)
            func setMetaData(_ metaData: ZPC.Streaming.MetaData)
            func getMetaData(completion: @escaping (ZPC.Streaming.MetaData?) -> Void)
            func writeData(_ data: Data, to range: NSRange)
            func readData(from range: NSRange, completion: @escaping (Data?) -> Void)
            func clean(completion: (() -> Void)?)
        }

        public let source: Sourceable
        public init(source: Sourceable = DefaultSource()) {
            self.source = source
        }

        private lazy var _delegateQueue: DispatchQueue = {
            .init(label: "com.zonplayer.streaming.delegate")
        }()

        private let _addedSchemePrefix = "ZonPlayer:"
        private var _providerPairs: [URL: DataProvidable] = [:]
    }
}

extension ZPC.Streaming: ZonPlayer.Cacheable {
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

extension ZPC.Streaming.Pluggable {
    public func prepare(_ request: URLRequest, forRange range: NSRange) -> URLRequest { request }
    public func willSend(_ request: URLRequest, forRange range: NSRange) {}
    public func didReceive(_ data: Data, forURL url: URL, withRange range: NSRange, fromRemote remoteFlag: Bool) {}
    public func didReceive(_ metaData: ZPC.Streaming.MetaData, forURL url: URL, fromRemote remoteFlag: Bool) {}
    public func didComplete(
        _ result: Result<Void,
        ZonPlayer.Error>,
        forURL url: URL,
        withRange range: NSRange,
        fromRemote remoteFlag: Bool
    ) {}
    public func anErrorOccurred(in storage: ZPC.Streaming.DataStorable, _ error: ZonPlayer.Error) {}
}

extension ZPC.Streaming.DataStorable {
    public func clean() { clean(completion: nil) }
}
