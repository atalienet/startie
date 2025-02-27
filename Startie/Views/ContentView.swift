import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        NavigationView {
            SidebarView()
                .frame(minWidth: 200)
            
            if let selectedGroup = dataStore.selectedGroup {
                GroupDetailView(group: selectedGroup)
            } else {
                Text("Select a group or create a new one")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Startie")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil
        )
    }
}
