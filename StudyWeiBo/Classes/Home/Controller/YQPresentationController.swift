//
//  YQPresentationController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/9.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

private let kPresentViewW : CGFloat = 150
private let kPresentViewH : CGFloat = 150

class YQPresentationController: UIPresentationController {
    
    private lazy var coverBtn : UIButton = { [weak self] in
        let coverBtn : UIButton = UIButton(frame: UIScreen.main.bounds)
        coverBtn.addTarget(self, action: #selector(coverBtnClick), for: .touchUpInside)
        return coverBtn
    }()

    // 用于布局转场动画弹出的控件
    override func containerViewWillLayoutSubviews() {
        //  containerView 这个属性很重要  是容器视图
        //  presentedView()  通过该方法能够拿到弹出的视图
        
        //  设置弹出视图的尺寸
        presentedView?.frame = CGRect(x: (kScreenW - kPresentViewW) / 2, y: 44, width: kPresentViewW, height: kPresentViewH)
        containerView?.insertSubview(coverBtn, at: 0)
        
    }
    
    @objc func coverBtnClick() {
        
        // 点击按钮时消失
          // presentedViewController 弹出的视图
          // presentingViewController  容器视图
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
