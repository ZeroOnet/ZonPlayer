//
//  Utils.swift
//  Tests
//
//  Created by 李文康 on 2023/11/20.
//  Copyright © 2023 Shanbay iOS. All rights reserved.
//

@_exported import XCTest
@_exported import ZonPlayer
@_exported import Nimble
@_exported import Quick

extension XCTestCase {
    func __zon_triggerUnexpectedError() {
        XCTFail("Unexpected error occurred.")
    }
}

class LoadingRequest: NSObject, ZPCLoadingRequestable {
    var isFinished: Bool = false

    var theDataRequest: ZPCLoadingDataRequestable?
    var theMetaDataRequest: ZPCLoadingMetaDataRequestable? = LoadingMetaDataRequest()

    func finishLoading(with error: Error?) { isFinished = true }

    func finishLoading() { isFinished = true }
}

class LoadingDataRequest: NSObject, ZPCLoadingDataRequestable {
    var requestedOffset: Int64 = 0
    var requestedLength: Int = 0
    var currentOffset: Int64 = 0
    var requestsAllDataToEndOfResource = false
    var data = Data()

    func respond(with data: Data) {
        self.data.append(data)
    }
}

class LoadingMetaDataRequest: NSObject, ZPCLoadingMetaDataRequestable {
    var contentLength: Int64 = 0
    var contentType: String?
    var isByteRangeAccessSupported = false
}
