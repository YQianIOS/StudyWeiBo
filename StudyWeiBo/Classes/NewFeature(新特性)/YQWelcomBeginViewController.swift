//
//  YQWelcomBeginViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/16.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import SnapKit

class YQWelcomBeginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


}

// MARK: -- UICollectionView的代理方法
extension YQWelcomBeginViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "welcomCollectionCell", for: indexPath) as! YQWelcomCollectionViewCell
        
        cell.imageIndex = indexPath.item
        
        if indexPath.item == 3 {
            cell.startButtonAnimate()
        }
        
        return cell
    }
}

// MARK: -- UICollectionViewCell 的自定义
class YQWelcomCollectionViewCell : UICollectionViewCell {
    
    //  添加图片
//    private lazy var cellImageView : UIImageView = {
//        let imageView : UIImageView = UIImageView(frame: UIScreen.main.bounds)
//        return imageView
//    }()
    private lazy var cellImageView : UIImageView = UIImageView()
    
    private lazy var startButton : UIButton = {
        let startBtn : UIButton = UIButton(normalImage: "new_feature_button", highLightedImage: "new_feature_button_highlighted")
        startBtn.addTarget(self, action: #selector(startButtonClick), for: .touchUpInside)
        startBtn.layer.cornerRadius = 6
        return startBtn
    }()
    
    fileprivate var imageIndex = 0 {
        didSet{
            cellImageView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            
            if imageIndex == 3 {
                startButton.isHidden = false
            } else {
                startButton.isHidden = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 设置UI
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(startButton)
        // 添加约束(一定要先添加到控件上  才能再设置约束)
        cellImageView.snp.makeConstraints { (make) in
//            make.left.equalTo(0)
//            make.right.equalTo(0)
//            make.top.equalTo(0)
//            make.bottom.equalTo(0)
            make.edges.equalTo(0)
        }
        
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-60)
        }
        
    }
    
    fileprivate func startButtonAnimate() {
        startButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        startButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 2.0, animations: { 
            self.startButton.transform = CGAffineTransform.identity
        }) { (finish) in
            self.startButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func startButtonClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushVC"), object: nil, userInfo: ["homePage": true])
    }
}

// MARK: -- UICollectionView的流水布局
class YQWelcomCollectionViewFlowLayout : UICollectionViewFlowLayout {
    override func prepare() {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        itemSize = UIScreen.main.bounds.size
        
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.isPagingEnabled = true
    }
}
