import GlassToast
import SwiftUI

/// Scenes used by CI to capture the README screenshots.
/// Launch with `-screenshot <scene>`; normal launches are unaffected.
enum ScreenshotScene: String {
    case stack
    case bottom

    static var current: ScreenshotScene? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-screenshot"), arguments.indices.contains(index + 1) else {
            return nil
        }
        return ScreenshotScene(rawValue: arguments[index + 1])
    }

    var edge: VerticalEdge { self == .bottom ? .bottom : .top }

    @MainActor
    func play(on toasts: ToastCenter) async {
        try? await Task.sleep(for: .milliseconds(600))
        switch self {
        case .stack:
            toasts.show(Toast(title: "You're offline", message: "Changes will sync later.", systemImage: "wifi.slash", style: .warning, duration: .indefinite))
            try? await Task.sleep(for: .milliseconds(250))
            toasts.show(Toast(title: "Message archived", systemImage: "archivebox.fill", style: .info, duration: .indefinite, action: ToastAction("Undo") {}))
            try? await Task.sleep(for: .milliseconds(250))
            toasts.show(Toast(title: "Photo saved", message: "Added to your library.", style: .success, duration: .indefinite))
        case .bottom:
            toasts.show(Toast(title: "Upload failed", message: "Check your connection and try again.", style: .error, duration: .indefinite, action: ToastAction("Retry") {}))
            try? await Task.sleep(for: .milliseconds(250))
            toasts.show(Toast(title: "Added to favorites", style: .custom(tint: .pink, systemImage: "heart.fill"), duration: .indefinite))
        }
    }
}
