//
//  YQStatusModal.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/28.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQStatusModal: NSObject {
    
    /// 微博创建时间
    var created_at: String?
    
    /// 字符串型的微博ID
    var idstr: String?
    
    /// 微博信息内容
    var text: String?
    
     /**微博来源*/
    var source: String?
    
    /// 微博作者的用户信息
    var user: YQUserModal?
    
    /// 配图数组
    var pic_urls: [[String: AnyObject]]?
    
    
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeys(dict)
        
    }
    
    override var description: String {
        let property = ["created_at", "idstr", "text", "source", "user"]
        let dict = dictionaryWithValues(forKeys: property)
        return "\(dict)"
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "user" {
            user = YQUserModal(dict: value as! [String : AnyObject])
            return
        }
        super.setValue(value, forKey: key)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
}
