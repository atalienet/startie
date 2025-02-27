import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if we need to launch any groups automatically
        launchAutoStartGroups()
    }
    
    private func launchAutoStartGroups() {
        // Get list of groups that should auto-start
        let autoLaunchGroupIds = AutoLaunchManager.getAutoLaunchGroups()
        
        if !autoLaunchGroupIds.isEmpty {
            // Create a new DataStore to load saved groups
            let dataStore = DataStore()
            
            // Launch each group that's configured for auto-launch
            for groupIdString in autoLaunchGroupIds {
                if let groupId = UUID(uuidString: groupIdString),
                   let group = dataStore.appGroups.first(where: { $0.id == groupId }) {
                    print("Auto-launching group: \(group.name)")
                    LaunchManager.launchApplications(in: group) { successCount in
                        print("Auto-launched \(successCount) of \(group.enabledApplications.count) applications in group \(group.name)")
                    }
                }
            }
        }
    }
}
