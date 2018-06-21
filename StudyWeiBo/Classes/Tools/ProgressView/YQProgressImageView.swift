//
//  YQProgressImageView.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2018/6/20.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

import UIKit

class YQProgressImageView: UIImageView {
    
    private lazy var progressView: YQProgressShowView = YQProgressShowView()
    
    var progress: CGFloat = 0 {
        didSet {
            progressView.progress = progress
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(progressView)
        progressView.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = bounds
    }
}
