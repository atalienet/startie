import Foundation
import ServiceManagement
import AppKit

class AutoLaunchManager {
    
    // Keys for storing settings in UserDefaults
    private static let autoLaunchGroupsKey = "AutoLaunchGroups"
    private static let autoLaunchDelaysKey = "AutoLaunchDelays"
    
    // Launch argument to identify when app was started at login
    static let launchedAtLoginArg = "--launched-at-login"
    
    static func setLaunchAtLogin(enabled: Bool, for group: AppGroup) {
        // Update the user defaults to remember which groups should auto-launch
        updateAutoLaunchGroups(group: group, enabled: enabled)
        
        // Configure system login items
        configureLoginItem(enabled: enabled)
    }
    
    static func setLaunchDelay(seconds: Int, for group: AppGroup) {
        var delays = getLaunchDelays()
        delays[group.id.uuidString] = seconds
        UserDefaults.standard.set(delays, forKey: autoLaunchDelaysKey)
    }
    
    static func getLaunchDelay(for groupId: UUID) -> Int {
        let delays = getLaunchDelays()
        return delays[groupId.uuidString] ?? 0
    }
    
    private static func getLaunchDelays() -> [String: Int] {
        return UserDefaults.standard.dictionary(forKey: autoLaunchDelaysKey) as? [String: Int] ?? [:]
    }
    
    private static func configureLoginItem(enabled: Bool) {
        if #available(macOS 13.0, *) {
            Task {
                do {
                    let service = SMAppService.mainApp
                    
                    if enabled {
                        if service.status != .enabled {
                            // Use the correct API for registering the app
                            try service.register()
                            print("Successfully registered app for login using SMAppService")
                            
                            // We can't directly pass launch arguments with SMAppService
                            // Instead, we'll check a flag in UserDefaults when the app launches
                            UserDefaults.standard.set(true, forKey: "LaunchAtLogin")
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
    
    static func getAutoLaunchGroups() -> [String] {
        return UserDefaults.standard.stringArray(forKey: autoLaunchGroupsKey) ?? []
    }
    
    static func isGroupSetToAutoLaunch(groupId: UUID) -> Bool {
        let groups = getAutoLaunchGroups()
        return groups.contains(groupId.uuidString)
    }
    
    // Check if app was launched at login
    static func wasLaunchedAtLogin() -> Bool {
        // Since we can't pass launch arguments with SMAppService in newer macOS versions,
        // we'll use a UserDefaults flag to detect launch at login
        if UserDefaults.standard.bool(forKey: "LaunchAtLogin") {
            // Reset the flag after checking it
            UserDefaults.standard.set(false, forKey: "LaunchAtLogin")
            return true
        }
        
        // Also check command line arguments for backward compatibility
        return CommandLine.arguments.contains(launchedAtLoginArg)
    }
}
