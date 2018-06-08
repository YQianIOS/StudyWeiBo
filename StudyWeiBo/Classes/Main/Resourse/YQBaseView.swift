//
//  YQBaseView.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/6.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQBaseView: UIView {
    
    
    @IBOutlet weak var visitorImageView: UIImageView!

    class func creatBaseView() -> YQBaseView {
        return Bundle.main.loadNibNamed("YQBaseView", owner: nil, options: nil)?.last as! YQBaseView
    }
    
    func setupViewInfo() {
        //  图片旋转
        
        // 1 创建动画
        let basicAni = CABasicAnimation(keyPath: "transform.rotation")
        basicAni.repeatCount = MAXFLOAT
        basicAni.toValue = Double.pi * 2
        basicAni.duration = 5
        //  此属性: 离开此页面后 动画不会停止...
        basicAni.isRemovedOnCompletion = false
        visitorImageView.layer.add(basicAni, forKey: nil)
    }

}
