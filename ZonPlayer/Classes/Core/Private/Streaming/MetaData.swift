//
//  MetaData.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/8.
//

struct MetaData: Codable {
    let contentType: String
    let byteRangeAccessSupported: Bool
    let contentLength: UInt
    let downloadedContentLength: UInt
}
