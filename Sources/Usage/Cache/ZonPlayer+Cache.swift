//
//  ZonPlayer+Cache.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/8.
//

public typealias ZPC = ZonPlayer.Cache

extension ZonPlayer {
    public enum Cache {}

    public protocol Cacheable {
        func prepare(url: URL, completion: @escaping (Result<AVURLAsset, ZonPlayer.Error>) -> Void)
    }

    public protocol CacheSettable {
        var cache: Cacheable? { get nonmutating set }
    }
}

extension ZonPlayer.CacheSettable {
    public func cache(_ cache: ZonPlayer.Cacheable?) -> Self {
        self.cache = cache
        return self
    }
}
