import Foundation

/// A pure, deterministic queue that decides which toasts are visible.
///
/// ``ToastCenter`` wraps this type and adds timers and observation. It is public
/// so you can reuse the queueing rules in your own presentation layer.
public struct ToastQueue: Sendable {
    /// Toasts currently on screen, oldest first.
    public private(set) var visible: [Toast] = []
    /// Toasts waiting for a free slot, oldest first.
    public private(set) var pending: [Toast] = []

    /// Maximum number of toasts shown at the same time.
    public var maxVisible: Int {
        didSet { maxVisible = max(1, maxVisible) }
    }

    /// When `true`, a toast identical to one already visible or pending is ignored.
    public var dropsDuplicates: Bool

    public init(maxVisible: Int = 3, dropsDuplicates: Bool = true) {
        self.maxVisible = max(1, maxVisible)
        self.dropsDuplicates = dropsDuplicates
    }

    public var isEmpty: Bool { visible.isEmpty && pending.isEmpty }

    /// Adds a toast.
    /// - Returns: `.visible` when it went straight on screen, `.queued` when it
    ///   waits for a slot, or `.dropped` when it was a duplicate.
    @discardableResult
    public mutating func enqueue(_ toast: Toast) -> EnqueueResult {
        if dropsDuplicates, (visible + pending).contains(where: { $0.isDuplicate(of: toast) }) {
            return .dropped
        }
        if visible.count < maxVisible {
            visible.append(toast)
            return .visible
        }
        pending.append(toast)
        return .queued
    }

    /// Removes a toast wherever it is.
    /// - Returns: The pending toast that was promoted to fill the freed slot, if any.
    @discardableResult
    public mutating func dismiss(id: Toast.ID) -> Toast? {
        if let index = pending.firstIndex(where: { $0.id == id }) {
            pending.remove(at: index)
            return nil
        }
        guard let index = visible.firstIndex(where: { $0.id == id }) else { return nil }
        visible.remove(at: index)
        guard !pending.isEmpty, visible.count < maxVisible else { return nil }
        let promoted = pending.removeFirst()
        visible.append(promoted)
        return promoted
    }

    public mutating func removeAll() {
        visible.removeAll()
        pending.removeAll()
    }

    public enum EnqueueResult: Sendable, Equatable {
        case visible
        case queued
        case dropped
    }
}
