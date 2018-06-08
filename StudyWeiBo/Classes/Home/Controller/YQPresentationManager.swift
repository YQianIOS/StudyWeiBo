//
//  YQPresentationManager.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/9.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQPresentationManager: NSObject {
    
     fileprivate var isPresent : Bool = false
    
}

// MARK: --  UIViewControllerTransitioningDelegate 代理方法
extension YQPresentationManager : UIViewControllerTransitioningDelegate {
    //  该方法用于返回一个负责转场动画的对象
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return YQPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    //  该方法用于返回一个负责转场如何出现的对象
      //  展现视图会调用这个方法
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //  展现
        isPresent = true
        
        //  展现视图时发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentationManagerDidPresent), object: self)
        return self
    }
    
    //  该方法用于返回一个负责转场如何消失的对象
      //  视图消失时会调用这个方法
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //  消失
        isPresent = false
        
        //  视图消失时发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentationManagerDidDismiss), object: self)
        return self
    }

}

extension YQPresentationManager : UIViewControllerAnimatedTransitioning {
    //  转场动画的时长 (统一管理)
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    //  专门用于管理Modal如何出现或消失   出现和消失都会调用这个方法
    //  所以动画需要的参数都放在这里: transitionContext
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //  方法抽取   保证方法里的功能单一性
        
        if isPresent {  //  展现
            
            willPresentViewController(transitionContext: transitionContext)
            
        } else {  //  消失
            
            willDismissViewController(transitionContext: transitionContext)
            
        }
    }
    
    // 展示的方法
    private func willPresentViewController(transitionContext: UIViewControllerContextTransitioning) {
        
        //  1. 获取需要弹出的视图
        /*
         transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)  // 需要添加的视图控制器
         transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)  // 添加到某视图控制器上
         */
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            YQLog("获取需要添加的视图控制器失败")
            return
        }
        //  let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        
        //  2. 添加视图
        transitionContext.containerView.addSubview(toView)
        
        //  3. 执行动画
        toView.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
        toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.transform = CGAffineTransform.identity
        }) { (_) in
            //  动画完成后  一定要告诉系统动画执行完毕了
            transitionContext.completeTransition(true)
        }

    }
    
    // 消失的方法
    private func willDismissViewController(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.transform = CGAffineTransform(scaleX: 1.0, y: 0.0001)
        }, completion: { (_) in
            transitionContext.completeTransition(true)
        })
    }

}
