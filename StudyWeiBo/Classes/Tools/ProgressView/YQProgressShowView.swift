//
//  YQProgressShowView.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2018/6/20.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

import UIKit

class YQProgressShowView: UIView {

    var progress: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }

    override func draw(_ rect: CGRect) {
        
        // 当progress = 1.0 时停止绘制
        if  progress >= 1.0 {
            return
        }
        
        let width = rect.size.width
        let height = rect.size.height
        let radius = width > height ? height * 0.5 : width * 0.5
        let center = CGPoint(x: width * 0.5, y: height * 0.5)
        
        let startAngle = CGFloat(-Double.pi * 0.5)
        let endAngle = startAngle + progress * CGFloat(Double.pi * 2)
        
        let bezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle:startAngle , endAngle:endAngle, clockwise: true)
        bezierPath.addLine(to: center)
        bezierPath.close()
        UIColor.red.setFill()
        
        bezierPath.fill()
    }
}
