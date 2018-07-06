//
//  YQPictureCollectionView.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2018/6/20.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

import UIKit
import SDWebImage

private let kItemWidth : CGFloat = 90
private let kItemHeight : CGFloat = 90
private let kItemMargin : CGFloat = 10
private let kPictureCollectionViewCell : String = "kPictureCollectionViewCell"

protocol YQPictureCollectionViewDelegate: class {
    func homeBasicTableViewCell(_ view: YQPictureCollectionView, pictureUrl: [URL]?, indexPath: IndexPath)
}

class YQPictureCollectionView: UICollectionView {
    
    /// 配图流水布局
//    private lazy var flowLayout : HomePictureFlowLayout = HomePictureFlowLayout()

    @IBOutlet weak var pictureFlowLayout: UICollectionViewFlowLayout!
    
    //  collectionView 高度约束
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    /// collectionView 宽度约束
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    weak var pictureDelegate: YQPictureCollectionViewDelegate?

    
    var homeViewModal : YQHomeViewModal? {
        didSet {
            reloadData()
            //  更新配图的尺寸
            let (cellSize , collectionSize ) = imageContentSize(homeViewModal)
            
            if cellSize != CGSize.zero {
                pictureFlowLayout.itemSize = cellSize
            }
            // collectionView的宽高约束
            collectionViewWidthConstraint.constant = collectionSize.width
            collectionViewHeightConstraint.constant = collectionSize.height
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
        
        register(YQPictureCollectionViewCell.self, forCellWithReuseIdentifier: kPictureCollectionViewCell)
    }
    
    /// 计算cell和collectionview的尺寸
    func imageContentSize(_ homeVM: YQHomeViewModal?) -> (CGSize,CGSize){
        
        let picCount = homeVM?.thumbnail_pic?.count ?? 0
        // 一张配图: cell = image.size, collectionview = image.size
        if picCount == 1 {
            let image : UIImage? = SDWebImageManager.shared().imageCache?.imageFromDiskCache(forKey: homeVM?.thumbnail_pic?.first?.absoluteString)
            let imageSize : CGSize = image?.size ?? CGSize.zero
            return (imageSize, imageSize)
        } else {
            return homeVM?.pictureSize ?? (CGSize.zero, CGSize.zero)
        }
    }

}

// MARK: -- UICollectionViewDataSource 协议方法
extension YQPictureCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeViewModal?.thumbnail_pic?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPictureCollectionViewCell, for: indexPath) as! YQPictureCollectionViewCell
        cell.url = homeViewModal?.thumbnail_pic![indexPath.item]
        
        return cell
    }
}

// MARK: -- UICollectionViewDelegate 协议方法
extension YQPictureCollectionView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = homeViewModal?.bmiddle_pic![indexPath.item]
        let collectionCell = collectionView.cellForItem(at: indexPath) as! YQPictureCollectionViewCell
        
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: SDWebImageDownloaderOptions(rawValue: 0), progress: { (current, total, url) in
            collectionCell.imageView.progress = CGFloat(current) / CGFloat(total)
        }, completed: { (image, data, error, _) in
            assert(error == nil, "高清图片下载失败")
            self.pictureDelegate?.homeBasicTableViewCell(self, pictureUrl: self.homeViewModal?.bmiddle_pic, indexPath: indexPath)
        })
    }
}

extension YQPictureCollectionView: YQPicturePresentationManagerDelegate {
    
    /// 用于创建一个和点击图片一模一样的UIImageView
    func browserPresentationWillShowImageView(browserPresenationManager: YQPicturePresentationManager, indexPath: IndexPath) -> UIImageView {
        
        let imageView: UIImageView = UIImageView()
        
        // 获取缓存里的图片
        imageView.sd_setImage(with: homeViewModal!.bmiddle_pic![indexPath.item])
        imageView.sizeToFit()
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    /// 用于获取点击图片相对于window的frame
    func browserPresentationWillFromFrame(browserPresenationManager: YQPicturePresentationManager, indexPath: IndexPath) -> CGRect {
        
        let collectionView = cellForItem(at: indexPath)!
        
        let rect = self.convert(collectionView.frame, to: UIApplication.shared.keyWindow)
        return CGRect(x: rect.origin.x , y: rect.origin.y, width: rect.size.width, height: rect.size.height)
    }
    
    /// 用于获取点击图片最终的frame
    func browserPresentationWillToFrame(browserPresenationManager: YQPicturePresentationManager, indexPath: IndexPath) -> CGRect {
        
        let data = NSData(contentsOf: homeViewModal!.bmiddle_pic![indexPath.item])
        
        guard let imageData = data as Data?, let image = UIImage(data: imageData) else {
            YQLog("获取大图失败")
            return CGRect.zero
        }
        // 拿到大图
        let imageSize = image.size
        let scale = imageSize.height / imageSize.width
        let imageHeight = scale * kScreenW
        
        var offsetY : CGFloat = 0.0
        if imageHeight < kScreenH {
            offsetY = ( kScreenH - imageHeight ) * 0.5
        }
        
       return CGRect(x: 0, y: offsetY, width: kScreenW, height: imageHeight)
        
    }
}

class YQPictureCollectionViewCell: UICollectionViewCell {
    var url: URL? {
        didSet {
            imageView.sd_setImage(with: url)
            
            //  gif 图标的显隐
            if  let flag = url?.absoluteString.lowercased().hasSuffix("gif") {
                gifImageView.isHidden = !flag
            }

        }
    }
    
    lazy var imageView: YQProgressImageView = {
        let pictureImageView = YQProgressImageView(frame: bounds)
        pictureImageView.contentMode = UIViewContentMode.scaleAspectFill
        pictureImageView.clipsToBounds = true   // 要加这个  这个模型才有效
        return pictureImageView
    }()
    
    lazy var gifImageView: UIImageView = {
        let gifImageView: UIImageView = UIImageView(image: UIImage(named: "gif"))
        gifImageView.sizeToFit()
        return gifImageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(imageView)
        addSubview(gifImageView)
        
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        var constrait = NSLayoutConstraint.constraints(withVisualFormat: "H:[gifImageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gifImageView": gifImageView])
        constrait += NSLayoutConstraint.constraints(withVisualFormat: "V:[gifImageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gifImageView": gifImageView])
        addConstraints(constrait)
    }
}

