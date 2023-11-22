//
//  AppDelegate.swift
//  Example-iOS
//
//  Created by 李文康 on 2023/11/7.
//

@_exported import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        #if DEBUG
            ZonPlayer.Manager.shared.enableConsoleLog = true
        #endif
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: HomeScene())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
