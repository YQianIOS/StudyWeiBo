//
//  YQPictureShowViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2018/6/9.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

import UIKit

private let collectionViewCell: String = "pictureCell"

class YQPictureShowViewController: UIViewController {

    /// 显示大图URL
    var bmiddle_pic: [URL]?
    var indexPath: IndexPath
    
    fileprivate lazy var collectionView: UICollectionView = { [weak self] in
        let collectionView = UICollectionView(frame: self!.view.bounds, collectionViewLayout: PictureFlowLayout())
        
        collectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCell)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    fileprivate lazy var closeButton: UIButton = {
       let btn = UIButton(type: UIButtonType.custom)
        btn.setTitle("关闭", for: UIControlState.normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: #selector(closeButtonClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    fileprivate lazy var saveButton: UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setTitle("保存", for: UIControlState.normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: #selector(saveButtonClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    init(bmiddle_pic: [URL]?, indexPath: IndexPath) {
        self.bmiddle_pic = bmiddle_pic;
        self.indexPath = indexPath;
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
    }
    private func setupUI() {
        view.addSubview(collectionView)
        
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        let dict = ["closeButton": closeButton, "saveButton": saveButton]
        let closeHConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[closeButton(100)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        let closeVConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[closeButton(44)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        
        let saveHConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[saveButton(100)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        let saveVConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[saveButton(44)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        
        view.addConstraints(closeHConstraint)
        view.addConstraints(closeVConstraint)
        view.addConstraints(saveHConstraint)
        view.addConstraints(saveVConstraint)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: false)
    }
    
}

// MARK: -- 内部控制方法
extension YQPictureShowViewController {
    @objc func saveButtonClick() {
        
    }
    @objc func closeButtonClick() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: -- 代理方法: UICollectionViewDataSource, UICollectionViewDelegate
extension YQPictureShowViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bmiddle_pic?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCell, for: indexPath) as! PictureCollectionViewCell
        cell.imageUrl = bmiddle_pic?[indexPath.item]
        return cell
    }
    
}

// MARK: -- 自定义 UICollectionViewCell
class PictureCollectionViewCell: UICollectionViewCell {
    
    var imageUrl: URL? {
        didSet {
            guard let url = imageUrl else {
                return
            }
           
            imageView.sd_setImage(with: url) { [weak self] (image, error, _, _) in
//                self!.imageView.sizeToFit()
                
                guard let picture = image else {
                    return
                }
                let imageSize = picture.size
                let scale = imageSize.height / imageSize.width
                let height = scale * kScreenW
                self!.imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: kScreenW, height: height))
                
                if height < kScreenH {
                    let offset = (kScreenH - height ) * 0.5
                    self!.scrollView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: offset, right: 0)
                } else {
                    self!.scrollView.contentSize = CGSize(width: kScreenW, height: height)
                }
            }
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -- 自定义 UICollectionView 的布局
class PictureFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        itemSize = UIScreen.main.bounds.size
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
    }
}
