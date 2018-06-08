//
//  MainViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/2.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    // MARK: -- 懒加载
    fileprivate lazy var bottomBtn : UIButton = {
        () -> UIButton in
        let bottomBtn : UIButton = UIButton()
        bottomBtn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), for: .normal)
        bottomBtn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), for: .highlighted)
        bottomBtn.setImage(UIImage(named: "tabbar_compose_icon_add"), for: .normal)
        bottomBtn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), for: .highlighted)
        
        bottomBtn.addTarget(self, action: #selector(bottomBtnClick(button:)), for: .touchUpInside)
        
        let width : CGFloat = kScreenW / CGFloat(self.tabBar.subviews.count)
//        bottomBtn.frame = CGRect(x: width * 2, y: 3, width: width, height: kTabBarH)
        let rect : CGRect = CGRect(x: 0, y: 0, width: width, height: kTabBarH)
        bottomBtn.frame = rect.offsetBy(dx: 2 * width, dy: 3)
        
        return bottomBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         //  添加buttom
        tabBar.addSubview(bottomBtn)
    }

}

// MARK: -- 设置UI
extension MainViewController {
    fileprivate func setupUI() {
        
        //  添加子控制器
        
        // MARK: -- 通过 Json 数据来动态创建一个类
        guard let jsonStr = Bundle.main.path(forResource: "MainVCSettings.json", ofType: nil) else {
            YQLog("动态获取类名字符串失败")
            return
        }
        
        //  转化成 NSData 对象
        guard let jsonData = NSData(contentsOfFile: jsonStr) as Data? else {
            YQLog("动态获取类名字符串失败")
            return
        }
        
        do {
            
            /*
             Swift和OC不太一样, OC中一般情况如果发生错误会给传入的指针赋值, 而在Swift中使用的是异常处理机制
             1.以后但凡看大 throws的方法, 那么就必须进行 try处理, 而只要看到try, 就需要写上do catch
             2.do{}catch{}, 只有do中的代码发生了错误, 才会执行catch{}中的代码
             3. try  正常处理异常, 也就是通过do catch来处理
             try! 告诉系统一定不会有异常, 也就是说可以不通过 do catch来处理
             但是需要注意, 开发中不推荐这样写, 一旦发生异常程序就会崩溃
             如果没有异常那么会返回一个确定的值给我们
             
             try? 告诉系统可能有错也可能没错, 如果没有系统会自动将结果包装成一个可选类型给我们, 如果有错系统会返回nil, 如果使用try? 那么可以不通过do catch来处理
             */
            
            let data = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String : AnyObject]]
            
            for dict in data {
                guard let controllerName = dict["vcName"] as? String else {
                    YQLog("类名出错")
                    return
                }
                let imageStr = dict["imageName"] as? String
                let selectStr = dict["selectImageStr"] as? String
                let title = dict["title"] as? String
                
                addChildControllersWithString(controllerStr: controllerName, imageStr: imageStr, selectImageStr: selectStr, title: title)
            }
            YQLog("动态加载控制器")
        } catch {
            YQLog("静态加载控制器")
            
            addChildControllersWithString(controllerStr: "YQHomeViewController", imageStr: "tabbar_home", selectImageStr: "tabbar_home_highlighted", title: "首页")
            addChildControllersWithString(controllerStr: "YQDiscoverViewController", imageStr: "tabbar_discover", selectImageStr: "tabbar_discover_highlighted", title: "发现")
            addChildControllersWithString(controllerStr: "YQNullTextViewController", imageStr: "", selectImageStr: "", title: "")
            addChildControllersWithString(controllerStr: "YQMessageViewController", imageStr: "tabbar_message_center", selectImageStr: "tabbar_message_center_highlighted", title: "消息")
            addChildControllersWithString(controllerStr: "YQProfileTableViewController", imageStr: "tabbar_profile", selectImageStr: "tabbar_profile_highlighted", title: "我的")
        }
        
        // MARK: -- 通过命名空间 + 字符串 来创建一个类
        /*
        addChildControllersWithString(controllerStr: "YQHomeViewController", imageStr: "tabbar_home", selectImageStr: "tabbar_home_highlighted", title: "首页")
        addChildControllersWithString(controllerStr: "YQDiscoverViewController", imageStr: "tabbar_discover", selectImageStr: "tabbar_discover_highlighted", title: "发现")
        addChildControllersWithString(controllerStr: "YQNullTextViewController", imageStr: "", selectImageStr: "", title: "")
        addChildControllersWithString(controllerStr: "YQMessageViewController", imageStr: "tabbar_message_center", selectImageStr: "tabbar_message_center_highlighted", title: "消息")
        addChildControllersWithString(controllerStr: "YQProfileTableViewController", imageStr: "tabbar_profile", selectImageStr: "tabbar_profile_highlighted", title: "我的")
        */
        
        // MARK: -- 通过控制器来创建一个类
        /*
        addChildControllers(viewController: YQHomeViewController(), imageStr: "tabbar_home", selectImageStr: "tabbar_home_highlighted", title: "首页")
        addChildControllers(viewController: YQDiscoverViewController(), imageStr: "tabbar_discover", selectImageStr: "tabbar_discover_highlighted", title: "发现")
        addChildControllers(viewController: UIViewController(), imageStr: "", selectImageStr: "", title: "")
        addChildControllers(viewController: YQMessageViewController(), imageStr: "tabbar_message_center", selectImageStr: "tabbar_message_center_highlighted", title: "消息")
        addChildControllers(viewController: YQProfileTableViewController(), imageStr: "tabbar_profile", selectImageStr: "tabbar_profile_highlighted", title: "我的")
         */
        
    }
    
    //  利用字符串来创建控制器
    private func addChildControllersWithString(controllerStr: String, imageStr : String? = "", selectImageStr : String? = "", title : String? = "") {
        //  StudyWeiBo.YQHomeViewController
       
        guard let infoDic = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            YQLog("获取命名空间失败")
            return
        }

        //  通过字符串来创建类,  这个类必须真实存在   不然创建出来的会是nil
        let classStr = infoDic + "." + controllerStr
        guard let vc = NSClassFromString(classStr) as? UIViewController.Type else {
            YQLog("创建类失败")
            return
        }
        let viewController = vc.init()
        let navigationVC = UINavigationController(rootViewController: viewController)
        
        if selectImageStr != nil {
            viewController.tabBarItem.selectedImage = UIImage(named: selectImageStr!)
        }
        if imageStr != nil {
            viewController.tabBarItem.image = UIImage(named: imageStr!)
        }
        
        viewController.title = title
        addChildViewController(navigationVC)
        
    }
    
    //  添加子控制器
    private func addChildControllers(viewController : UIViewController, imageStr : String, selectImageStr : String, title : String) {
        
        viewController.tabBarItem.image = UIImage(named: imageStr)
        viewController.tabBarItem.selectedImage = UIImage(named: selectImageStr)
        viewController.tabBarItem.title = title
        addChildViewController(viewController)
    }
}

// MARK: -- 事件的处理
extension MainViewController {
    @objc fileprivate func bottomBtnClick(button : UIButton) {
        YQLog("点击事件")
    }
}
