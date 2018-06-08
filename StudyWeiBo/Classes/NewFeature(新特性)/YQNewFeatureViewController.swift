//
//  YQNewFeatureViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/16.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import SDWebImage

class YQNewFeatureViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var iconBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let userAccount = YQUserAccountModal.loadUserAccount() else {
            YQLog("没有用户信息")
            return
        }
        guard let url = URL(string: userAccount.avatar_large!) else {
            return
        }
        
        iconImageView.layer.cornerRadius = iconImageView.bounds.width * 0.5
        iconImageView.clipsToBounds = true
        
        iconImageView.setImageWith(url, placeholderImage: UIImage(named: "avatar_default_big"))
        
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        iconBottomConstraint.constant = kScreenH - 100 - iconImageView.bounds.height
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
          
            UIView.animate(withDuration: 1.0, animations: {
                self.welcomeLabel.alpha = 1.0
            }, completion: { (Bool) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushVC"), object: nil, userInfo: ["homePage":true])
            })
        }
    }

}
