//
//  ZPCLoadingRequestable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/21.
//

/**
 AVAssetResourceLoadingRequest,
 AVAssetResourceLoadingDataRequest,
 AVAssetResourceLoadingContentInformationRequest
 cannot create a instance, so define a protocol to make unit test available.
 */
public protocol ZPCLoadingRequestable: NSObject {
    var isFinished: Bool { get }
    var theDataRequest: ZPCLoadingDataRequestable? { get }
    var theMetaDataRequest: ZPCLoadingMetaDataRequestable? { get }

    func finishLoading(with error: Error?)
    func finishLoading()
}

extension AVAssetResourceLoadingRequest: ZPCLoadingRequestable {
    public var theDataRequest: ZPCLoadingDataRequestable? { dataRequest }
    public var theMetaDataRequest: ZPCLoadingMetaDataRequestable? { contentInformationRequest }
}

public protocol ZPCLoadingDataRequestable: NSObject {
    var requestedOffset: Int64 { get }
    var requestedLength: Int { get }
    var currentOffset: Int64 { get }
    var requestsAllDataToEndOfResource: Bool { get }

    func respond(with data: Data)
}

extension AVAssetResourceLoadingDataRequest: ZPCLoadingDataRequestable {}

public protocol ZPCLoadingMetaDataRequestable: NSObject {
    var contentType: String? { get set }
    var contentLength: Int64 { get set }
    var isByteRangeAccessSupported: Bool { get set }
}

extension ZPCLoadingMetaDataRequestable {
    public var metaData: ZPC.MetaData {
        get {
            .init(
                contentType: contentType ?? "",
                isByteRangeAccessSupported: isByteRangeAccessSupported,
                contentLength: Int(contentLength)
            )
        }

        set {
            contentType = newValue.contentType
            contentLength = Int64(newValue.contentLength)
            isByteRangeAccessSupported = newValue.isByteRangeAccessSupported
        }
    }
}

extension AVAssetResourceLoadingContentInformationRequest: ZPCLoadingMetaDataRequestable {}
