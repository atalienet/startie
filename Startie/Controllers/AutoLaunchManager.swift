import Foundation
import ServiceManagement

class AutoLaunchManager {
    // Key constants for UserDefaults
    private static let launchAtStartupKey = "LaunchAtStartup"
    private static let autoLaunchGroupsKey = "AutoLaunchGroups"
    
    // MARK: - App Launch at Login Management
    
    /// Check if app was launched at login
    static func wasLaunchedAtLogin() -> Bool {
        // Check for startup flag in arguments
        return ProcessInfo.processInfo.arguments.contains(where: { $0.contains("-psn") })
    }
    
    /// Check if app is registered as a login item
    static func isLoginItemEnabled() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }
    
    /// Update the app's login item registration to match UserDefaults
    static func refreshLoginItemRegistration() {
        print("Current login item status: \(SMAppService.mainApp.status.rawValue)")
        
        // If any auto-launch groups exist, ensure the app launches at login
        let hasAutoLaunchGroups = !(getAutoLaunchGroups().isEmpty)
        if hasAutoLaunchGroups {
            // Force login item registration if there are auto-launch groups
            enableLoginItem()
            UserDefaults.standard.set(true, forKey: launchAtStartupKey)
            print("Auto-registering as login item because auto-launch groups exist")
        } else if UserDefaults.standard.bool(forKey: launchAtStartupKey) {
            // User preference is to launch at login
            enableLoginItem()
        } else {
            // User preference is not to launch at login
            disableLoginItem()
        }
    }
    
    /// Force registration as login item (ignoring current status)
    static func forceRegisterLoginItem() {
        do {
            try SMAppService.mainApp.register()
            print("Force-registered as login item")
            UserDefaults.standard.set(true, forKey: launchAtStartupKey)
        } catch {
            print("Failed to force-register as login item: \(error)")
        }
    }
    
    /// Register app as a login item
    static func enableLoginItem() {
        do {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
                print("Successfully registered as login item")
            } else {
                print("App is already registered as login item")
            }
            // Store the preference
            UserDefaults.standard.set(true, forKey: launchAtStartupKey)
        } catch {
            print("Failed to register as login item: \(error)")
        }
    }
    
    /// Unregister app as a login item
    static func disableLoginItem() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
                print("Successfully unregistered as login item")
            } else {
                print("App is already not registered as login item")
            }
            // Update the preference
            UserDefaults.standard.set(false, forKey: launchAtStartupKey)
        } catch {
            print("Failed to unregister as login item: \(error)")
        }
    }
    
    // MARK: - Group Auto-launch Management
    
    /// Set auto-launch for a specific group
    static func setLaunchAtLogin(enabled: Bool, for group: AppGroup) {
        if enabled {
            addAutoLaunchGroup(groupId: group.id)
            // If adding an auto-launch group, ensure the app is set to launch at login
            enableLoginItem()
        } else {
            removeAutoLaunchGroup(groupId: group.id)
            // If no auto-launch groups remain, we can disable app launch at login
            if getAutoLaunchGroups().isEmpty {
                disableLoginItem()
            }
        }
    }
    
    // Rest of the methods remain the same...
    
    /// Check if a group is set to auto-launch
    static func isGroupSetToAutoLaunch(groupId: UUID) -> Bool {
        let autoLaunchGroups = getAutoLaunchGroups()
        return autoLaunchGroups.contains(groupId.uuidString)
    }
    
    /// Set launch delay for a group
    static func setLaunchDelay(seconds: Int, for group: AppGroup) {
        let key = "LaunchDelay-\(group.id.uuidString)"
        UserDefaults.standard.set(seconds, forKey: key)
    }
    
    /// Get launch delay for a group
    static func getLaunchDelay(for groupId: UUID) -> Int {
        let key = "LaunchDelay-\(groupId.uuidString)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // MARK: - Private Helpers
    
    /// Get list of auto-launch group IDs
    static func getAutoLaunchGroups() -> [String] {
        return UserDefaults.standard.stringArray(forKey: autoLaunchGroupsKey) ?? []
    }
    
    /// Add a group to auto-launch list
    private static func addAutoLaunchGroup(groupId: UUID) {
        var groups = getAutoLaunchGroups()
        let groupIdString = groupId.uuidString
        
        if !groups.contains(groupIdString) {
            groups.append(groupIdString)
            UserDefaults.standard.set(groups, forKey: autoLaunchGroupsKey)
        }
    }
    
    /// Remove a group from auto-launch list
    private static func removeAutoLaunchGroup(groupId: UUID) {
        var groups = getAutoLaunchGroups()
        let groupIdString = groupId.uuidString
        
        groups.removeAll { $0 == groupIdString }
        UserDefaults.standard.set(groups, forKey: autoLaunchGroupsKey)
    }
}
