//
//  ZPCDataRequestable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/17.
//

public protocol ZPCDataTaskable {
    var range: NSRange { get }
    var loadingRequest: ZPCLoadingRequestable { get }

    func requestData(completion: @escaping (Result<Void, ZonPlayer.Error>) -> Void)
}

public protocol ZPCDataRequestable {
    var url: URL { get }
    var plugins: [ZPCStreamingPluggable] { get }

    func dataTask(forRange range: NSRange, withLoadingRequest loadingRequest: ZPCLoadingRequestable) -> ZPCDataTaskable
}
