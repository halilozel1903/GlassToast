import Observation
import SwiftUI

/// The object you talk to when you want to show a toast.
///
/// Create one per window (usually at the app root), attach it with
/// ``SwiftUICore/View/toastHost(_:edge:)`` and read it anywhere below with
/// `@Environment(ToastCenter.self)`.
@MainActor
@Observable
public final class ToastCenter {
    public private(set) var queue: ToastQueue

    @ObservationIgnored
    private var timers: [Toast.ID: Task<Void, Never>] = [:]

    public init(maxVisible: Int = 3, dropsDuplicates: Bool = true) {
        queue = ToastQueue(maxVisible: maxVisible, dropsDuplicates: dropsDuplicates)
    }

    /// Toasts currently on screen, oldest first.
    public var visibleToasts: [Toast] { queue.visible }

    /// Shows a toast, or queues it if the maximum number is already visible.
    public func show(_ toast: Toast) {
        if queue.enqueue(toast) == .visible {
            scheduleDismissal(of: toast)
        }
    }

    /// Shows a toast built from its parts.
    public func show(
        _ title: String,
        message: String? = nil,
        systemImage: String? = nil,
        style: ToastStyle = .neutral,
        duration: ToastDuration = .short,
        action: ToastAction? = nil
    ) {
        show(Toast(
            title: title,
            message: message,
            systemImage: systemImage,
            style: style,
            duration: duration,
            action: action
        ))
    }

    /// Dismisses a toast before its timer runs out.
    public func dismiss(_ id: Toast.ID) {
        timers.removeValue(forKey: id)?.cancel()
        if let promoted = queue.dismiss(id: id) {
            scheduleDismissal(of: promoted)
        }
    }

    /// Removes every visible and pending toast.
    public func dismissAll() {
        timers.values.forEach { $0.cancel() }
        timers.removeAll()
        queue.removeAll()
    }

    /// Stops the countdown of a visible toast, for example while the user drags it.
    func pauseTimer(for id: Toast.ID) {
        timers.removeValue(forKey: id)?.cancel()
    }

    /// Restarts the countdown of a visible toast.
    func resumeTimer(for id: Toast.ID) {
        guard let toast = queue.visible.first(where: { $0.id == id }) else { return }
        scheduleDismissal(of: toast)
    }

    private func scheduleDismissal(of toast: Toast) {
        guard let seconds = toast.duration.timeInterval else { return }
        timers[toast.id]?.cancel()
        timers[toast.id] = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            self?.timers[toast.id] = nil
            self?.dismiss(toast.id)
        }
    }
}
