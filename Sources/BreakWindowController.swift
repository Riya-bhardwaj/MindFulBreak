import SwiftUI
import AppKit

class BreakWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 520),
            styleMask: [.titled, .closable, .fullSizeContentView, .resizable],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .clear
        window.isMovableByWindowBackground = true
        window.center()
        window.level = .floating
        window.collectionBehavior = [.fullScreenPrimary]
        window.contentView = NSHostingView(rootView: BreakView())
        
        self.init(window: window)
    }
    
    override func showWindow(_ sender: Any?) {
        window?.contentView = NSHostingView(rootView: BreakView())
        super.showWindow(sender)
        window?.center()
    }
}
