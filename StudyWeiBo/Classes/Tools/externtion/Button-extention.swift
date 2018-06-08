//
//  Button-extention.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/27.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(normalImage: String, highLightedImage: String?) {
        self.init()
        
        setImage(UIImage(named: normalImage), for: .normal)

        if highLightedImage != nil {
            setImage(UIImage(named: highLightedImage!), for: .highlighted)
        }
        
        sizeToFit()
    }
}

