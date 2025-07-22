//
//  ZPC+Streaming+MetaData.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/14.
//

extension ZPC.Streaming {
    public struct MetaData: Codable, Equatable, Sendable {
        public let contentType: String
        public let isByteRangeAccessSupported: Bool
        public let contentLength: Int

        public init(
            contentType: String,
            isByteRangeAccessSupported: Bool,
            contentLength: Int
        ) {
            self.contentType = contentType
            self.isByteRangeAccessSupported = isByteRangeAccessSupported
            self.contentLength = contentLength
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.contentType == rhs.contentType
            && lhs.isByteRangeAccessSupported == rhs.isByteRangeAccessSupported
            && lhs.contentLength == rhs.contentLength
        }
    }
}
