//
//  YQUserAccountModal.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/14.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import Foundation

class YQUserAccountModal: NSObject, NSCoding {
    
    // 令牌
    var access_token : String?
    //过期时间
    var expires_in : Int = 0 {
        didSet {
            overDate = NSDate(timeIntervalSinceNow: TimeInterval(expires_in))
        }
    }
    // 用户ID
    var uid : String?
    // 过期时间
    var overDate : NSDate?
    //  用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    // 用户昵称
    var screen_name: String?
    
    // 存储数据
    static var userAccountModal : YQUserAccountModal?
    
    // 缓存文件的路径
    private static let fileStr : String = "userAccount.plist".getCachesDirector()
    
    init(dict : [String: AnyObject]) {
        super.init()
        
        setValuesForKeys(dict)
    }
    
    override var description: String {
        let property = ["access_token","expires_in","uid","overDate","avatar_large","screen_name"]
        let dict : [String : Any] = dictionaryWithValues(forKeys: property)
        return ("\(dict)")
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    // 解归档模型
    class func loadUserAccount() -> YQUserAccountModal? {
        if userAccountModal != nil {
            return userAccountModal
        }
        
        
        guard let userAccount = NSKeyedUnarchiver.unarchiveObject(withFile: fileStr) as? YQUserAccountModal else {
            return userAccountModal
        }

        guard let date = userAccount.overDate, date.compare(NSDate() as Date) != ComparisonResult.orderedAscending else {
            YQLog("令牌已经过期了")
            return nil
        }
        
        userAccountModal = userAccount
        return userAccount
    }
    
    // 将数据保存进缓存文件中
    func saveAccount() -> Bool {
        
        return NSKeyedArchiver.archiveRootObject(self, toFile: YQUserAccountModal.fileStr)
    }
    
    // 判断是否已登录
    class func isLogin() -> Bool {
        
        return loadUserAccount() != nil
    }
    
    // MARK: -- 获取用户信息的请求
    func getUserInfo(finished : @escaping (_ userAccount: YQUserAccountModal?, _ err: Error?) -> ()) {
        // 1. 创建请求头
        let headerStr = "2/users/show.json"
        
        // 断言
        assert(access_token != nil, "必须授权之后才能显示欢迎界面")
       
        // 2. 创建参数
        let parameters = ["access_token": access_token!, "uid": uid!]
        
        YQNetworkTools.shareInstance.get(headerStr, parameters: parameters, progress: nil, success: { (task, objc) in
            
            guard let infoDict = objc as? [String: AnyObject] else {
                YQLog("用户信息请求错误")
                return
            }
            self.avatar_large = infoDict["avatar_large"] as? String
            self.screen_name = infoDict["screen_name"] as? String
            
            finished(self,nil)
            
        }) { (taskError, error) in
            finished(nil, error)
        }
        
    }
    
    
    // MARK: -- 归档及解档
        // 归档
    func encode(with aCoder: NSCoder) {
        aCoder.encode(access_token, forKey: "access_token")
        aCoder.encode(expires_in, forKey: "expires_in")
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(overDate, forKey: "overDate")
        aCoder.encode(avatar_large, forKey: "avatar_large")
        aCoder.encode(screen_name, forKey: "screen_name")
    }
        // 解档
    required init?(coder aDecoder: NSCoder) {
        self.access_token = aDecoder.decodeObject(forKey: "access_token") as? String
        self.expires_in = aDecoder.decodeInteger(forKey: "expires_in")
        self.uid = aDecoder.decodeObject(forKey: "uid") as? String
        self.overDate = aDecoder.decodeObject(forKey: "overDate") as? NSDate
        self.avatar_large = aDecoder.decodeObject(forKey: "avatar_large") as? String
        self.screen_name = aDecoder.decodeObject(forKey: "screen_name") as? String
    }
}
