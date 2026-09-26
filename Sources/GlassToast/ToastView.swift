import SwiftUI

/// The visual representation of a single toast.
struct ToastView: View {
    let toast: Toast
    let edge: VerticalEdge
    let onDismiss: () -> Void
    let onDragChanged: (Bool) -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    /// Distance, in points, the user has to drag towards the edge to dismiss.
    private let dismissThreshold: CGFloat = 32

    var body: some View {
        HStack(spacing: 12) {
            if let symbol = toast.resolvedSystemImage {
                Image(systemName: symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(toast.style.tint)
                    .symbolEffect(.bounce, value: toast.id)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let message = toast.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let action = toast.action {
                Button {
                    action.handler()
                    onDismiss()
                } label: {
                    Text(action.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(toast.style.tint)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: 520)
        .toastBackground(tint: toast.style.tint)
        .offset(y: dragOffset)
        .gesture(dragGesture)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityAction(named: Text("Dismiss"), onDismiss)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    onDragChanged(true)
                }
                let translation = value.translation.height
                let towardsEdge = edge == .top ? translation < 0 : translation > 0
                // Follow the finger towards the edge, rubber-band away from it.
                dragOffset = towardsEdge ? translation : translation / 6
            }
            .onEnded { value in
                isDragging = false
                let translation = value.predictedEndTranslation.height
                let dismissed = edge == .top
                    ? translation < -dismissThreshold
                    : translation > dismissThreshold
                if dismissed {
                    onDismiss()
                } else {
                    withAnimation(.spring(duration: 0.35, bounce: 0.4)) { dragOffset = 0 }
                    onDragChanged(false)
                }
            }
    }
}

extension View {
    /// Liquid Glass on iOS 26 and macOS 26, a material fallback everywhere else.
    @ViewBuilder
    func toastBackground(tint: Color) -> some View {
        let shape = RoundedRectangle(cornerRadius: 26, style: .continuous)
        if #available(iOS 26.0, macOS 26.0, *) {
            glassEffect(.regular.tint(tint.opacity(0.12)).interactive(), in: shape)
        } else {
            background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
        }
    }
}
