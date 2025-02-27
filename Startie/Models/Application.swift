//
//  Application.swift
//  Startie
//
//  Created by u1 on 2/27/25.
//


import Foundation

struct Application: Identifiable {
    var id = UUID()
    var name: String
    var bundleIdentifier: String
    var path: String
}
