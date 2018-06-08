//
//  AppDelegate.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/1.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        YQLog("userAccount.plist".getCachesDirector())
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(notification:)), name: NSNotification.Name(rawValue: "pushVC"), object: nil);
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = showRootViewController()
        
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().tintColor = UIColor.orange
        UITabBar.appearance().tintColor = UIColor.orange
        
        return true
    }

    //  判断是否有新版本
    fileprivate func isNewVersion() -> Bool {
        guard let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {
            YQLog("获取当前版本失败")
            return false
        }
        let userDefault = UserDefaults.standard
        let lastVersion = (userDefault.value(forKey: "version") as? String) ?? "0.0"
        
        if lastVersion.compare(currentVersion) == ComparisonResult.orderedAscending {  // 有新版本
            
            userDefault.set(currentVersion, forKey: "version")
            
            return true
        }
        
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// 处理通知的方法
extension AppDelegate {
    @objc fileprivate func receiveNotification(notification: Notification) {
        guard let isHome = notification.userInfo?["homePage"] as? Bool else {
            return
        }
        
        if isHome {
            window?.rootViewController = MainViewController()
        }else {
        
            let welcomStoryboardVC = UIStoryboard.init(name: "NewFeature", bundle: nil).instantiateInitialViewController()
            window?.rootViewController = welcomStoryboardVC
        }
        
    }
    
    func showRootViewController() -> UIViewController {
        if YQUserAccountModal.isLogin() { // 已经登录
            if isNewVersion() { // 有新版本
                return UIStoryboard.init(name: "WelcomBegin", bundle: nil).instantiateInitialViewController()!
            } else {
                return UIStoryboard.init(name: "NewFeature", bundle: nil).instantiateInitialViewController()!
            }
        }
        
        return MainViewController()
    }
    

}

