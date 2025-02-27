import Foundation

struct AppGroup: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var applications: [Application] = []
    var launchAtLogin: Bool = false
    
    // Filter for only enabled applications
    var enabledApplications: [Application] {
        applications.filter { $0.isEnabled }
    }
    
    static func == (lhs: AppGroup, rhs: AppGroup) -> Bool {
        return lhs.id == rhs.id
    }
}
