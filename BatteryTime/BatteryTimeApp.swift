import SwiftUI

@main
struct BatteryTimeApp: App {
    @StateObject private var batteryManager = BatteryManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(batteryManager)
        }
    }
}
