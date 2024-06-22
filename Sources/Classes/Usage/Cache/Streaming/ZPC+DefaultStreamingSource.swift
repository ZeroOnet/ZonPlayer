//
//  ZPC+DefaultStreamingSource.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/14.
//

extension ZPC {
    public final class DefaultStreamingSource: ZPCStreamingSourceable {
        public let saveToDisk: Bool
        public var enableConsoleLog: Bool
        public init(
            saveToDisk: Bool = true,
            enableConsoleLog: Bool = ZonPlayer.Manager.shared.enableConsoleLog
        ) {
            self.saveToDisk = saveToDisk
            self.enableConsoleLog = enableConsoleLog
        }

        public var plugins: [ZPCStreamingPluggable] = []

        public func cleanCache(completion: (() -> Void)? = nil) {
            _config.ioQueue.async {
                try? FileManager.default.removeItem(at: self._config.cacheDirectory)
                self._config.prepare()
                completion?()
            }
        }

        public func storage(for url: URL) -> ZPCDataStorable {
            guard saveToDisk else { return DummyDataStorage(url: url) }
            return ZPC.DefaultDataStorage(url: url, config: _config)
        }

        public func provider(for url: URL) -> ZPCStreamingDataProvidable {
            let storage = storage(for: url)
            let plugins = (enableConsoleLog ? [_logPlugin] : []) + self.plugins + [_SaveToDiskPlugin(storage: storage)]
            let requester = DataRequester(url: url, plugins: plugins)
            return DataProvider(storage: storage, requester: requester)
        }

        private lazy var _config: Config = { .config(components: "Streaming") }()

        private let _logPlugin = _LogPlugin()
    }
}

extension ZPC.DefaultStreamingSource {
    private struct _LogPlugin: ZPCStreamingPluggable {
        let logQueue: DispatchQueue
        init(logQueue: DispatchQueue = ZonPlayer.Manager.shared.logQueue) {
            self.logQueue = logQueue
        }

        func willSend(_ request: URLRequest, forRange range: NSRange) {
            _print("✈️ will send request to fetch data with \(range)", url: request.url)
        }

        func didReceive(_ data: Data, forURL url: URL, withRange range: NSRange, fromRemote remoteFlag: Bool) {
            _print("📦 did receive \(data) from \(_source(remoteFlag)) with \(range)", url: url)
        }

        func didReceive(_ metaData: ZPC.MetaData, forURL url: URL, fromRemote remoteFlag: Bool) {
            _print("📢 did receive \(metaData) from \(_source(remoteFlag))", url: url)
        }

        func didComplete(
            _ result: Result<Void,
            ZonPlayer.Error>,
            forURL url: URL,
            withRange range: NSRange,
            fromRemote remoteFlag: Bool
        ) {
            let resultString: String
            switch result {
            case .success:
                resultString = "🎉 did complete"
            case .failure(let error):
                resultString = "💔 failed because of \(error.localizedDescription)"
            }
            _print("\(resultString) from \(_source(remoteFlag)) with \(range)", url: url)
        }

        func anErrorOccurred(in storage: ZPCDataStorable, _ error: ZonPlayer.Error) {
            _print("🚒 There is an error in \(storage) -> \(error.localizedDescription)", url: storage.url)
        }

        private func _print(_ message: String, url: URL?) {
            logQueue.async {
                let string =
"""
ZonPlayer Streaming Cache <<< \(url.unsafelyUnwrapped)
-->>> \(message).
"""
                print(string)
            }
        }

        private func _source(_ remoteFlag: Bool) -> String {
            remoteFlag ? "remote server ☁️" : "local storage 🏠"
        }
    }
}

extension ZPC.DefaultStreamingSource {
    private struct _SaveToDiskPlugin: ZPCStreamingPluggable {
        let storage: ZPCDataStorable

        func didReceive(
            _ data: Data,
            forURL url: URL,
            withRange range: NSRange,
            fromRemote remoteFlag: Bool
        ) {
            guard remoteFlag else { return }
            storage.writeData(data, to: range)
        }

        func didReceive(
            _ metaData: ZPC.MetaData,
            forURL url: URL,
            fromRemote remoteFlag: Bool
        ) {
            guard remoteFlag else { return }
            storage.setMetaData(metaData)
        }
    }
}
