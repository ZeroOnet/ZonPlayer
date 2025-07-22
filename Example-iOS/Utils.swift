//
//  Utils.swift
//  Example-iOS
//
//  Created by 李文康 on 2025/7/18.
//  Copyright © 2025 Shanbay iOS. All rights reserved.
//

func timeString(value: TimeInterval) -> String {
    let intValue = Int(value)
    let hours = intValue / 3600
    let hoursInSeconds = hours * 3600
    let minutes = (intValue - hoursInSeconds) / 60
    let seconds = intValue - hoursInSeconds - minutes * 60
    let format = "%02i:"

    return (hours != 0 ? String(format: format, hours) : "")
        + (minutes != 0 ? String(format: format, minutes) : "")
        + String(format: "%02i", seconds)
}

