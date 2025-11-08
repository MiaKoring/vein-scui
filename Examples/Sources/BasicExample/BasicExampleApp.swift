//
//  BetterSyncSCUITestApp.swift
//  BetterSyncSCUITest
//
//  Created by Mia Koring on 29.10.25.
import Foundation
import SwiftCrossUI
import DefaultBackend
import BetterSync
import BetterSyncSCUI

@main
struct BetterSyncTestEnvironmentApp: App {
    @State var toggleQueries = false
    let modelContainer: ModelContainer
    
    init() {
        do {
            EncryptionManager.shared.provider = try AESGCMProvider(password: "Test")
            let containerPath = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!
            
            let dbDir = containerPath.relativePath.replacingOccurrences(of: "%20", with: " ").appending("/BSCUITest/InternalData")
            
            let dbPath = dbDir.appending("/db.sqlite3")
            print(dbDir)
            try FileManager.default.createDirectory(
                atPath: dbDir,
                withIntermediateDirectories: true
            )
            
            if !FileManager.default.fileExists(atPath: dbPath) {
                FileManager.default.createFile(
                    atPath: dbPath,
                    contents: nil
                )
            }
            
            self.modelContainer = try ModelContainer(
                models: Test.self,
                migration: TestMigration.self,
                at: dbPath
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    var body: some Scene {
        WindowGroup("BetterSyncTest") {
            BetterSyncContainer {
                HStack {
                    ContentView()
                    #if !canImport(UIKit)
                    ContentView(predicate: .randomValue(.isBiggerOrEqualTo, 500).flag(.isEqualTo, true))
                    #endif
                }
            }
            .modelContainer(modelContainer)
        }.defaultSize(width: 800, height: 600)
    }
}
