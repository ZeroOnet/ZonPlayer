//
//  ZPC+Config.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/8.
//

import CryptoKit

public protocol ZPCFileNameConvertible {
    /// Convert url to file name.
    ///
    /// - Important: File name must contain valid extension to help player playback, eg: .mp3, .mp4. 
    /// ZPC.Config treated url path extension as file extension by default.
    func map(url: URL) -> String
}

extension ZPC {
    public struct Config {
        public let cacheDirectory: URL
        public let fileName: ZPCFileNameConvertible
        public let ioQueue: DispatchQueue
        public init(
            cacheDirectory: URL,
            fileName: ZPCFileNameConvertible,
            ioQueue: DispatchQueue
        ) {
            self.cacheDirectory = cacheDirectory
            self.fileName = fileName
            self.ioQueue = ioQueue
        }

        /// Create a config.
        /// - cacheDirectory: documentDir/ZonPlayer/components.
        /// - fileName: a instance of FileNameSHA256BaseOnURL.
        public static func config(components: String) -> Config {
            let documentPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true
            )[0]
            let cacheDirectory = URL(fileURLWithPath: documentPath)
                .appendingPathComponent("ZonPlayer/\(components)", isDirectory: true)
            let ioQueue = DispatchQueue(label: "com.zonplayer.io")
            let result = Config(
                cacheDirectory: cacheDirectory,
                fileName: ZPC.FileNameSHA256BaseOnURL(),
                ioQueue: ioQueue
            )
            result.prepare()
            return result
        }

        /// Create cache directory if needed.
        public func prepare() {
            let path = cacheDirectory.path
            let fileManager = FileManager.default
            guard !fileManager.fileExists(atPath: path) else { return }
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }

        public func fileURL(with url: URL) -> URL {
            // Error Domain=AVFoundationErrorDomain Code=-11828 "Cannot Open"
            // UserInfo=0x167170 {NSLocalizedFailureReason=This media format is not supported.
            // NSLocalizedDescription=Cannot Open}
            // https://stackoverflow.com/questions/9290972/is-it-possible-to-make-avurlasset-work-without-a-file-extension
            let fileName = self.fileName.map(url: url) + ".\(url.pathExtension)"
            return cacheDirectory.appendingPathComponent(fileName, isDirectory: false)
        }

        public func recordURL(with url: URL) -> URL {
            let fileName = self.fileName.map(url: url) + ".zprecord"
            return cacheDirectory.appendingPathComponent(fileName, isDirectory: false)
        }
    }

    public struct FileNameSHA256BaseOnURL: ZPCFileNameConvertible {
        public init() {}

        public func map(url: URL) -> String {
            url.absoluteString.__zon_sha256
        }
    }
}

extension String {
    fileprivate var __zon_sha256: String {
        guard let data = data(using: .utf8) else { return self }
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
