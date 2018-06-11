//
//  YQRefreshView.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/12/14.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import SnapKit

class YQRefreshControl: UIRefreshControl {
    
    private lazy var refreshView : YQRefreshView = YQRefreshView.creatRefreshView()
    
    lazy var isAnimate: Bool = false;
    
    private var rotationFlag : Bool = false
    
    override init() {
        super.init()
        backgroundColor = UIColor.white
        addSubview(refreshView)
        
        refreshView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 150, height: bounds.size.height))
            make.center.equalTo(self)
        }
        
        //  增加观察者  观察 frame 值的变化
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                
        if frame.origin.y == 0 || frame.origin.y == -64 {
            return
        }
        
        // 刷新状态触发
        if isRefreshing {
            // 开始刷新
            refreshView.startRefresh()
            return
        }
        
        if frame.origin.y > -50 && rotationFlag {
            rotationFlag = false
            refreshView.rotationArrowMethod(flag: rotationFlag)
            
        } else if frame.origin.y < -50 && !rotationFlag{
            rotationFlag = true
            refreshView.rotationArrowMethod(flag: rotationFlag)
            
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        refreshView.stopRefresh()
    }
   
}

class YQRefreshView: UIView {

    @IBOutlet weak var arrowImageView: UIImageView!
   
    @IBOutlet weak var refreshLabel: UILabel!

    @IBOutlet weak var showView: UIView!
    
    @IBOutlet weak var refreshImageView: UIImageView!
    
    class func creatRefreshView() -> YQRefreshView {
        return Bundle.main.loadNibNamed("RefreshView", owner: nil, options: nil)?.last as! YQRefreshView
    }
    
    
    // 开始刷新方法
    fileprivate func startRefresh() {
        
        guard refreshImageView.layer.animation(forKey: "refreshing") == nil else {
            return
        }
        
       showView.isHidden = true
        
        // 1.创建动画
        let anim =  CABasicAnimation(keyPath: "transform.rotation")
        anim.duration = 2
        anim.toValue = 2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false
        //  将动画加到图层上
        refreshImageView.layer.add(anim, forKey: "refreshing")
    }
    
    //  停止刷新的方法
    fileprivate func stopRefresh() {
        showView.isHidden = false
        refreshImageView.layer.removeAllAnimations()
    }
    
    // 旋转箭头的方法
    fileprivate func rotationArrowMethod(flag : Bool) {
        
        var angle : CGFloat = flag ? -0.01 : 0.01
        let refreshText : String = flag ? "松开刷新" : "下拉刷新"
        
        angle += CGFloat(Double.pi)
        UIView.animate(withDuration: 0.5) {
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: angle)
            self.refreshLabel.text = refreshText
        }
        
    }
    
    
}
