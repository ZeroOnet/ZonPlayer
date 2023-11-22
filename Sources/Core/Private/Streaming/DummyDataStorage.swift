//
//  DummyDataStorage.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/15.
//

struct DummyDataStorage: ZPCDataStorable {
    let url: URL
    let onError = ZPDelegate<ZonPlayer.Error, Void>()

    func getCacheFragments(completion: @escaping ([NSRange]) -> Void) {
        completion([])
    }
    func setMetaData(_ metaData: ZPC.MetaData) {}
    func getMetaData(completion: @escaping (ZPC.MetaData?) -> Void) {
        completion(nil)
    }
    func writeData(_ data: Data, to range: NSRange) {}
    func readData(from range: NSRange, completion: @escaping (Data?) -> Void) {
        completion(nil)
    }
    func save() {}
    func clean(completion: (() -> Void)?) { completion?() }
}
