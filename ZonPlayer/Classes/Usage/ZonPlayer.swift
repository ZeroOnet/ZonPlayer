//
//  ZonPlayer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

// TODO: -
// 1. 自实现下载器
// 2. 边下边播 ResourceLoader 实现

public enum ZonPlayer {
    public static func player(_ url: URLConvertible) -> ZPSettable {
        Builder(url: url)
    }
}
