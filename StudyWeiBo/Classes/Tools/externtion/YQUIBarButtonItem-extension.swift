//
//  YQUIBarButtonItem-extension.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/7.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    convenience init(imageName: String, target: Any?, action: Selector, forEvent: UIControlEvents) {
        let leftBtn : UIButton = UIButton()
        leftBtn.setImage(UIImage(named: imageName), for: .normal)
        leftBtn.setImage(UIImage(named : imageName + "_highlighted"), for: .highlighted)
        //  尺寸必须要加  不然不会显示
        leftBtn.sizeToFit()
        
        leftBtn.addTarget(target, action: action, for: forEvent)
        self.init(customView: leftBtn)
    }
    
}
