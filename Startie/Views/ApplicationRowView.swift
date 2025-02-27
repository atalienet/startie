import SwiftUI

struct ApplicationRowView: View {
    let application: Application
    let onToggle: (Bool) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Application icon (fixed conditional binding)
            let icon = NSWorkspace.shared.icon(forFile: application.path)
            Image(nsImage: icon)
                .resizable()
                .frame(width: 32, height: 32)
            
            // Application name
            VStack(alignment: .leading) {
                Text(application.name)
                    .fontWeight(.medium)
                Text(application.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            // Enable/disable toggle
            Toggle("", isOn: Binding(
                get: { application.isEnabled },
                set: { onToggle($0) }
            ))
            .toggleStyle(.switch)
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}
