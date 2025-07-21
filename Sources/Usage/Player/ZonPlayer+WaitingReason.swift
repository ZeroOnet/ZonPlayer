//
//  ZonPlayer+WaitingReason.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

extension ZonPlayer {
    public struct WaitingReason: @unchecked Sendable {
        let desc: AVPlayer.WaitingReason

        public static let unknown = Self(desc: .init(rawValue: "ZonPlayerWaitingUnknownReason"))
        public static let itemLoading = Self(desc: .init(rawValue: "ZonPlayerWaitingItemLoadingReason"))
        public static let initializing = Self(desc: .init(rawValue: "ZonPlayerWaitingPlayerInitializingReason"))
        public static let session = Self(desc: .init(rawValue: "ZonPlayerWaitingSessionSettingReason"))
        public static let cache = Self(desc: .init(rawValue: "ZonPlayerWaitingCacheReason"))
    }
}

extension ZonPlayer.WaitingReason: CustomStringConvertible {
    public var description: String { desc.rawValue }
}
