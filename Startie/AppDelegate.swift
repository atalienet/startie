import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var contentView: AnyView?
    private var statusBarManager: StatusBarManager?
    private var mainWindowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the status bar icon
        statusBarManager = StatusBarManager()
        
        // Only launch auto-start groups if app was launched at login
        if AutoLaunchManager.wasLaunchedAtLogin() {
            launchAutoStartGroups()
        }
        
        // Set up notification observer for creating windows
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCreateWindow),
            name: NSNotification.Name("CreateNewWindow"),
            object: nil
        )
        
        // THIS WAS MISSING: Schedule the login item refresh after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.refreshLoginItem()
        }
    }
    
    private func refreshLoginItem() {
        print("Refreshing login item 5 seconds after app launch")
        // Call the new method that properly handles all scenarios
        AutoLaunchManager.refreshLoginItemRegistration()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Keep app running when window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running in menu bar when window is closed
    }
    
    // Window creation handler
    @objc func handleCreateWindow() {
        // Check if there's already a valid window we can use
        let appWindows = NSApp.windows.filter { window in
            // Filter out status bar windows by checking class name
            !window.isExcludedFromWindowsMenu &&
            String(describing: type(of: window)) != "NSStatusBarWindow"
        }
        
        if let existingWindow = appWindows.first(where: { $0.isVisible }) {
            // We have a visible window, just activate it
            NSApp.activate(ignoringOtherApps: true)
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        if let hiddenWindow = appWindows.first(where: { window in
            return !window.isVisible
        }) {
            // We have a hidden window, show it
            NSApp.activate(ignoringOtherApps: true)
            hiddenWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        // No valid window exists, create one
        createNewWindow()
    }
    
    private func createNewWindow() {
        guard let contentView = self.contentView else { return }
        
        // Make sure we don't have an existing controller
        if mainWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Startie"
            window.contentView = NSHostingView(rootView: contentView)
            
            mainWindowController = NSWindowController(window: window)
            
            // Track when this window is closed
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(windowWillClose(_:)),
                name: NSWindow.willCloseNotification,
                object: window
            )
        }
        
        // Show and activate the window
        mainWindowController?.showWindow(nil)
        
        // Make sure the app is active
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func windowWillClose(_ notification: Notification) {
        if let closingWindow = notification.object as? NSWindow,
           closingWindow == mainWindowController?.window {
            // Our main window is closing, clear the reference
            mainWindowController = nil
        }
    }
    
    private func launchAutoStartGroups() {
        // Get auto-launch group IDs
        let autoLaunchGroupIds = AutoLaunchManager.getAutoLaunchGroups()
        
        if !autoLaunchGroupIds.isEmpty {
            // Create a new DataStore to load saved groups
            let dataStore = DataStore()
            
            // Launch each group that's configured for auto-launch
            for groupIdString in autoLaunchGroupIds {
                if let groupId = UUID(uuidString: groupIdString),
                   let group = dataStore.appGroups.first(where: { $0.id == groupId }) {
                    
                    // Get the delay for this group
                    let delay = AutoLaunchManager.getLaunchDelay(for: groupId)
                    
                    print("Auto-launching group: \(group.name) with delay: \(delay) seconds")
                    
                    if delay > 0 {
                        // Launch with delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(delay)) {
                            self.launchGroup(group)
                        }
                    } else {
                        // Launch immediately
                        launchGroup(group)
                    }
                }
            }
        }
    }
    
    private func launchGroup(_ group: AppGroup) {
        LaunchManager.launchApplications(in: group) { successCount in
            print("Auto-launched \(successCount) of \(group.enabledApplications.count) applications in group \(group.name)")
        }
    }
}
