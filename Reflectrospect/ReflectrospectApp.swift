//
//  ReflectrospectApp.swift
//  Reflectrospect
//
//  Created by Sindhu Rallabhandi on 3/15/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    let db = Firestore.firestore()
      let storage = Storage.storage()
    return true
  }
}

@main
struct ReflectrospectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
