import SwiftUI

struct ContentView: View {
    @EnvironmentObject var batteryManager: BatteryManager

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Text(batteryManager.remainingTimeString)
                    .font(.system(size: 36, weight: .semibold, design: .default))
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
            }
            .padding()
        }
        .onAppear {
            batteryManager.startMonitoring()
        }
    }
}

#Preview {
    ContentView().environmentObject(BatteryManager())
}
