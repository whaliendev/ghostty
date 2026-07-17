import SwiftUI
import UniformTypeIdentifiers

struct QuickTerminalView: View {
    let ghostty: Ghostty.App

    var controller: QuickTerminalController
    @ObservedObject var tabManager: QuickTerminalTabManager
    @Binding var isPinned: Bool

    var body: some View {
        VStack(spacing: 0) {
            if tabManager.tabs.count > 1 {
                QuickTerminalTabBarView(ghostty: ghostty, tabManager: tabManager)
            }
            ZStack(alignment: .topTrailing) {
                TerminalView(
                    ghostty: ghostty,
                    viewModel: controller,
                    delegate: controller,
                )
                .onDrop(of: [.quickTerminalTab], isTargeted: nil) { _ in
                    // Tab dropped on terminal surface - move to new window
                    if let tab = tabManager.draggedTab {
                        tabManager.moveTabToNewWindow(tab)
                        return true
                    }
                    return false
                }

                QuickTerminalPinButton(isPinned: $isPinned)
                    .frame(width: 30, height: 30)
                    .padding(.top, 10)
                    .padding(.trailing, 10)
            }
        }
        // The Quick Terminal window visually hides its titlebar but the NSPanel
        // still reports a safe-area inset at the top. `TerminalView` already
        // ignores that inset internally, but the VStack wrapping it does not —
        // without this, the tab bar (and the unwrapped top edge generally)
        // gets pushed down by the inset, leaving a dark strip above the bar.
        .ignoresSafeArea(.container, edges: .top)
    }
}
