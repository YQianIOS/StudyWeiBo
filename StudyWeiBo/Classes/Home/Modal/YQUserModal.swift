//
//  YQUserModal.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/28.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQUserModal: NSObject {
    
    /// 字符串型的用户UID
    @objc var idstr: String?
    
    /// 用户昵称
    @objc var screen_name: String?
    
    /// 用户头像地址（中图），50×50像素
    @objc var profile_image_url: String?
    
    /// 用户认证类型  没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    @objc var verified_type: Int = -1
    
    /// 会员等级 ,取值范围 1~6
    @objc var mbrank: Int = -1
    
    
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    
    override var description: String {
        let property = ["idstr", "screen_name", "profile_image_url", "verified_type"]
        let dict = dictionaryWithValues(forKeys: property)
        return "\(dict)"
    }
}
