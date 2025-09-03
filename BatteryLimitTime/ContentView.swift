import SwiftUI

struct ContentView: View {
    @StateObject private var estimator = BatteryEstimator()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Text(timeString)
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(statusString)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(40)
        }
    }

    private var timeString: String {
        if let seconds = estimator.remainingTime {
            let hours = Int(seconds) / 3600
            let minutes = Int(seconds.truncatingRemainder(dividingBy: 3600)) / 60
            return String(format: "残り時間: %d時間%d分（参考値）", hours, minutes)
        } else {
            return "計測中..."
        }
    }

    private var statusString: String {
        let levelPercent = Int(estimator.batteryLevel * 100)
        switch estimator.batteryState {
        case .charging, .full:
            return "充電中 \(levelPercent)%"
        case .unplugged, .unknown:
            return "バッテリー \(levelPercent)%"
        @unknown default:
            return "バッテリー \(levelPercent)%"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
