import SwiftUI
import AppKit

class StatusBarManager: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var rightClickMenu: NSMenu!
    
    override init() {
        super.init()
        
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // Set up right-click menu once at initialization
        setupRightClickMenu()
        
        if let button = statusItem.button {
            // Set the icon (using app icon)
            if let appIcon = NSApp.applicationIconImage {
                let resizedIcon = resizeImage(image: appIcon, w: 18, h: 18)
                button.image = resizedIcon
            }
            
            // Use a different approach for handling clicks
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
        }
    }
    
    private func setupRightClickMenu() {
        rightClickMenu = NSMenu()
        rightClickMenu.delegate = self
        
        // Add Restart option
        let restartItem = NSMenuItem(title: "Restart", action: #selector(restartApp), keyEquivalent: "r")
        restartItem.target = self
        rightClickMenu.addItem(restartItem)
        
        // Add Quit option
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        rightClickMenu.addItem(quitItem)
    }
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else if event.type == .leftMouseUp {
            requestWindowCreation()
        }
    }
    
    private func requestWindowCreation() {
        // Always request a window - the AppDelegate will handle whether to create or show existing
        NSApp.activate(ignoringOtherApps: true)
        NotificationCenter.default.post(name: NSNotification.Name("CreateNewWindow"), object: nil)
    }
    
    private func showContextMenu() {
        statusItem.menu = rightClickMenu
        statusItem.button?.performClick(nil)
        
        // Reset the menu after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.statusItem.menu = nil
        }
    }
    
    // MARK: - NSMenuDelegate
    
    func menuDidClose(_ menu: NSMenu) {
        // Ensure menu is detached after closing
        if menu == rightClickMenu {
            statusItem.menu = nil
        }
    }
    
    @objc private func restartApp() {
        print("Restart app triggered")
        
        // Use NSWorkspace for more reliable app launching
        let workspace = NSWorkspace.shared
        let bundleURL = Bundle.main.bundleURL
        
        // Launch new instance first, then quit current instance
        do {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            
            workspace.openApplication(at: bundleURL,
                                     configuration: configuration) { newApp, error in
                if let error = error {
                    print("Failed to launch new instance: \(error)")
                    return
                }
                
                print("Successfully launched new instance, terminating current instance...")
                
                // Give the new instance time to fully launch before terminating this one
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NSApp.terminate(nil)
                }
            }
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // Helper function to resize the app icon for the menu bar
    private func resizeImage(image: NSImage, w: CGFloat, h: CGFloat) -> NSImage {
        let destSize = NSSize(width: w, height: h)
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSRect(x: 0, y: 0, width: destSize.width, height: destSize.height),
                  from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                  operation: .sourceOver,
                  fraction: 1)
        newImage.unlockFocus()
        newImage.isTemplate = true // Makes it work with Dark Mode
        return newImage
    }
}
