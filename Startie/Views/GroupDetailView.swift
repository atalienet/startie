import SwiftUI
import UniformTypeIdentifiers

struct GroupDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    @State var group: AppGroup
    @State private var showingFilePicker = false
    @State private var showingSettings = false
    @State private var isLaunching = false
    @State private var launchResults: (total: Int, success: Int)? = nil
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text(group.name)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Label("Settings", systemImage: "gear")
                }
                .popover(isPresented: $showingSettings) {
                    GroupSettingsView(group: $group)
                        .frame(width: 300, height: 200)
                        .padding()
                }
                
                Button(action: {
                    showingFilePicker = true
                }) {
                    Label("Add Application", systemImage: "plus")
                }
                .sheet(isPresented: $showingFilePicker) {
                    AppPickerView { selectedApps in
                        for app in selectedApps {
                            dataStore.addApplication(to: group.id, application: app)
                        }
                        // Update our local copy of the group
                        if let updatedGroup = dataStore.appGroups.first(where: { $0.id == group.id }) {
                            group = updatedGroup
                        }
                    }
                }
            }
            .padding([.horizontal, .top])
            
            // Launch button
            Button(action: {
                launchApplications()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Group")
                }
                .frame(minWidth: 150)
            }
            .buttonStyle(.borderedProminent)
            .disabled(group.enabledApplications.isEmpty || isLaunching)
            .padding()
            
            // Launch results
            if let results = launchResults {
                Text("Launched \(results.success) of \(results.total) applications")
                    .foregroundColor(results.success == results.total ? .green : .orange)
                    .padding(.bottom)
            }
            
            // Application list
            List {
                ForEach(group.applications) { app in
                    ApplicationRowView(application: app, onToggle: { isEnabled in
                        toggleApplication(app, isEnabled: isEnabled)
                    }, onDelete: {
                        dataStore.removeApplication(from: group.id, applicationId: app.id)
                        // Update our local copy of the group
                        if let updatedGroup = dataStore.appGroups.first(where: { $0.id == group.id }) {
                            group = updatedGroup
                        }
                    })
                }
            }
            .listStyle(InsetListStyle())
            
            // Empty state
            if group.applications.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Applications")
                        .font(.title2)
                    
                    Text("Click the + button to add applications to this group")
                        .foregroundColor(.secondary)
                    
                    Button("Add Application") {
                        showingFilePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .onChange(of: group) { newGroup in
            dataStore.updateGroup(newGroup)
        }
    }
    
    private func toggleApplication(_ app: Application, isEnabled: Bool) {
        if let index = group.applications.firstIndex(where: { $0.id == app.id }) {
            group.applications[index].isEnabled = isEnabled
            dataStore.updateGroup(group)
        }
    }
    
    private func launchApplications() {
        isLaunching = true
        launchResults = nil
        
        LaunchManager.launchApplications(in: group) { successCount in
            isLaunching = false
            launchResults = (group.enabledApplications.count, successCount)
        }
    }
}

// A view for group settings
struct GroupSettingsView: View {
    @Binding var group: AppGroup
    @State private var launchAtLogin: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Group Settings")) {
                TextField("Group Name", text: $group.name)
                    .padding(.vertical, 4)
                
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        // When the toggle changes, update the login item settings
                        AutoLaunchManager.setLaunchAtLogin(enabled: newValue, for: group)
                    }
                    .padding(.vertical, 4)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Applications in group: \(group.applications.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Enabled applications: \(group.enabledApplications.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
        .padding()
        .onAppear {
            // Check if this group is set to auto-launch when the view appears
            launchAtLogin = AutoLaunchManager.isGroupSetToAutoLaunch(groupId: group.id)
        }
    }
}

// A view to pick applications
struct AppPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSelect: ([Application]) -> Void
    
    var body: some View {
        VStack {
            Text("Select Applications")
                .font(.headline)
                .padding()
            
            Button("Select Applications") {
                pickApplications()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .frame(width: 300, height: 200)
    }
    
    private func pickApplications() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [UTType.application]
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        openPanel.begin { response in
            if response == .OK {
                let applications = openPanel.urls.map { url in
                    let appName = url.deletingPathExtension().lastPathComponent
                    return Application(
                        name: appName,
                        path: url.path,
                        bundleIdentifier: Bundle(url: url)?.bundleIdentifier
                    )
                }
                onSelect(applications)
                presentationMode.wrappedValue.dismiss()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
