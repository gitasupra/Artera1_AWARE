//
//  AWAREApp.swift
//  AWARE Watch App
//
//  Created by Jessica Lieu on 11/5/23.
//

import SwiftUI
import Firebase
import FirebaseCore
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  func applicationDidFinishLaunching() {
    FirebaseApp.configure()
      
//    Analytics.logEvent("watch_app_launched", parameters: nil)

  }
}

@main
struct AWARE_Watch_AppApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
