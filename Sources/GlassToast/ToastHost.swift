import SwiftUI

public extension View {
    /// Presents the toasts of `center` on top of this view and injects the
    /// center into the environment.
    ///
    /// ```swift
    /// @State private var toasts = ToastCenter()
    ///
    /// var body: some Scene {
    ///     WindowGroup {
    ///         ContentView()
    ///             .toastHost(toasts)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - center: The center that owns the toasts.
    ///   - edge: Where toasts slide in from.
    func toastHost(_ center: ToastCenter, edge: VerticalEdge = .top) -> some View {
        modifier(ToastHostModifier(center: center, edge: edge))
    }
}

struct ToastHostModifier: ViewModifier {
    let center: ToastCenter
    let edge: VerticalEdge

    func body(content: Content) -> some View {
        content
            .overlay(alignment: edge == .top ? .top : .bottom) {
                ToastStack(center: center, edge: edge)
            }
            .environment(center)
    }
}

struct ToastStack: View {
    let center: ToastCenter
    let edge: VerticalEdge

    private var toasts: [Toast] {
        // The newest toast sits closest to the edge it slides in from.
        edge == .top ? center.visibleToasts.reversed() : center.visibleToasts
    }

    private var transitionEdge: Edge {
        edge == .top ? .top : .bottom
    }

    var body: some View {
        GlassContainer(spacing: 10) {
            VStack(spacing: 10) {
                ForEach(toasts) { toast in
                    ToastView(
                        toast: toast,
                        edge: edge,
                        onDismiss: { center.dismiss(toast.id) },
                        onDragChanged: { isDragging in
                            if isDragging {
                                center.pauseTimer(for: toast.id)
                            } else {
                                center.resumeTimer(for: toast.id)
                            }
                        }
                    )
                    .transition(
                        .move(edge: transitionEdge)
                            .combined(with: .opacity)
                            .combined(with: .scale(scale: 0.9))
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(edge == .top ? .top : .bottom, 8)
        .animation(.spring(duration: 0.45, bounce: 0.3), value: center.visibleToasts.map(\.id))
        .sensoryFeedback(trigger: center.visibleToasts.last?.id) { _, newValue in
            guard let newValue,
                  let toast = center.visibleToasts.first(where: { $0.id == newValue })
            else { return nil }
            return toast.style.feedback
        }
    }
}

/// Groups the toasts so their Liquid Glass shapes blend into each other on iOS 26.
struct GlassContainer<Content: View>: View {
    var spacing: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
    }
}

extension ToastStyle {
    var feedback: SensoryFeedback {
        switch self {
        case .success: .success
        case .warning: .warning
        case .error: .error
        case .neutral, .info, .custom: .impact(weight: .light)
        }
    }
}
