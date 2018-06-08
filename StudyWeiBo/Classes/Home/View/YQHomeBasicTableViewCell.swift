//
//  YQHomeBasicTableViewCell.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/12/13.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import SDWebImage

private let kPictureCollectionViewCell : String = "kPictureCollectionViewCell"

private let kItemMargin : CGFloat = 10
private let kItemWidth : CGFloat = 90
private let kItemHeight : CGFloat = 90

class YQHomeBasicTableViewCell: UITableViewCell {
    
    /// 配图collectionView
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    /// 配图流水布局
    private lazy var flowLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    //  collectionView 宽度约束
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    /// collectionView 高度约束
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var vipImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    var homeViewModal : YQHomeViewModal? {
        didSet {
            // 设置头标
            iconImageView.sd_setImage(with: homeViewModal?.profileImageUrl, placeholderImage: UIImage(named: "avatar_default_small"))
            
            // 设置昵称
            nameLabel.text = homeViewModal?.status?.user?.screen_name
            
            // 设置会员图标
            vipImageView.image = homeViewModal?.memberImage
            
            // 设置时间: Wed Nov 29 15:46:29 +0800 2017
            timeLabel.text = homeViewModal?.publicTime
            
            // 设置来源: <a href=\"http://app.weibo.com/t/feed/6vtZb0\" rel=\"nofollow\">微博 weibo.com</a>
            sourceLabel.text = homeViewModal?.sourceString
            
            // 设置正文
            contentLabel.text = homeViewModal?.status?.text
            
            // 设置用户认证
            verifiedImageView.image = homeViewModal?.verifiedImage
            
            //  刷新配图的数据
            pictureCollectionView.reloadData()
            //  更新配图的尺寸
            let collectionViewSize : (cellSize : CGSize, collectionSize : CGSize) = calculateImageContentSize()
            
            if collectionViewSize.cellSize != CGSize.zero {
                self.flowLayout.itemSize = collectionViewSize.cellSize
            }
            // collectionView的宽高约束( 命名弄反了 )
            collectionViewWidthConstraint.constant = collectionViewSize.collectionSize.height
            collectionViewHeightConstraint.constant = collectionViewSize.collectionSize.width
            
        }
    }

    /// 计算cell和collectionview的尺寸
    private func calculateImageContentSize() -> (CGSize,CGSize){
        /*
         没有配图: cell = zero, collectionview = zero
         一张配图: cell = image.size, collectionview = image.size
         四张配图: cell = {90, 90}, collectionview = {2*w+m, 2*h+m}
         其他张配图: cell = {90, 90}, collectionview =
         */
        let picCount = homeViewModal?.thumbnail_pic?.count ?? 0
        // 没有配图
        if picCount == 0 {
            return (CGSize.zero, CGSize.zero)
        }
        // 一张配图
        if picCount == 1 {
            let image : UIImage? = SDWebImageManager.shared().imageCache?.imageFromDiskCache(forKey: homeViewModal?.thumbnail_pic?.first?.absoluteString)
            let imageSize : CGSize = image?.size ?? CGSize.zero
            return (imageSize, imageSize)
        }
        // 四张配图
        if picCount == 4 {
            let cellSize : CGSize = CGSize(width: kItemWidth, height: kItemHeight)
            let collectionSize : CGSize = CGSize(width: 2 * kItemWidth + kItemMargin, height: 2 * kItemHeight + kItemMargin)
            return (cellSize, collectionSize)
        }
        // 其他张配图
        let col = picCount == 2 ? 2 : 3
        //        let col = 3
        let row = (picCount - 1) / 3 + 1
        let collectionSize : CGSize = CGSize(width: CGFloat(col) * kItemWidth + CGFloat((col - 1)) * kItemMargin, height: CGFloat(row) * kItemHeight + CGFloat(row - 1) * kItemMargin)
        return (CGSize(width: kItemWidth, height: kItemHeight), collectionSize)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = iconImageView.bounds.width * 0.5
        iconImageView.layer.masksToBounds = true
        
        //  设置正文的最大宽度
        contentLabel.preferredMaxLayoutWidth = kScreenW - 2 * 10
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: kItemWidth, height: kItemHeight)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        
        self.flowLayout = flowLayout
        
        pictureCollectionView.collectionViewLayout = self.flowLayout
        pictureCollectionView.bounces = false
        pictureCollectionView.delegate = self
        pictureCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kPictureCollectionViewCell)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: -- UICollectionViewDataSource 协议方法
extension YQHomeBasicTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeViewModal?.thumbnail_pic?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPictureCollectionViewCell, for: indexPath)
        
        let pictureImageView = UIImageView(frame: cell.bounds)
        pictureImageView.sd_setImage(with: homeViewModal?.thumbnail_pic?[indexPath.item])
        pictureImageView.contentMode = UIViewContentMode.scaleAspectFill
        pictureImageView.clipsToBounds = true   // 要加这个  这个模型才有效
        
        cell.contentView.addSubview(pictureImageView)
        
        return cell
    }
}

// MARK: -- UICollectionViewDelegate 协议方法
extension YQHomeBasicTableViewCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
