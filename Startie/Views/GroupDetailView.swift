//
//  GroupDetailView.swift
//  Startie
//
//  Created by u1 on 2/27/25.
//


import SwiftUI

struct GroupDetailView: View {
    var body: some View {
        VStack {
            HStack {
                Button("Add Application") {
                    // TODO: Implement file picker to add an application
                }
                Spacer()
                Button("Start") {
                    // TODO: Launch all applications in the selected group
                }
            }
            .padding()
            
            List {
                // TODO: Display list of applications
                Text("Application 1")
            }
        }
        .navigationTitle("Group Details")
    }
}
