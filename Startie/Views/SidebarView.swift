//
//  SidebarView.swift
//  Startie
//
//  Created by u1 on 2/27/25.
//


import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            ForEach(AppGroup.sampleGroups) { group in
                Text(group.name)
            }
            Button(action: {
                // TODO: Add Group functionality
            }) {
                Label("Add Group", systemImage: "plus")
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Groups")
    }
}
