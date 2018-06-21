//
//  YQHomeBasicTableViewCell.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/12/13.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import SDWebImage

private let kItemMargin : CGFloat = 10

class YQHomeBasicTableViewCell: UITableViewCell {
    
    /// 配图collectionView
    @IBOutlet weak var pictureCollectionView: YQPictureCollectionView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var vipImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    
        
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
            pictureCollectionView.homeViewModal = homeViewModal
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = iconImageView.bounds.width * 0.5
        iconImageView.layer.masksToBounds = true
        
        //  设置正文的最大宽度
        contentLabel.preferredMaxLayoutWidth = kScreenW - 2 * 10
        
    }

    // MARK: -- 计算cell的高度
    func calculateCellHeight(viewModal: YQHomeViewModal) -> CGFloat {
        let pickHeight = pictureCollectionView.imageContentSize(viewModal).1.height
        let contentLabelHeight = sizeWithText(viewModal.status?.text ?? "").height + 5
        return pickHeight + contentLabelHeight + 60 + 44 + 40
    }
    
    private func sizeWithText(_ text: String) -> CGSize {
        if text == "" {
            return CGSize.zero
        }
        return (text as NSString).boundingRect(with: CGSize(width: kScreenW - 2 * kItemMargin, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil).size
    }
}


