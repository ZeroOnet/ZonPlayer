//
//  ZPWaitingReason.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public struct ZPWaitingReason {
    let desc: AVPlayer.WaitingReason

    public static let unknown = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingUnknownReason"))
    public static let itemLoading = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingItemLoadingReason"))
    public static let initializing = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingPlayerInitializingReason"))
    public static let session = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingSessionSettingReason"))
    public static let cache = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingCacheReason"))
}

extension ZPWaitingReason: CustomStringConvertible {
    public var description: String { desc.rawValue }
}
