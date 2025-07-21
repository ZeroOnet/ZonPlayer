//
//  DummyDataStorage.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/15.
//

struct DummyDataStorage: ZPC.Streaming.DataStorable {
    let url: URL
    let onError = ZonPlayer.Delegate<ZonPlayer.Error, Void>()

    func getCacheFragments(completion: @escaping ([NSRange]) -> Void) {
        completion([])
    }
    func setMetaData(_ metaData: ZPC.Streaming.MetaData) {}
    func getMetaData(completion: @escaping (ZPC.Streaming.MetaData?) -> Void) {
        completion(nil)
    }
    func writeData(_ data: Data, to range: NSRange) {}
    func readData(from range: NSRange, completion: @escaping (Data?) -> Void) {
        completion(nil)
    }
    func save() {}
    func clean(completion: (() -> Void)?) { completion?() }
}
