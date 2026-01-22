import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timer: Timer?
    var breakWindowController: BreakWindowController?
    var timerStartDate: Date?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        startWorkTimer()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            if let image = NSImage(systemSymbolName: "leaf.circle", accessibilityDescription: "Mindful Break") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "🍃"
            }
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 320)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView(appDelegate: self))
    }
    
    func startWorkTimer() {
        timer?.invalidate()
        timerStartDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1200, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showBreakAlert()
            }
        }
    }
    
    private func showBreakAlert() {
        let alert = NSAlert()
        alert.messageText = "Time for a mindful break"
        alert.informativeText = "You've been focused for 20 minutes. Take a moment to refresh."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Take a Break")
        alert.addButton(withTitle: "Skip")
        
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            showBreakWindow()
        }
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func showBreakWindow() {
        popover?.performClose(nil)
        if breakWindowController == nil {
            breakWindowController = BreakWindowController()
        }
        breakWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
