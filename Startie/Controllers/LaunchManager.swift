import AppKit

struct LaunchManager {
    static func launch(application: Application) {
        NSWorkspace.shared.launchApplication(
            withBundleIdentifier: application.bundleIdentifier,
            options: [],
            additionalEventParamDescriptor: nil,
            launchIdentifier: nil
        )
    }
}
