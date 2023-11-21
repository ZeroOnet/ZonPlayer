//
//  ZPCDataStorable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/8.
//

public protocol ZPCDataStorable {
    var url: URL { get }
    var onError: ZPDelegate<ZonPlayer.Error, Void> { get }

    func getCacheFragments(completion: @escaping ([NSRange]) -> Void)
    func setMetaData(_ metaData: ZPC.MetaData)
    func getMetaData(completion: @escaping (ZPC.MetaData?) -> Void)
    func writeData(_ data: Data, to range: NSRange)
    func readData(from range: NSRange, completion: @escaping (Data?) -> Void)
    func clean(completion: (() -> Void)?)
}

extension ZPCDataStorable {
    public func clean() { clean(completion: nil) }
}
