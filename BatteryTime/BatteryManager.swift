import SwiftUI
import Combine

final class BatteryManager: ObservableObject {
    @Published var remainingTimeString: String = "残り時間: 計算中..."

    private var cancellables = Set<AnyCancellable>()
    private var lastLevel: Float?
    private var lastDate: Date?
    private var history: [TimeInterval] = []

    func startMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        update()
        NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification))
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &cancellables)
    }

    private func update() {
        let device = UIDevice.current
        let level = device.batteryLevel
        let state = device.batteryState
        let now = Date()

        guard state == .unplugged else {
            remainingTimeString = "充電中"
            lastLevel = level
            lastDate = now
            return
        }

        if let lastLevel = lastLevel, let lastDate = lastDate {
            let deltaLevel = lastLevel - level
            let deltaTime = now.timeIntervalSince(lastDate)
            if deltaLevel > 0 {
                let perPercent = deltaTime / Double(deltaLevel * 100)
                history.append(perPercent)
                history = Array(history.suffix(5))
            }
        }
        lastLevel = level
        lastDate = now

        let average = history.average
        let remainingPercent = max(level, 0) * 100
        let secondsRemaining = average * Double(remainingPercent)
        remainingTimeString = format(seconds: secondsRemaining)
    }

    private func format(seconds: Double) -> String {
        guard seconds.isFinite && seconds > 0 else {
            return "残り時間: 解析中（参考値）"
        }
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds.truncatingRemainder(dividingBy: 3600)) / 60
        return String(format: "残り時間: %d時間%d分（参考値）", hours, minutes)
    }
}

private extension Array where Element == TimeInterval {
    var average: TimeInterval {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
