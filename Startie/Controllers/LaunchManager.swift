import Foundation
import AppKit

class LaunchManager {
    
    enum LaunchError: Error {
        case applicationNotFound
        case launchFailed
    }
    
    static func launch(application: Application) -> Result<Void, LaunchError> {
        let workspace = NSWorkspace.shared
        
        // Check if the file exists
        if !FileManager.default.fileExists(atPath: application.path) {
            return .failure(.applicationNotFound)
        }
        
        // Create proper NSWorkspace.OpenConfiguration object instead of dictionary
        let configuration = NSWorkspace.OpenConfiguration()
        
        workspace.openApplication(at: application.url,
                              configuration: configuration,
                          completionHandler: nil)
        return .success(())
    }
    
    static func launchApplications(in group: AppGroup, completion: @escaping (Int) -> Void) {
        let enabledApps = group.enabledApplications
        var successCount = 0
        
        for app in enabledApps {
            let result = launch(application: app)
            
            switch result {
            case .success:
                successCount += 1
            case .failure(let error):
                print("Error launching \(app.name): \(error)")
            }
        }
        
        completion(successCount)
    }
}
