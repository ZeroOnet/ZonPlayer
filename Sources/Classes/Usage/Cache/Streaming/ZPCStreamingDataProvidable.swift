//
//  ZPCStreamingDataProvidable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/14.
//

public protocol ZPCStreamingDataProvidable {
    func addLoadingRequest(_ loadingRequest: ZPCLoadingRequestable)
    func removeLoadingRequest(_ loadingRequest: ZPCLoadingRequestable)
}
