import SwiftUI

/// A single toast notification.
///
/// Toasts are value types: create one, hand it to a ``ToastCenter`` and the
/// center takes care of queueing, presenting and dismissing it.
public struct Toast: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var message: String?
    public var systemImage: String?
    public var style: ToastStyle
    public var duration: ToastDuration
    public var action: ToastAction?

    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        systemImage: String? = nil,
        style: ToastStyle = .neutral,
        duration: ToastDuration = .short,
        action: ToastAction? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.style = style
        self.duration = duration
        self.action = action
    }

    /// The SF Symbol shown next to the title, if any.
    public var resolvedSystemImage: String? {
        systemImage ?? style.defaultSystemImage
    }

    /// Two toasts are considered duplicates when they would look identical on screen.
    func isDuplicate(of other: Toast) -> Bool {
        title == other.title && message == other.message && style == other.style
    }
}

// MARK: - Convenience factories

public extension Toast {
    static func info(_ title: String, message: String? = nil, duration: ToastDuration = .short) -> Toast {
        Toast(title: title, message: message, style: .info, duration: duration)
    }

    static func success(_ title: String, message: String? = nil, duration: ToastDuration = .short) -> Toast {
        Toast(title: title, message: message, style: .success, duration: duration)
    }

    static func warning(_ title: String, message: String? = nil, duration: ToastDuration = .long) -> Toast {
        Toast(title: title, message: message, style: .warning, duration: duration)
    }

    static func error(_ title: String, message: String? = nil, duration: ToastDuration = .long) -> Toast {
        Toast(title: title, message: message, style: .error, duration: duration)
    }
}

// MARK: - Style

/// The semantic style of a toast. Drives the tint and the default icon.
public enum ToastStyle: Sendable, Hashable {
    case neutral
    case info
    case success
    case warning
    case error
    case custom(tint: Color, systemImage: String?)

    public var tint: Color {
        switch self {
        case .neutral: .primary
        case .info: .blue
        case .success: .green
        case .warning: .orange
        case .error: .red
        case let .custom(tint, _): tint
        }
    }

    public var defaultSystemImage: String? {
        switch self {
        case .neutral: nil
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        case let .custom(_, systemImage): systemImage
        }
    }
}

// MARK: - Duration

/// How long a toast stays on screen before it dismisses itself.
public enum ToastDuration: Sendable, Hashable {
    /// 2.5 seconds.
    case short
    /// 4.5 seconds.
    case long
    /// A custom number of seconds.
    case seconds(Double)
    /// Stays until the user swipes it away or you call ``ToastCenter/dismiss(_:)``.
    case indefinite

    public var timeInterval: Double? {
        switch self {
        case .short: 2.5
        case .long: 4.5
        case let .seconds(value): max(0, value)
        case .indefinite: nil
        }
    }
}

// MARK: - Action

/// An optional trailing button, for example "Undo".
public struct ToastAction: Sendable {
    public let title: String
    public let handler: @MainActor @Sendable () -> Void

    public init(_ title: String, handler: @escaping @MainActor @Sendable () -> Void) {
        self.title = title
        self.handler = handler
    }
}
