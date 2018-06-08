//
//  YQHomeViewModal.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/12/1.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQHomeViewModal: NSObject {
    

    var status: YQStatusModal?
    
    // MARK: -- 获取到的数据处理
    // 用户头像
    var profileImageUrl : URL?
    // 会员图标
    var memberImage : UIImage?
    // 认证图标
    var verifiedImage : UIImage?
    // 发布时间
    var publicTime : String?
    // 微博来源
    var sourceString : String?
    
    /// 保存所有配图URL
    var thumbnail_pic: [URL]?
    /// 保存所有配图大图URL
    var bmiddle_pic: [URL]?
    
    init(status: YQStatusModal ) {
        super.init()
        self.status = status
        
        // 用户头像
        profileImageUrl = URL(string: status.user?.profile_image_url ?? "")
        
        // 认证图标
        var verifiedImageName: String = ""
        
        switch status.user?.verified_type ?? -1 {
        case 0:
            verifiedImageName = "avatar_vip"
        case 2,3,5:
            verifiedImageName = "avatar_enterprise_vip"
        case 220:
            verifiedImageName = "avatar_grassroot"
        default:
            verifiedImageName = ""
        }
        verifiedImage = UIImage(named: verifiedImageName)
        
        // 会员图标
        if let memberRank = status.user?.mbrank {
            if memberRank > 0 && memberRank < 7 {
                memberImage = UIImage(named: "common_icon_membership_level\(memberRank)")
            }else {
                memberImage = UIImage(named: "")
            }
        }
        
        // 发布时间
        if let createDate = status.created_at {
            // 将服务器返回的时间格式化为Date
            let date = Date.createDate(dateStr: createDate, formatterStr: "EE MM dd HH:mm:ss Z yyyy")
            if let createTime = date {
                publicTime = createTime.descriptionStr()
            }
        }
        
        // 微博来源
        if let sourceStr = status.source, sourceStr != "" {
            // 对字符串进行截取
            let startLocation = (sourceStr as NSString).range(of: ">").location + 1
            let strLength = (sourceStr as NSString).range(of: "<", options: NSString.CompareOptions.backwards).location - startLocation  // 从后面往前数
            //                let strLength = (sourceStr as NSString) .range(of: "</").location - startLocation
            let str = (sourceStr as NSString).substring(with: NSRange(location: startLocation, length: strLength))
            sourceString = "来自: " + str
        }
        
        // 微博配图
        if let pics = status.pic_urls {
            // 一定要给数组分配内存空间
            thumbnail_pic = [URL]()
            bmiddle_pic = [URL]()
            
            for dictPic in pics {
                guard let picStr = dictPic["thumbnail_pic"] as? String else {
                    continue
                }
                let middlePicStr = picStr.replacingOccurrences(of: "thumbnail", with: "bmiddle")
                thumbnail_pic?.append(URL(string: picStr)!)
                bmiddle_pic?.append(URL(string: middlePicStr)!)
            }
        }
        
    }
}
