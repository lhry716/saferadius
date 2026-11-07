import SwiftUI

@main
struct SafeRadiusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(SafePalette.green)
                .preferredColorScheme(.light)
        }
    }
}
