import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingAddGroupAlert = false
    @State private var newGroupName = ""
    
    var body: some View {
        List {
            ForEach(dataStore.appGroups) { group in
                NavigationLink(
                    destination: GroupDetailView(group: group),
                    tag: group.id,
                    selection: $dataStore.selectedGroupId
                ) {
                    HStack {
                        Text(group.name)
                        Spacer()
                        Text("\(group.applications.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .contextMenu {
                    Button("Rename") {
                        renameGroup(group)
                    }
                    Divider()
                    Button("Delete") {
                        deleteGroup(group)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    showingAddGroupAlert = true
                }) {
                    Label("Add Group", systemImage: "plus")
                }
            }
        }
        .alert("New Group", isPresented: $showingAddGroupAlert) {
            TextField("Group Name", text: $newGroupName)
            Button("Cancel", role: .cancel) {
                newGroupName = ""
            }
            Button("Create") {
                if !newGroupName.isEmpty {
                    dataStore.addGroup(name: newGroupName)
                    newGroupName = ""
                }
            }
        } message: {
            Text("Enter a name for the new group")
        }
    }
    
    private func renameGroup(_ group: AppGroup) {
        let alert = NSAlert()
        alert.messageText = "Rename Group"
        alert.informativeText = "Enter a new name for the group:"
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.stringValue = group.name
        alert.accessoryView = textField
        
        alert.addButton(withTitle: "Rename")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            let newName = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !newName.isEmpty {
                var updatedGroup = group
                updatedGroup.name = newName
                dataStore.updateGroup(updatedGroup)
            }
        }
    }
    
    private func deleteGroup(_ group: AppGroup) {
        let alert = NSAlert()
        alert.messageText = "Delete Group"
        alert.informativeText = "Are you sure you want to delete '\(group.name)'? This action cannot be undone."
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            dataStore.deleteGroup(withId: group.id)
        }
    }
}
