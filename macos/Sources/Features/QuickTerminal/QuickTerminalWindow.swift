import Cocoa

class QuickTerminalWindow: NSPanel {
    // Both of these must be true for windows without decorations to be able to
    // still become key/main and receive events.
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Note: almost all of this stuff can be done in the nib/xib directly
        // but I prefer to do it programmatically because the properties we
        // care about are less hidden.

        // Add a custom identifier so third party apps can use the Accessibility
        // API to apply special rules to the quick terminal.
        self.identifier = .init(rawValue: "com.mitchellh.ghostty.quickTerminal")

        // Set the correct AXSubrole of kAXFloatingWindowSubrole (allows
        // AeroSpace to treat the Quick Terminal as a floating window)
        self.setAccessibilitySubrole(.floatingWindow)

        // Keep `.titled` in the styleMask so macOS' private NSThemeFrame draws
        // the standard rounded outer rectangle (and the window-server can
        // compute a matching drop shadow). `.fullSizeContentView` lets the
        // contentView extend into the area where the titlebar would otherwise
        // sit. The titlebar is then visually erased via `titleVisibility` and
        // `titlebarAppearsTransparent`, and the traffic-light buttons are
        // explicitly hidden. `.nonactivatingPanel` preserves the existing
        // overlay behaviour (no app activation when the Quick Terminal is
        // triggered). See HiddenTitlebarTerminalWindow for the same pattern
        // used by the regular Terminal in hidden-titlebar mode.
        self.styleMask = [
            .titled,
            .fullSizeContentView,
            .resizable,
            .closable,
            .nonactivatingPanel,
        ]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true

        // Nuke the titlebar container outright as a belt-and-braces measure
        // (mirrors HiddenTitlebarTerminalWindow.swift); some operations such
        // as setting `title` can otherwise re-reveal it.
        if let themeFrame = contentView?.superview,
           let titleBarContainer = themeFrame.firstDescendant(
               withClassName: "NSTitlebarContainerView") {
            titleBarContainer.isHidden = true
        }
    }

    /// This is set to the frame prior to setting `contentView`. This is purely a hack to workaround
    /// bugs in older macOS versions (Ventura): https://github.com/ghostty-org/ghostty/pull/8026
    var initialFrame: NSRect?

    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
        // Upon first adding this Window to its host view, older SwiftUI
        // seems to have a "hiccup" and corrupts the frameRect,
        // sometimes setting the size to zero, sometimes corrupting it.
        // If we find we have cached the "initial" frame, use that instead
        // the propagated one through the framework
        //
        // https://github.com/ghostty-org/ghostty/pull/8026
        super.setFrame(initialFrame ?? frameRect, display: flag)
    }
}
