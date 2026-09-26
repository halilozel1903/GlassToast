import GlassToast
import SwiftUI

@main
struct GlassToastDemoApp: App {
    @State private var toasts = ToastCenter(maxVisible: 3)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .toastHost(toasts, edge: ScreenshotScene.current?.edge ?? .top)
                .task { await ScreenshotScene.current?.play(on: toasts) }
        }
    }
}
