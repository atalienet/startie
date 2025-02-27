import SwiftUI

// Helper to silence the deprecation warning
struct SidebarNavigationLink<Label: View>: View {
    let destination: GroupDetailView
    let tag: UUID
    @Binding var selection: UUID?
    let label: () -> Label
    
    var body: some View {
        NavigationLink(
            destination: destination,
            tag: tag,
            selection: $selection,
            label: label
        )
    }
}

struct SidebarView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showingAddGroupAlert = false
    @State private var newGroupName = ""
    
    var body: some View {
        List {
            ForEach(dataStore.appGroups) { group in
                // Using our custom wrapper to silence the warning
                SidebarNavigationLink(
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
    
    // Keep the existing methods
    private func renameGroup(_ group: AppGroup) {
        // Existing implementation
    }
    
    private func deleteGroup(_ group: AppGroup) {
        // Existing implementation
    }
}
