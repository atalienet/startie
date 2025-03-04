[日本語版を表示する](./README_ja.md)
# Startie - App-laud Everytime!

![Image](https://github.com/user-attachments/assets/31025fde-b02c-4498-8c6a-431166d959a6)

## ⚠️ Important Notice
- This application is currently in its alpha phase and may **contain numerous bugs and incomplete features.** A stable release is anticipated in March.
- **Please be aware that this application is currently unsigned. This may result in limitations, including those related to building via Xcode. A formal release with appropriate signing is planned for March.** 
 
## Overview

Startie revolutionises your workflow by allowing you to group applications and launch them collectively. Whether you favour manual activation or the convenience of automation, Startie enables you to configure your app groups to launch automatically upon system startup or user login.

## Key Features

* **Application Grouping:** Organise your applications into bespoke, manageable groups tailored to your specific needs.
* **Batch Launch:** Initiate all applications within a selected group simultaneously, significantly enhancing your efficiency.
* **Multiple Group Management:** Create and administer multiple application groups, perfectly aligning with your diverse workflows.
* **Advanced Launch Conditions:**
    * Set groups to launch automatically on system startup or user login.
    * Implement delayed launch times for each group, relative to startup or login, facilitating a staggered and controlled application launch.

## System Requirements

* Latest macOS, macOS 15 Sequoia
* Apple Silicon Mac

## Installation Instructions

1.  Navigate to the `v0.1` tag within the repository.
2.  Download and extract the source code.
3.  Open the project and build the application using Xcode.

## How to use
1. Launch the application.
    1. If no window appears, click on the icon (a plain square) in the menu bar.
2. Click the `+` button at the top of the left sidebar to add a group and specify its name.
3. In the main area on the right, add applications to the group.
4. Click the ▶ button to launch all applications in the group at once!
5. If you want to set the application to launch at login or configure other settings, click the ⚙ icon at the top right.

## Development Roadmap

* **Enhanced Launch Conditions:** Introduce more refined control over launch triggers, including time-specific and event-driven activations.
* **Seamless macOS Integration:** Deepen compatibility and integration with various macOS functionalities, such as Spotlight and Shortcuts.
* **Background Application Launch:** Enable applications to launch without bringing their windows to the foreground, maintaining a streamlined and focused workspace.
* **Individual Application Delay Settings:** Implement the capability to set individual delays for applications within groups, offering granular control over launch timing.
* **Customisable Application Group Icons:** Add the feature to assign custom icons to application groups, enhancing visual differentiation and quick identification.
* **User friendly UI:** Improve the User interface to make the application more pleasing to use.
* **Settings Persistence:** Add the ability for the application to save its settings between uses.
* **Error Handling:** Add better error handling to the application.

## Specifications
- Swift 
- SwiftUI
- Swift Data
