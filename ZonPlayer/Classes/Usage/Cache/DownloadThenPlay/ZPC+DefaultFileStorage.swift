//
//  ZPC+DefaultFileStorage.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/6.
//

extension ZPC {
    public final class DefaultFileStorage {
        public let config: Config
        public init(config: Config = .config(components: "DownloadThenPlay")) {
            self.config = config
        }
    }
}

extension ZPC.DefaultFileStorage: ZPFileStorable {
    public func create(file: File, with url: RemoteURL, completion: @escaping (Result<File, ZonPlayer.Error>) -> Void) {
        switch fileURL(url: url) {
        case .success(let storeURL):
            config.ioQueue.async {
                do {
                    if FileManager.default.fileExists(atPath: storeURL.path) {
                        try FileManager.default.removeItem(at: storeURL)
                    }
                    try FileManager.default.moveItem(at: file.location, to: storeURL)
                    completion(.success(File(location: storeURL)))
                } catch {
                    completion(.failure(.cacheFailed(.fileStoreFailed(storeURL, error))))
                }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    public func read(with url: RemoteURL) -> Result<File?, ZonPlayer.Error> {
        switch fileURL(url: url) {
        case .success(let fileURL):
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return .success(File(location: fileURL))
            } else {
                return .success(nil)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    public func fileURL(url: RemoteURL) -> Result<FileURL, ZonPlayer.Error> {
        let fileURL = config.fileURL(with: url)
        let dir = config.cacheDirectory

        if FileManager.default.fileExists(atPath: dir.path) {
            return .success(fileURL)
        } else {
            return .failure(.cacheFailed(.createCacheDirectoryFailed(dir)))
        }
    }

    public func delete(with url: RemoteURL, completion: (() -> Void)?) {
        guard let existURL = try? fileURL(url: url).get() else { completion?(); return }
        config.ioQueue.async {
            try? FileManager.default.removeItem(at: existURL)
            completion?()
        }
    }

    public func deleteAll(completion: (() -> Void)?) {
        let dir = config.cacheDirectory
        config.ioQueue.async {
            try? FileManager.default.removeItem(at: dir)
            completion?()
        }
    }
}
