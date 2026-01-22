import SwiftUI
import AppKit

class BreakWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 450),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .clear
        window.isMovableByWindowBackground = true
        window.center()
        window.contentView = NSHostingView(rootView: BreakView())
        
        self.init(window: window)
    }
}
