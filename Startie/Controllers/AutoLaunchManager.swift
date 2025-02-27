import Foundation
import ServiceManagement
import AppKit

class AutoLaunchManager {
    
    // Keys for storing settings in UserDefaults
    private static let autoLaunchGroupsKey = "AutoLaunchGroups"
    private static let autoLaunchDelaysKey = "AutoLaunchDelays" // New key for delays
    
    static func setLaunchAtLogin(enabled: Bool, for group: AppGroup) {
        // Update the user defaults to remember which groups should auto-launch
        updateAutoLaunchGroups(group: group, enabled: enabled)
        
        // Configure system login items
        configureLoginItem(enabled: enabled)
    }
    
    // New method to set delay for a group
    static func setLaunchDelay(seconds: Int, for group: AppGroup) {
        var delays = getLaunchDelays()
        delays[group.id.uuidString] = seconds
        UserDefaults.standard.set(delays, forKey: autoLaunchDelaysKey)
    }
    
    // New method to get delay for a group
    static func getLaunchDelay(for groupId: UUID) -> Int {
        let delays = getLaunchDelays()
        return delays[groupId.uuidString] ?? 0
    }
    
    // Helper to get all delays
    private static func getLaunchDelays() -> [String: Int] {
        return UserDefaults.standard.dictionary(forKey: autoLaunchDelaysKey) as? [String: Int] ?? [:]
    }
    
    // Configure the app itself as a login item
    private static func configureLoginItem(enabled: Bool) {
        if #available(macOS 13.0, *) {
            Task {
                do {
                    let service = SMAppService.mainApp
                    
                    if enabled {
                        if service.status != .enabled {
                            try service.register()
                            print("Successfully registered app for login using SMAppService")
                        }
                    } else {
                        // Only unregister if no groups are set to launch at login
                        if getAutoLaunchGroups().isEmpty && service.status == .enabled {
                            try service.unregister()
                            print("Successfully unregistered app from login using SMAppService")
                        }
                    }
                } catch {
                    print("Error configuring login item with SMAppService: \(error.localizedDescription)")
                }
            }
        } else {
            // For older macOS versions
            if let bundleID = Bundle.main.bundleIdentifier as CFString? {
                // Only unregister if no groups are set to launch at login
                let shouldEnable = enabled || !getAutoLaunchGroups().isEmpty
                
                let result = SMLoginItemSetEnabled(bundleID, shouldEnable)
                print("Login item \(shouldEnable ? "enabled" : "disabled") using SMLoginItemSetEnabled: \(result)")
            } else {
                print("Failed to get bundle identifier for login item configuration")
            }
        }
    }
    
    // Store which groups should auto-launch in UserDefaults
    private static func updateAutoLaunchGroups(group: AppGroup, enabled: Bool) {
        var groups = getAutoLaunchGroups()
        
        if enabled {
            // Add group ID if not already in the list
            if !groups.contains(group.id.uuidString) {
                groups.append(group.id.uuidString)
            }
        } else {
            // Remove group ID if in the list
            groups.removeAll { $0 == group.id.uuidString }
        }
        
        UserDefaults.standard.set(groups, forKey: autoLaunchGroupsKey)
    }
    
    // Get the list of group IDs that should auto-launch
    static func getAutoLaunchGroups() -> [String] {
        return UserDefaults.standard.stringArray(forKey: autoLaunchGroupsKey) ?? []
    }
    
    // Check if a specific group is set to auto-launch
    static func isGroupSetToAutoLaunch(groupId: UUID) -> Bool {
        let groups = getAutoLaunchGroups()
        return groups.contains(groupId.uuidString)
    }
}
