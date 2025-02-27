import SwiftUI

@main
struct StartieApp: App {
    @StateObject private var dataStore = DataStore()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Store the content view in the AppDelegate
                    appDelegate.contentView = AnyView(
                        ContentView()
                            .environmentObject(dataStore)
                            .frame(minWidth: 800, minHeight: 600)
                    )
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Group") {
                    // Show create group dialog
                    createNewGroup()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
    
    private func createNewGroup() {
        let alert = NSAlert()
        alert.messageText = "Create New Group"
        alert.informativeText = "Enter a name for the new group:"
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.placeholderString = "Group Name"
        alert.accessoryView = textField
        
        alert.addButton(withTitle: "Create")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            let groupName = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !groupName.isEmpty {
                dataStore.addGroup(name: groupName)
            }
        }
    }
}
