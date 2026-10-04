//
//  CarPlaySceneDelegate.swift
//  CarPlayWebBrowser
//
//  CarPlay Scene Delegate sử dụng MapTemplate để mở rộng quyền hiển thị giao diện đồ họa web toàn màn hình trên xe thực tế.
//

import UIKit
import CarPlay

class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate, CPMapTemplateDelegate {
    
    var carWindow: UIWindow?
    var interfaceController: CPInterfaceController?
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController,
        to window: UIWindow
    ) {
        self.interfaceController = interfaceController
        self.carWindow = window
        
        print("[CarPlaySceneDelegate] Đã kết nối với màn hình CarPlay của xe!")
        
        // 1. Tạo WebBrowserCarViewController hiển thị WKWebView
        let browserVC = WebBrowserCarViewController()
        let navigationController = UINavigationController(rootViewController: browserVC)
        navigationController.isNavigationBarHidden = true
        
        // 2. Gán trực tiếp vào UIWindow của CarPlay
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // 3. Sử dụng CPMapTemplate làm khung khởi chạy chuẩn giúp iOS CarPlay chấp nhận ứng dụng đồ họa trên xe thật
        let mapTemplate = CPMapTemplate()
        mapTemplate.mapDelegate = self
        
        interfaceController.setRootTemplate(mapTemplate, animated: false, completion: nil)
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnectInterfaceController interfaceController: CPInterfaceController,
        from window: UIWindow
    ) {
        print("[CarPlaySceneDelegate] Đã ngắt kết nối với CarPlay.")
        self.carWindow = nil
        self.interfaceController = nil
    }
}
