//
//  ZPC+Streaming+Requestable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/21.
//

extension ZPC.Streaming {
    /**
     AVAssetResourceLoadingRequest,
     AVAssetResourceLoadingDataRequest,
     AVAssetResourceLoadingContentInformationRequest
     cannot create a instance, so define a protocol to make unit test available.
     */
    public protocol LoadingRequestable: NSObject {
        var isFinished: Bool { get }
        var theDataRequest: LoadingDataRequestable? { get }
        var theMetaDataRequest: LoadingMetaDataRequestable? { get }

        func finishLoading(with error: Error?)
        func finishLoading()
    }

    public protocol LoadingDataRequestable: NSObject {
        var requestedOffset: Int64 { get }
        var requestedLength: Int { get }
        var currentOffset: Int64 { get }
        var requestsAllDataToEndOfResource: Bool { get }

        func respond(with data: Data)
    }

    public protocol LoadingMetaDataRequestable: NSObject {
        var contentType: String? { get set }
        var contentLength: Int64 { get set }
        var isByteRangeAccessSupported: Bool { get set }
    }
}

extension AVAssetResourceLoadingRequest: ZPC.Streaming.LoadingRequestable {
    public var theDataRequest: ZPC.Streaming.LoadingDataRequestable? { dataRequest }
    public var theMetaDataRequest: ZPC.Streaming.LoadingMetaDataRequestable? { contentInformationRequest }
}

extension AVAssetResourceLoadingDataRequest: ZPC.Streaming.LoadingDataRequestable {}

extension ZPC.Streaming.LoadingMetaDataRequestable {
    public var metaData: ZPC.Streaming.MetaData {
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

extension AVAssetResourceLoadingContentInformationRequest: ZPC.Streaming.LoadingMetaDataRequestable {}
