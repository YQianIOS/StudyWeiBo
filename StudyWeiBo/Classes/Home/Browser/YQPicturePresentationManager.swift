//
//  YQPicturePresentationManager.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2018/6/12.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

import UIKit

protocol YQPicturePresentationManagerDelegate: class {
    /// 用于创建一个和点击图片一模一样的UIImageView
    func browserPresentationWillShowImageView(browserPresenationManager: YQPicturePresentationManager, indexPath: IndexPath) -> UIImageView
    
    /// 用于获取点击图片相对于window的frame
    func browserPresentationWillFromFrame(browserPresenationManager: YQPicturePresentationManager, indexPath: IndexPath) -> CGRect
    
    /// 用于获取点击图片最终的frame
    func browserPresentationWillToFrame(browserPresenationManager: YQPicturePresentationManager, indexPath: IndexPath) -> CGRect
}

class YQPicturePresentationManager: NSObject {

    fileprivate var isPresent: Bool = false
    
    fileprivate weak var delegate: YQPicturePresentationManagerDelegate?
    
    fileprivate var indexPath: IndexPath?
    
    func setDelegateData(delegate: YQPicturePresentationManagerDelegate, indexPath: IndexPath) {
        self.delegate = delegate
        self.indexPath = indexPath
    }
}

extension YQPicturePresentationManager: UIViewControllerTransitioningDelegate {
    //  该方法用于返回一个负责转场动画的对象
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return UIPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    //  展现视图会调用这个方法
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }
    
     //  视图消失时会调用这个方法
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
}

extension YQPicturePresentationManager: UIViewControllerAnimatedTransitioning {
    //  转场动画的时长 (统一管理)
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
     //  专门用于管理Modal如何出现或消失   出现和消失都会调用这个方法
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {  //  展现
            
            willPresentViewController(transitionContext: transitionContext)
            
        } else {  //  消失
            
            willDismissViewController(transitionContext: transitionContext)
            
        }
        
    }
    
    //  展现
    private func willPresentViewController(transitionContext: UIViewControllerContextTransitioning) {
        
        assert(delegate != nil, "browserPresenationManager 不能为空")
        assert(indexPath != nil, "indexPath 不能为空")
        
        // 获取需要弹出的视图控制器的 view
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            return
        }
        
        let imageView = delegate!.browserPresentationWillShowImageView(browserPresenationManager: self, indexPath: indexPath!)
        
        let rect = delegate!.browserPresentationWillFromFrame(browserPresenationManager: self, indexPath: indexPath!)
        
        let toFrame = delegate!.browserPresentationWillToFrame(browserPresenationManager: self, indexPath: indexPath!)
        
        imageView.frame = rect
        transitionContext.containerView.addSubview(imageView)
        
        UIView.animate(withDuration: 1.0, animations: {
            imageView.frame = toFrame
        }) { (_) in
            imageView.removeFromSuperview()
            
            transitionContext.containerView.addSubview(toView)
            
            // 告诉系统动画执行完毕
            transitionContext.completeTransition(true)
        }
        
    }
    
    private func willDismissViewController(transitionContext: UIViewControllerContextTransitioning) {

        // 获取需要弹出的视图控制器的 view
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        var fromCollectionView: UICollectionView?
        for view in fromView.subviews {
            if view.isKind(of: UICollectionView.self) {
                fromCollectionView = view as? UICollectionView
            }
        }
        
        guard let collectionView = fromCollectionView else {
            YQLog("未找到 collectionView")
            return
        }
        let index = Int(collectionView.contentOffset.x / kScreenW)
        YQLog(index)
        let indexPath = IndexPath(item: index, section: 0)
        
        let imageView = delegate!.browserPresentationWillShowImageView(browserPresenationManager: self, indexPath: indexPath)
        
        let toFrame = delegate!.browserPresentationWillFromFrame(browserPresenationManager: self, indexPath: indexPath)
        
        let rect = delegate!.browserPresentationWillToFrame(browserPresenationManager: self, indexPath: indexPath)
        
        fromView.removeFromSuperview()
        transitionContext.containerView.addSubview(imageView)
        imageView.frame = rect
        UIView.animate(withDuration: 1.0, animations: {
            imageView.frame = toFrame
        }) { (_) in
            imageView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
