// Startie/AppState.swift
import Foundation
import ServiceManagement

class AppState: ObservableObject {
    @Published var groups: [AppGroup] = []
    
    init() {
        loadGroups()
    }
    
    func loadGroups() {
        let url = getDocumentsDirectory().appendingPathComponent("groups.json")
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([AppGroup].self, from: data) {
            groups = decoded
        }
    }
    
    func saveGroups() {
        let url = getDocumentsDirectory().appendingPathComponent("groups.json")
        if let data = try? JSONEncoder().encode(groups) {
            try? data.write(to: url)
        }
    }
    
    func updateLoginItems() {
        let shouldEnable = groups.contains { $0.launchAtLogin }
        let service = SMAppService.mainApp
        do {
            if shouldEnable {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            print("Failed to update login items: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
