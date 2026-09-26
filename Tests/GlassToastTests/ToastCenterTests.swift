import Testing
@testable import GlassToast

@MainActor
@Suite("ToastCenter")
struct ToastCenterTests {
    @Test func autoDismissesAfterDuration() async throws {
        let center = ToastCenter()
        center.show(Toast(title: "Quick", duration: .seconds(0.05)))
        #expect(center.visibleToasts.count == 1)

        try await Task.sleep(for: .milliseconds(400))

        #expect(center.visibleToasts.isEmpty)
    }

    @Test func indefiniteToastStaysUntilDismissed() async throws {
        let center = ToastCenter()
        let toast = Toast(title: "Sticky", duration: .indefinite)
        center.show(toast)

        try await Task.sleep(for: .milliseconds(150))
        #expect(center.visibleToasts.count == 1)

        center.dismiss(toast.id)
        #expect(center.visibleToasts.isEmpty)
    }

    @Test func promotedToastGetsItsOwnTimer() async throws {
        let center = ToastCenter(maxVisible: 1)
        let first = Toast(title: "First", duration: .indefinite)
        center.show(first)
        center.show(Toast(title: "Second", duration: .seconds(0.05)))
        #expect(center.queue.pending.count == 1)

        center.dismiss(first.id)
        #expect(center.visibleToasts.map(\.title) == ["Second"])

        try await Task.sleep(for: .milliseconds(400))
        #expect(center.queue.isEmpty)
    }

    @Test func dismissAllClearsEverything() {
        let center = ToastCenter(maxVisible: 1)
        center.show("One")
        center.show("Two")
        center.dismissAll()
        #expect(center.queue.isEmpty)
    }
}
