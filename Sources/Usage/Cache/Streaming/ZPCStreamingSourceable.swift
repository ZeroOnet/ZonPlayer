//
//  ZPCStreamingSourceable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/14.
//

public protocol ZPCStreamingSourceable {
    var plugins: [ZPCStreamingPluggable] { get set }

    func storage(for url: URL) -> ZPCDataStorable
    func provider(for url: URL) -> ZPCStreamingDataProvidable
}
