import Foundation

struct Application: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var path: String
    var bundleIdentifier: String?
    var isEnabled: Bool = true
    
    // Helper computed property to get the URL for the application
    var url: URL {
        URL(fileURLWithPath: path)
    }
    
    // Equality check based on path
    static func == (lhs: Application, rhs: Application) -> Bool {
        return lhs.path == rhs.path
    }
}
