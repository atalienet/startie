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
            // Get the DataStore
            guard let dataStore = getDataStore() else {
                print("Could not access DataStore for auto-launching groups")
                return
            }
            
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
    
    private func getDataStore() -> DataStore? {
        // Get the DataStore from the SwiftUI environment
        if let windowScene = NSApplication.shared.windows.first?.windowScene {
            for window in windowScene.windows {
                if let rootViewController = window.rootViewController,
                   let hostingController = rootViewController as? NSHostingController<AnyView> {
                    // Try to extract the DataStore from the environment
                    // This is a bit of a hack, but works for most SwiftUI apps
                    let mirror = Mirror(reflecting: hostingController.rootView)
                    for child in mirror.children {
                        if let dataStore = child.value as? DataStore {
                            return dataStore
                        }
                    }
                }
            }
        }
        
        // If we can't get it from the UI, create a temporary one to load data
        let tempDataStore = DataStore()
        return tempDataStore
    }
}
