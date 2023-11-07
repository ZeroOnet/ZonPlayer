//
//  ZonPlayer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public enum ZonPlayer {
    public static func player(_ url: URLConvertible) -> ZPSettable {
        Builder(url: url)
    }
}
