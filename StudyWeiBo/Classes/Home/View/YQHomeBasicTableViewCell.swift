//
//  YQHomeBasicTableViewCell.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/12/13.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import SDWebImage

private let kItemWidth : CGFloat = 90
private let kItemHeight : CGFloat = 90
private let kItemMargin : CGFloat = 10

protocol YQHomeBasicTableViewCellDelegate: class {
    func homeBasicTableViewCell(_ view: YQHomeBasicTableViewCell, pictureUrl: [URL]?, indexPath: IndexPath)
}

private let kPictureCollectionViewCell : String = "kPictureCollectionViewCell"

class YQHomeBasicTableViewCell: UITableViewCell {
    
    /// 配图collectionView
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    /// 配图流水布局
    private lazy var flowLayout : HomePictureFlowLayout = HomePictureFlowLayout()
    
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
    
    @IBOutlet weak var bottomView: UIView!
    
    
    weak var delegate: YQHomeBasicTableViewCellDelegate?
    
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
            contentLabel.frame.size.height = 60
            
            // 设置用户认证
            verifiedImageView.image = homeViewModal?.verifiedImage
            
            //  刷新配图的数据
            pictureCollectionView.reloadData()
            //  更新配图的尺寸
            let collectionViewSize : (cellSize : CGSize, collectionSize : CGSize) = imageContentSize(homeViewModal)
            
            if collectionViewSize.cellSize != CGSize.zero {
                self.flowLayout.itemSize = collectionViewSize.cellSize
            }
            // collectionView的宽高约束( 命名弄反了 )
            collectionViewWidthConstraint.constant = collectionViewSize.collectionSize.height
            collectionViewHeightConstraint.constant = collectionViewSize.collectionSize.width
        }
    }

    /// 计算cell和collectionview的尺寸
    private func imageContentSize(_ homeVM: YQHomeViewModal?) -> (CGSize,CGSize){
        
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = iconImageView.bounds.width * 0.5
        iconImageView.layer.masksToBounds = true
        
        //  设置正文的最大宽度
        contentLabel.preferredMaxLayoutWidth = kScreenW - 2 * 10
        
        pictureCollectionView.delegate = self
        pictureCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kPictureCollectionViewCell)
    }
    
    // MARK: -- 计算cell的高度
    func calculateCellHeight(viewModal: YQHomeViewModal) -> CGFloat {
        let pickHeight = imageContentSize(viewModal).1.height
        let contentLabelHeight = sizeWithText(viewModal.status?.text ?? "").height + 5
        return pickHeight + contentLabelHeight + 60 + 44 + 40
    }
    
    private func sizeWithText(_ text: String) -> CGSize {
        if text == "" {
            return CGSize.zero
        }
        return (text as NSString).boundingRect(with: CGSize(width: kScreenW - 2 * kItemMargin, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil).size
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
        delegate?.homeBasicTableViewCell(self, pictureUrl: homeViewModal?.bmiddle_pic, indexPath: indexPath)
    }
}

class HomePictureFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        itemSize = CGSize(width: kItemWidth, height: kItemHeight)
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        
        collectionView?.bounces = false
    }
}
