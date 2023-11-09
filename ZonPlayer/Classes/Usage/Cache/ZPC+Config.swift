//
//  ZPC+Config.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/8.
//

import CommonCrypto

public protocol ZPCFileNameConvertible {
    /// Convert url to file name.
    ///
    /// - Important: File name must contain valid extension to help player playback, eg: .mp3, .mp4.
    func map(url: URL) -> String
}

extension ZPC {
    public struct Config {
        public let cacheDirectory: URL
        public let fileName: ZPCFileNameConvertible

        public static let `default` = {
            let documentPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true
            )[0]
            let cacheDirectory = URL(fileURLWithPath: documentPath)
                .appendingPathComponent("ZonPlayer")
            return Config(cacheDirectory: cacheDirectory, fileName: ZPC.FileNameMD5BaseOnURL())
        }()

        public init(cacheDirectory: URL, fileName: ZPCFileNameConvertible) {
            self.cacheDirectory = cacheDirectory
            self.fileName = fileName
        }
    }

    public struct FileNameMD5BaseOnURL: ZPCFileNameConvertible {
        public func map(url: URL) -> String {
            // Error Domain=AVFoundationErrorDomain Code=-11828 "Cannot Open"
            // UserInfo=0x167170 {NSLocalizedFailureReason=This media format is not supported.
            // NSLocalizedDescription=Cannot Open}
            // https://stackoverflow.com/questions/9290972/is-it-possible-to-make-avurlasset-work-without-a-file-extension
            return url.absoluteString.__zon_md5 + ".\(url.pathExtension)"
        }
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
                   let digestBA = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBA, messageLength, digestBA)
                }
                return 0
            }
        }

        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
