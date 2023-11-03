//
//  ZonPlayer.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

// TODO: -
// 1. 自实现下载器
// 2. 边下边播 ResourceLoader 实现
// 3. 远程控制命令的扩展，支持所有系统现在以及未来命令，封面如何处理。（如果下载图片，会涉及缓存问题）
// 4. Log Monitor 设计。

public enum ZonPlayer {
    public static func player(_ url: URLConvertible) -> ZPSettable {
        Builder(url: url)
    }
}
