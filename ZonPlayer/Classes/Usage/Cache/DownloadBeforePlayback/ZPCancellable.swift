//
//  ZPCancellable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

public protocol ZPCancellable {
    var isCancelled: Bool { get }

    /// Cancel an in-process operation.
    func cancel()
}
