//
//  DataStore.swift
//  Startie
//
//  Created by u1 on 2/27/25.
//


import Foundation
import Combine

class DataStore: ObservableObject {
    @Published var appGroups: [AppGroup] = []
    @Published var selectedGroupId: UUID?
    
    private let saveURL: URL
    
    var selectedGroup: AppGroup? {
        guard let id = selectedGroupId else { return nil }
        return appGroups.first { $0.id == id }
    }
    
    init() {
        // Get the Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        saveURL = documentsDirectory.appendingPathComponent("startie_groups.json")
        
        loadGroups()
    }
    
    // MARK: - Group Management
    
    func addGroup(name: String) {
        let newGroup = AppGroup(name: name)
        appGroups.append(newGroup)
        selectedGroupId = newGroup.id
        saveGroups()
    }
    
    func updateGroup(_ group: AppGroup) {
        if let index = appGroups.firstIndex(where: { $0.id == group.id }) {
            appGroups[index] = group
            saveGroups()
        }
    }
    
    func deleteGroup(withId id: UUID) {
        appGroups.removeAll { $0.id == id }
        if selectedGroupId == id {
            selectedGroupId = appGroups.first?.id
        }
        saveGroups()
    }
    
    // MARK: - Application Management
    
    func addApplication(to groupId: UUID, application: Application) {
        if let index = appGroups.firstIndex(where: { $0.id == groupId }) {
            // Check if app already exists in the group
            if !appGroups[index].applications.contains(where: { $0.path == application.path }) {
                appGroups[index].applications.append(application)
                saveGroups()
            }
        }
    }
    
    func removeApplication(from groupId: UUID, applicationId: UUID) {
        if let groupIndex = appGroups.firstIndex(where: { $0.id == groupId }) {
            appGroups[groupIndex].applications.removeAll { $0.id == applicationId }
            saveGroups()
        }
    }
    
    func toggleApplication(in groupId: UUID, applicationId: UUID) {
        if let groupIndex = appGroups.firstIndex(where: { $0.id == groupId }),
           let appIndex = appGroups[groupIndex].applications.firstIndex(where: { $0.id == applicationId }) {
            appGroups[groupIndex].applications[appIndex].isEnabled.toggle()
            saveGroups()
        }
    }
    
    // MARK: - Persistence
    
    func saveGroups() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(appGroups)
            try data.write(to: saveURL)
        } catch {
            print("Error saving groups: \(error.localizedDescription)")
        }
    }
    
    func loadGroups() {
        do {
            if FileManager.default.fileExists(atPath: saveURL.path) {
                let data = try Data(contentsOf: saveURL)
                appGroups = try JSONDecoder().decode([AppGroup].self, from: data)
                
                // Set the first group as selected if none is selected
                if selectedGroupId == nil && !appGroups.isEmpty {
                    selectedGroupId = appGroups[0].id
                }
            }
        } catch {
            print("Error loading groups: \(error.localizedDescription)")
            // Start with empty groups if loading fails
            appGroups = []
        }
    }
}