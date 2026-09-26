import GlassToast
import SwiftUI

struct ContentView: View {
    @Environment(ToastCenter.self) private var toasts
    @State private var favorites = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Styles") {
                    Button("Info") {
                        toasts.show(.info("New version available", message: "Pull to refresh to update."))
                    }
                    Button("Success") {
                        toasts.show(.success("Photo saved", message: "Added to your library."))
                    }
                    Button("Warning") {
                        toasts.show(.warning("Low storage", message: "Only 1.2 GB left on this device."))
                    }
                    Button("Error") {
                        toasts.show(.error("Upload failed", message: "Check your connection and try again."))
                    }
                    Button("Custom") {
                        toasts.show(
                            "Added to favorites",
                            style: .custom(tint: .pink, systemImage: "heart.fill")
                        )
                    }
                }

                Section("Behavior") {
                    Button("With Undo action") {
                        favorites += 1
                        toasts.show(Toast(
                            title: "Message archived",
                            systemImage: "archivebox.fill",
                            style: .info,
                            duration: .long,
                            action: ToastAction("Undo") { favorites -= 1 }
                        ))
                    }
                    Button("Sticky (swipe to dismiss)") {
                        toasts.show(Toast(
                            title: "You're offline",
                            message: "Swipe up to dismiss.",
                            systemImage: "wifi.slash",
                            style: .warning,
                            duration: .indefinite
                        ))
                    }
                    Button("Burst of 6 (queueing)") {
                        for index in 1...6 {
                            toasts.show(.info("Notification \(index)"))
                        }
                    }
                    Button("Dismiss all", role: .destructive) {
                        toasts.dismissAll()
                    }
                }

                Section {
                    LabeledContent("Archived messages", value: "\(favorites)")
                }
            }
            .navigationTitle("GlassToast")
        }
    }
}

#Preview {
    ContentView()
        .toastHost(ToastCenter())
}
