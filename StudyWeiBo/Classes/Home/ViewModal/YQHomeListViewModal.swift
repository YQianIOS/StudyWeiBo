//
//  YQHomeListViewModal.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2018/6/8.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class YQHomeListViewModal: NSObject {
    
    lazy var statusArr: [YQHomeViewModal] = [YQHomeViewModal]()
    
    func loadDealData(_ isLastData: Bool, finishCallBack: @escaping (_ count : Int) -> ()) {
        var sinde_id = statusArr.first?.status?.idstr ?? "0"
        var max_id = "0"
        if isLastData {
            sinde_id = "0"
            let indexStr = statusArr.last?.status?.idstr ?? "0"
            let lastIndex = Int(indexStr) ?? 0
            max_id = lastIndex == 0 ? "0" : "\(lastIndex - 1)"
        }
        
        // 发送网络请求
        YQNetworkTools.shareInstance.requestHomePageData(sindeId: sinde_id, max_id: max_id, finish: { (result, error) in
            
            guard error == nil else {
                SVProgressHUD.showError(withStatus: "获取微博数据失败")
                SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                return
            }
            guard result != nil else {
                return
            }
            
            var statusModals: [YQHomeViewModal] = [YQHomeViewModal]()
            for statusDic in result! {
                let statusModal = YQStatusModal(dict: statusDic)
                statusModals.append(YQHomeViewModal(status: statusModal))
            }
            
            // 3.处理微博数据
            if sinde_id != "0"{
                self.statusArr = statusModals + self.statusArr
            } else if max_id != "0" {
                self.statusArr = self.statusArr + statusModals
            } else {
                self.statusArr = statusModals
            }
            //            self.tableView.reloadData()
            self.cachePicture(statusModals: statusModals, finishCallBack)
            
        })
    }
    private func cachePicture(statusModals: [YQHomeViewModal], _ finishCallBack: @escaping (_ count : Int) -> ()) {
        
        // 0.创建一个组
        let group = DispatchGroup.init()
        
        for statusModal in statusModals {
            //  将下载的任务添加到组里
            
            guard let picUrlArr = statusModal.thumbnail_pic else {
                continue
            }
            for picUrl  in picUrlArr {
                group.enter()
                SDWebImageManager.shared().loadImage(with: picUrl, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, data, error, _, _, _) in
                    //  下载任务完成后离开组
                    group.leave()
                    
                })
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            finishCallBack(statusModals.count)
        }
        
    }
}
