import AppKit
import SwiftUI

/// Small floating pin button overlaid on the Quick Terminal. When toggled on,
/// the Quick Terminal does not auto-hide on focus loss for the rest of the
/// session — the underlying `quick-terminal-autohide` config is not modified.
struct QuickTerminalPinButton: View {
    @Binding var isPinned: Bool

    @State private var isHovered: Bool = false

    var body: some View {
        Button {
            isPinned.toggle()
        } label: {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .font(.system(size: 12, weight: .semibold))
                .rotationEffect(.degrees(isPinned ? 0 : 45))
                .foregroundStyle(foregroundColor)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(.regularMaterial)
                        .opacity(isHovered || isPinned ? 0.7 : 0.0)
                )
                // Use a rectangular hit-region — clicking anywhere in the 30×30
                // frame should toggle the pin, not only the inner circle. This
                // is what makes the button comfortable to click; the previous
                // `.contentShape(Circle())` produced a frustratingly small
                // target.
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
            // The terminal surface view installs its own tracking area that
            // forces the I-beam cursor whenever the mouse is over the
            // terminal. Pushing pointingHand onto the cursor stack while
            // hovering and popping it on exit gives the button a normal
            // clickable feel without interfering with the I-beam everywhere
            // else inside the terminal.
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .help(isPinned
              ? "Unpin Quick Terminal (auto-hide on focus loss)"
              : "Pin Quick Terminal (stay open on focus loss)")
        .accessibilityLabel(isPinned ? "Unpin Quick Terminal" : "Pin Quick Terminal")
    }

    private var foregroundColor: Color {
        if isPinned {
            return .yellow
        }
        return isHovered ? .primary : Color.white.opacity(0.45)
    }
}
