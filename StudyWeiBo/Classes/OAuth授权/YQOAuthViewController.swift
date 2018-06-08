//
//  YQOAuthViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/14.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQOAuthViewController: UIViewController {
    
    @IBOutlet weak var containWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        containWebView.delegate = self

        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=2712205577&redirect_uri=http://www.520it.com"
        
        guard let url = URL(string : urlStr) else {
            return
        }
        let request = URLRequest(url: url)
        containWebView.loadRequest(request)
    }
}

// MARK: -- UIWebViewDelegate代理方法
extension YQOAuthViewController : UIWebViewDelegate {
    
    //  每次请求都会调用这个方法
        // 如果返回false: 代表不允许请求
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 判断是否是授权回调页
        guard let urlStr = request.url?.absoluteString else {
            return false
        }
        
        guard urlStr.hasPrefix(WB_Redirect_uri) else {
            
            YQLog("不是授权回调页")
            return true
        }
     
        //  判断授权回调页中是否包含 code= 
            // query : 表示获取一个请求地址中的参数部分
        let queryKey = "code="
        
        guard let query = request.url?.query else {
            return false
        }
        guard query.hasPrefix(queryKey) else {
            YQLog("请求参数中不包含 code=")
            return false
        }
        let codeStr = query.substring(from: queryKey.endIndex)
        
        loadAccessToken(codeStr: codeStr)
        return false
        
    }
}

// MARK: -- 获取accessToken
extension YQOAuthViewController {
    
    // 利用request_Token换取 access token
    fileprivate func loadAccessToken(codeStr : String?) {
        guard (codeStr != nil) else {
            return
        }
        // 1. 创建请求头
        let headerStr = "oauth2/access_token"
        // 2. 创建参数
        let parameters = ["client_id": WB_App_Key, "client_secret": WB_App_Secret, "grant_type": "authorization_code", "code": codeStr, "redirect_uri": WB_Redirect_uri]
        
        // 3. 发送请求
        YQNetworkTools.shareInstance.post(headerStr, parameters: parameters, progress: nil, success: { (task, objc) in
            guard let result = objc as? [String: AnyObject] else {
                YQLog("返回数据错误")
                return
            }
            
            // accessToken : 2.007FcawFPZIYxC271330707ebGf4EB 
                //  在一定时间内 返回的accessToken值是一样的
            let userAccount = YQUserAccountModal(dict: result)
            
            // 获取用户信息必须先拿到access_token
            userAccount.getUserInfo(finished: {(newUserAccount, error) in
                guard newUserAccount != nil else {
                    YQLog(error)
                    return
                }
                // 将数据保存起来
                guard newUserAccount!.saveAccount() else {
                    YQLog("归档失败")
                    return
                }
                
                //  保存用户信息成功后  跳转到欢迎界面 
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushVC"), object: nil, userInfo: ["homePage": false])
            })
            
            
        }) { (errorTask, error) in
            YQLog(error)
        }
        
    }
}
