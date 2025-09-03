import Foundation
import Combine
import SwiftUI

final class BatteryEstimator: ObservableObject {
    @Published var batteryLevel: Float = UIDevice.current.batteryLevel
    @Published var batteryState: UIDevice.BatteryState = UIDevice.current.batteryState
    @Published var remainingTime: TimeInterval?

    private var lastRecord: (date: Date, level: Float)?
    private var avgSecondsPerPercent: TimeInterval = 0
    private var sampleCount: Int = 0

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
        lastRecord = (Date(), batteryLevel)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(batteryLevelChanged),
                                               name: UIDevice.batteryLevelDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(batteryStateChanged),
                                               name: UIDevice.batteryStateDidChangeNotification,
                                               object: nil)
    }

    @objc private func batteryLevelChanged() {
        let level = UIDevice.current.batteryLevel
        let now = Date()

        if batteryState == .unplugged || batteryState == .unknown {
            if let last = lastRecord, level < last.level {
                let deltaLevel = last.level - level
                let deltaTime = now.timeIntervalSince(last.date)
                let timePerPercent = deltaTime / Double(deltaLevel * 100)
                avgSecondsPerPercent = ((avgSecondsPerPercent * Double(sampleCount)) + timePerPercent) / Double(sampleCount + 1)
                sampleCount += 1
            }
        }

        lastRecord = (now, level)
        batteryLevel = level
        updateRemaining()
    }

    @objc private func batteryStateChanged() {
        batteryState = UIDevice.current.batteryState
        updateRemaining()
    }

    private func updateRemaining() {
        guard batteryState == .unplugged || batteryState == .unknown else {
            remainingTime = nil
            return
        }
        let remainingPercent = max(batteryLevel, 0) * 100
        remainingTime = avgSecondsPerPercent * Double(remainingPercent)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
