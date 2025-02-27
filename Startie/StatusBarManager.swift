import SwiftUI
import AppKit

class StatusBarManager: NSObject {
    private var statusItem: NSStatusItem!
    
    override init() {
        super.init()
        
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            // Set the icon (using app icon)
            if let appIcon = NSApp.applicationIconImage {
                let resizedIcon = resizeImage(image: appIcon, w: 18, h: 18)
                button.image = resizedIcon
            }
            
            // Configure the button with precise action handling
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
        }
    }
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            // Request window creation directly - simpler approach
            requestWindowCreation()
        }
    }
    
    private func requestWindowCreation() {
        // Always request a window - the AppDelegate will handle whether to create or show existing
        NSApp.activate(ignoringOtherApps: true)
        NotificationCenter.default.post(name: NSNotification.Name("CreateNewWindow"), object: nil)
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        // Add a "Show" menu item
        let showItem = NSMenuItem(title: "Show", action: #selector(showMainWindowFromMenu), keyEquivalent: "s")
        showItem.target = self
        menu.addItem(showItem)
        
        let restartItem = NSMenuItem(title: "Restart", action: #selector(restartApp), keyEquivalent: "r")
        restartItem.target = self
        menu.addItem(restartItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        // Present the menu
        statusItem.menu = menu
        
        // Reset the menu after it's displayed
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.menu = nil
        }
    }
    
    @objc private func showMainWindowFromMenu() {
        requestWindowCreation()
    }
    
    @objc private func restartApp() {
        // Get the path to the current application
        let bundleURL = Bundle.main.bundleURL
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [bundleURL.path]
        
        do {
            try process.run()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.terminate(nil)
            }
        } catch {
            print("Failed to restart: \(error)")
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
