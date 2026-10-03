//
//  CarPlaySceneDelegate.swift
//  CarPlayWebBrowser
//
//  CarPlay Scene Delegate quản lý cửa sổ hiển thị đồ họa web trên màn hình CarPlay.
//

import UIKit
import CarPlay

class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    
    // Lưu trữ kết nối với UIWindow của CarPlay
    var carWindow: UIWindow?
    var interfaceController: CPInterfaceController?
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController,
        to window: UIWindow
    ) {
        self.interfaceController = interfaceController
        self.carWindow = window
        
        print("[CarPlaySceneDelegate] CarPlay Window Connected! Displaying Web Browser UI...")
        
        // Khởi tạo và thiết lập WebBrowserCarViewController làm Root View Controller của màn hình CarPlay
        let browserVC = WebBrowserCarViewController()
        let navigationController = UINavigationController(rootViewController: browserVC)
        navigationController.isNavigationBarHidden = true // Tự tạo custom navbar tối ưu cho CarPlay
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // Tạo một template CarPlay cơ bản để giữ kết nối interfaceController không bị đứt
        setupFallbackCarPlayTemplate(interfaceController: interfaceController)
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnectInterfaceController interfaceController: CPInterfaceController,
        from window: UIWindow
    ) {
        print("[CarPlaySceneDelegate] CarPlay Window Disconnected.")
        self.carWindow = nil
        self.interfaceController = nil
    }
    
    private func setupFallbackCarPlayTemplate(interfaceController: CPInterfaceController) {
        let item = CPListItem(text: "Đang hiển thị Trình Duyệt Web", detailText: "Xem trên màn hình chính của xe")
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Trình Duyệt Web", sections: [section])
        
        interfaceController.setRootTemplate(listTemplate, animated: false, completion: nil)
    }
}
