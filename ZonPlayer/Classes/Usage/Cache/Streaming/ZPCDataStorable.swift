//
//  ZPCDataStorable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/8.
//

public protocol ZPCDataStorable {
    func write(data: Data, with range: Range<Int>)
    func readData(with range: Range<Int>) -> Data
    func deleteAll(completion: (() -> Void)?)
}

extension ZPCDataStorable {
    public func deleteAll() { deleteAll(completion: nil) }
}
