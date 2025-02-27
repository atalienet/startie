//
//  AppGroup.swift
//  Startie
//
//  Created by u1 on 2/27/25.
//


import Foundation

struct AppGroup: Identifiable {
    var id = UUID()
    var name: String
    var applications: [Application]
    var launchAtLogin: Bool
}

extension AppGroup {
    static let sampleGroups = [
        AppGroup(name: "Work", applications: [], launchAtLogin: false),
        AppGroup(name: "Entertainment", applications: [], launchAtLogin: false)
    ]
}
