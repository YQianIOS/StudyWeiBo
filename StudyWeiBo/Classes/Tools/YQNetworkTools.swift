//
//  YQNetworkTools.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/14.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import AFNetworking

class YQNetworkTools: AFHTTPSessionManager {
    
    // Swift推荐我们这样编写单例
    static let shareInstance : YQNetworkTools = {
        
        let baseUrl = URL(string: "https://api.weibo.com/")
        let networkTool = YQNetworkTools(baseURL: baseUrl, sessionConfiguration: URLSessionConfiguration.default)
        
        return networkTool
    }()
    
    // 首页数据的请求
    func requestHomePageData(sindeId: String, max_id: String, finish: @escaping (_ result: [[String: AnyObject]]?, _ err: Error?)->()) {
        assert(YQUserAccountModal.loadUserAccount() != nil, "必须授权之后才能获取微博数据")
        
        // 1.准备路径
        let path = "2/statuses/home_timeline.json"
        // 2.准备参数
        let parameters = ["access_token": YQUserAccountModal.loadUserAccount()!.access_token!, "since_id": sindeId, "max_id": max_id]
        
        // 3.发送Get请求
        get(path, parameters: parameters, progress: nil, success: { (dataTask, object) in
            
            guard let data = object as? [String: AnyObject]  else {
                return
            }
            guard let status = data["statuses"] as? [[String: AnyObject]] else {
                return
            }
            finish(status, nil)
            
        }) { (dataTask, error) in
            finish(nil, error)
        }
        
        
    }
}
