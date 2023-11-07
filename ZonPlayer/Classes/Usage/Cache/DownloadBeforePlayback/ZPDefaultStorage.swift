//
//  ZPDefaultStorage.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/6.
//

import CommonCrypto

public protocol ZPFileNameConvertible {
    func map(url: URL) -> String
}

public final class ZPDefaultStorage {
    public struct Config {
        public let cacheDirectory: URL
        public let fileName: ZPFileNameConvertible

        public static let `default` = {
            let documentPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true
            )[0]
            let cacheDirectory = URL(fileURLWithPath: documentPath)
                .appendingPathComponent("ZonPlayer")
            return Config(cacheDirectory: cacheDirectory, fileName: MD5BaseOnURL())
        }()

        public init(cacheDirectory: URL, fileName: ZPFileNameConvertible) {
            self.cacheDirectory = cacheDirectory
            self.fileName = fileName
        }

        public struct MD5BaseOnURL: ZPFileNameConvertible {
            public func map(url: URL) -> String {
                // Error Domain=AVFoundationErrorDomain Code=-11828 "Cannot Open"
                // UserInfo=0x167170 {NSLocalizedFailureReason=This media format is not supported.
                // NSLocalizedDescription=Cannot Open}
                // https://stackoverflow.com/questions/9290972/is-it-possible-to-make-avurlasset-work-without-a-file-extension
                return url.absoluteString.__zon_md5 + ".\(url.pathExtension)"
            }
        }
    }

    public let config: Config
    public init(config: Config = .default) {
        self.config = config
        _prepare()
    }

    private lazy var _ioQueue: DispatchQueue = {
        .init(label: "com.zeroonet.player.io")
    }()
}

extension ZPDefaultStorage: ZPFileStorable {
    public func create(file: File, with url: URL, completion: @escaping (Result<File, ZonPlayer.Error>) -> Void) {
        switch fileURL(url: url) {
        case .success(let storeURL):
            _ioQueue.async {
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

    public func read(with url: URL) -> Result<File?, ZonPlayer.Error> {
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

    public func fileURL(url: URL) -> Result<URL, ZonPlayer.Error> {
        let fileName = config.fileName.map(url: url)
        let dir = config.cacheDirectory

        if FileManager.default.fileExists(atPath: dir.path) {
            return .success(dir.appendingPathComponent(fileName, isDirectory: false))
        } else {
            return .failure(.cacheFailed(.createCacheDirectoryFailed(dir)))
        }
    }

    public func delete(with url: URL, completion: (() -> Void)?) {
        guard let existURL = try? fileURL(url: url).get() else { completion?(); return }
        _ioQueue.async {
            try? FileManager.default.removeItem(at: existURL)
            completion?()
        }
    }

    public func deleteAll(completion: (() -> Void)?) {
        let dir = config.cacheDirectory
        _ioQueue.async {
            try? FileManager.default.removeItem(at: dir)
            completion?()
        }
    }
}

extension ZPDefaultStorage {
    private func _prepare() {
        let fileManager = FileManager.default
        let path = config.cacheDirectory.path
        guard !fileManager.fileExists(atPath: path) else { return }
        try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
}

extension String {
    fileprivate var __zon_md5: String {
        guard let messageData = data(using: .utf8) else { return self }

        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBA = messageBytes.baseAddress,
                   let digestBA = digestBytes.bindMemory(to: UInt8.self).baseAddress
                { // swiftlint:disable:this opening_brace
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBA, messageLength, digestBA)
                }
                return 0
            }
        }

        return digestData.map { String(format: "%02hhx", $0) }.joined()

    }
}
