//
//  YQTitleButton.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/7.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQTitleButton: UIButton {

    init(frame : CGRect, title : String, target: Any?, action: Selector, forState: UIControlEvents) {
        super.init(frame: frame)
        setImage(UIImage(named: "navigationbar_arrow_down"), for: .normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected)
        setTitle(title + "  ", for: .normal)
        setTitleColor(UIColor.darkGray, for: .normal)
        
        addTarget(target, action: action, for: forState)
        
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleRect : CGRect = (titleLabel?.frame)!
        let imageViewRect : CGRect = (imageView?.frame)!

        guard (titleRect.origin.x > imageViewRect.origin.x) else {
            return
        }
        titleLabel?.frame = titleRect.offsetBy(dx: -(imageView?.bounds.width)!, dy: 0)
        imageView?.frame = imageViewRect.offsetBy(dx: (titleLabel?.bounds.width)!, dy: 0)
        
//        titleLabel?.frame.origin.x = 0
//        imageView?.frame.origin.x = (titleLabel?.bounds.width)! + 5
        
    }

}
// MARK: -- 事件处理
extension YQTitleButton {
    @objc fileprivate func titleBtnClick(button: UIButton) {
     
        button.isSelected = !button.isSelected
    }
}
