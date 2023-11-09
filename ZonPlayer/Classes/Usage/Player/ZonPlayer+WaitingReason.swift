//
//  ZonPlayer+WaitingReason.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public typealias ZPWaitingReason = ZonPlayer.WaitingReason

extension ZonPlayer {
    public struct WaitingReason {
        let desc: AVPlayer.WaitingReason

        public static let unknown = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingUnknownReason"))
        public static let itemLoading = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingItemLoadingReason"))
        public static let initializing = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingPlayerInitializingReason"))
        public static let session = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingSessionSettingReason"))
        public static let cache = ZPWaitingReason(desc: .init(rawValue: "ZonPlayerWaitingCacheReason"))
    }
}

extension ZonPlayer.WaitingReason: CustomStringConvertible {
    public var description: String { desc.rawValue }
}
