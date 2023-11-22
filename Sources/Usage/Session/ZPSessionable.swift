//
//  ZPSessionable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public protocol ZPSessionable {
    func apply() throws
}

public protocol ZPSessionSettable {
    var session: ZPSessionable? { get nonmutating set }
}

extension ZPSessionSettable {
    public func session(_ session: ZPSessionable?) -> Self {
        self.session = session
        return self
    }
}
