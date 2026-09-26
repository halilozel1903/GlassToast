import Testing
@testable import GlassToast

@Suite("ToastQueue")
struct ToastQueueTests {
    @Test func showsUpToMaxVisibleThenQueues() {
        var queue = ToastQueue(maxVisible: 2)
        #expect(queue.enqueue(.info("One")) == .visible)
        #expect(queue.enqueue(.info("Two")) == .visible)
        #expect(queue.enqueue(.info("Three")) == .queued)
        #expect(queue.visible.map(\.title) == ["One", "Two"])
        #expect(queue.pending.map(\.title) == ["Three"])
    }

    @Test func dismissingVisibleToastPromotesOldestPending() {
        var queue = ToastQueue(maxVisible: 1)
        let first = Toast.info("First")
        queue.enqueue(first)
        queue.enqueue(.info("Second"))
        queue.enqueue(.info("Third"))

        let promoted = queue.dismiss(id: first.id)

        #expect(promoted?.title == "Second")
        #expect(queue.visible.map(\.title) == ["Second"])
        #expect(queue.pending.map(\.title) == ["Third"])
    }

    @Test func dismissingPendingToastPromotesNothing() {
        var queue = ToastQueue(maxVisible: 1)
        queue.enqueue(.info("Visible"))
        let waiting = Toast.info("Waiting")
        queue.enqueue(waiting)

        #expect(queue.dismiss(id: waiting.id) == nil)
        #expect(queue.pending.isEmpty)
        #expect(queue.visible.count == 1)
    }

    @Test func dropsDuplicatesByDefault() {
        var queue = ToastQueue()
        queue.enqueue(.success("Saved"))
        #expect(queue.enqueue(.success("Saved")) == .dropped)
        #expect(queue.enqueue(.error("Saved")) == .visible)
    }

    @Test func keepsDuplicatesWhenAsked() {
        var queue = ToastQueue(dropsDuplicates: false)
        queue.enqueue(.success("Saved"))
        #expect(queue.enqueue(.success("Saved")) == .visible)
    }

    @Test func maxVisibleIsAtLeastOne() {
        var queue = ToastQueue(maxVisible: 0)
        #expect(queue.maxVisible == 1)
        queue.maxVisible = -4
        #expect(queue.maxVisible == 1)
    }

    @Test func unknownIdIsIgnored() {
        var queue = ToastQueue()
        queue.enqueue(.info("Hello"))
        #expect(queue.dismiss(id: Toast.info("Other").id) == nil)
        #expect(queue.visible.count == 1)
    }
}

@Suite("Toast")
struct ToastTests {
    @Test func durations() {
        #expect(ToastDuration.short.timeInterval == 2.5)
        #expect(ToastDuration.long.timeInterval == 4.5)
        #expect(ToastDuration.seconds(-1).timeInterval == 0)
        #expect(ToastDuration.indefinite.timeInterval == nil)
    }

    @Test func customSymbolWinsOverStyleSymbol() {
        let toast = Toast(title: "Hi", systemImage: "star.fill", style: .success)
        #expect(toast.resolvedSystemImage == "star.fill")
        #expect(Toast.success("Hi").resolvedSystemImage == "checkmark.circle.fill")
        #expect(Toast(title: "Plain").resolvedSystemImage == nil)
    }
}
