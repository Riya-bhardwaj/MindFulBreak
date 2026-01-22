import SwiftUI
import UserNotifications

@main
struct MindfulBreakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timer: Timer?
    var breakWindowController: BreakWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupNotifications()
        startWorkTimer()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "leaf.circle", accessibilityDescription: "Mindful Break")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 320)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView(appDelegate: self))
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func startWorkTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1200, repeats: true) { [weak self] _ in
            self?.sendBreakNotification()
        }
    }
    
    private func sendBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a mindful break"
        content.body = "You've been focused for 20 minutes. Take a moment to refresh."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        showBreakWindow()
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
