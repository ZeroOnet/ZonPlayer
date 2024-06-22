//
//  ZPCacheable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

public protocol ZPCacheable {
    func prepare(url: URL, completion: @escaping (Result<AVURLAsset, ZonPlayer.Error>) -> Void)
}

public protocol ZPCacheSettable {
    var cache: ZPCacheable? { get nonmutating set }
}

extension ZPCacheSettable {
    public func cache(_ cache: ZPCacheable?) -> Self {
        self.cache = cache
        return self
    }
}
