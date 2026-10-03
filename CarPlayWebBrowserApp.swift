//
//  CarPlayWebBrowserApp.swift
//  CarPlayWebBrowser
//
//  Created for CarPlay Graphical Web Browsing.
//

import SwiftUI
import UIKit
import CarPlay

@main
struct CarPlayWebBrowserApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            iPhoneWebControlView()
        }
    }
}

/// AppDelegate để đăng ký cấu hình CarPlay Scene
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        print("[CarPlayWebBrowser] App started successfully.")
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        
        if connectingSceneSession.role == UISceneSession.Role(rawValue: "CPTemplateApplicationSceneSessionRoleApplication") {
            let sceneConfig = UISceneConfiguration(
                name: "CarPlay",
                sessionRole: connectingSceneSession.role
            )
            sceneConfig.delegateClass = CarPlaySceneDelegate.self
            return sceneConfig
        }
        
        let config = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        return config
    }
}
