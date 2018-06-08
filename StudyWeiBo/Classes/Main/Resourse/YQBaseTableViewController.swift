//
//  YQBaseTableViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/6.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQBaseTableViewController: UITableViewController {
    
    var baseView : YQBaseView?

    let isLogin : Bool = YQUserAccountModal.isLogin()
    override func loadView() {
        if isLogin {
            super.loadView()
        }else{
            let baseView : YQBaseView = YQBaseView.creatBaseView()
            self.baseView = baseView
            view = baseView
            
            setupUI()
        }
    }
}

// MARK: -- 设置UI界面
extension YQBaseTableViewController {
    fileprivate func setupUI() {
        // 3.添加导航条按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.plain, target: self, action: #selector(registerBtnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.plain, target: self, action: #selector(loginBtnClick))
    }
    
    @objc private func registerBtnClick() {
        YQLog("")
    }
    
    @objc private func loginBtnClick() {
        present(YQOAuthViewController(), animated: true, completion: nil)
    }
}
