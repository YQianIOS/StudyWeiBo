//
//  YQHomeViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/2.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

private let kHomeTableViewCell : String = "kHomeTableViewCell"

class YQHomeViewController: YQBaseTableViewController {
    
    fileprivate lazy var remindLabel: UILabel = {
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 44))
        titleLabel.backgroundColor = UIColor.orange
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.isHidden = true
        return titleLabel
    }()
    
    var isLastData: Bool = false
    
    fileprivate lazy var homeListVM: YQHomeListViewModal = YQHomeListViewModal()
    
    fileprivate lazy var animateManager : YQPresentationManager = YQPresentationManager()
    
    fileprivate lazy var refresh: YQRefreshControl = YQRefreshControl()
    
    fileprivate lazy var titleBtn : YQTitleButton = { [weak self] in
        let titleBtn : YQTitleButton = YQTitleButton(frame: CGRect.zero, title: "首页", target: self, action: #selector(titleBtnClick(button:)), forState: UIControlEvents.touchUpInside)
        return titleBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //  判断是否登录
        if !isLogin {
            baseView?.setupViewInfo()
            return
        }
        
        // 设置UI界面
        setupUI()
    }
    
    //  析构函数
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -- 设置UI界面
extension YQHomeViewController {
    fileprivate func setupUI() {
        
        //  设置导航栏
        setNavigationBar()
        
        tableView.register(UINib(nibName: "YQHomeTableViewCell", bundle: nil), forCellReuseIdentifier: kHomeTableViewCell)
        
        //  可以自动设置 行高
        tableView.estimatedRowHeight = 400
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        // 清除cell的分隔线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //  增加通知的观察者
        NotificationCenter.default.addObserver(self, selector: #selector(titleChange), name: NSNotification.Name(rawValue: presentationManagerDidPresent), object: animateManager)
        NotificationCenter.default.addObserver(self, selector: #selector(titleChange), name: NSNotification.Name(presentationManagerDidDismiss), object: animateManager)
        
        /// 添加下拉刷新
        refreshControl = refresh
        
        refreshControl?.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        refreshControl?.beginRefreshing()
    
        //  要给它设置一个背景颜色   自定义的刷新View 才会跟着下来
//        refreshControl?.backgroundColor = UIColor.white
        
        //  请求数据
        loadData()
    }
    
    @objc fileprivate func loadData() {
                
        homeListVM.loadDealData(isLastData)  { (count) in
            // 结束下拉刷新
            self.refreshControl?.endRefreshing()
            
            //  弹出提示Label
            if self.isLastData {
                self.showRefreshStatus(count)
            }
            
            //  刷新表格c
            self.tableView.reloadData()
        }
    }
    
    // MARK: -- 提示框弹出方法
    private func showRefreshStatus(_ dataCount: Int) {
        
        //  设置提示文本
        remindLabel.text = dataCount == 0 ? "没有新的数据" : "刷新到\(dataCount)条数据"
     
        self.remindLabel.isHidden = false
        
        if remindLabel.transform.ty == 0 {
            return
        }
        
        UIView.animate(withDuration: 1, animations: {
            self.remindLabel.transform = CGAffineTransform.init(translationX: 0, y: 44)
        }) { (_) in
            UIView.animate(withDuration: 1, delay: 2, options: UIViewAnimationOptions(rawValue: 0), animations: {
                self.remindLabel.transform = CGAffineTransform.identity
            }, completion: { (_)  in
                self.remindLabel.isHidden = true
            })
        }
    }
    
    // MARK: -- 设置导航栏
    private func setNavigationBar() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendattention", target: self, action: #selector(leftBarButtonItemClick(leftButton:)), forEvent: UIControlEvents.touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop", target: self, action: #selector(rightBarButtonItemClick), forEvent: UIControlEvents.touchUpInside)
        
        navigationItem.titleView = titleBtn
        
        
        navigationController?.navigationBar.insertSubview(remindLabel, at: 0)
    
    }
}
// MARK: -- 事件的处理
extension YQHomeViewController {
    @objc fileprivate func leftBarButtonItemClick(leftButton: UIBarButtonItem) {
        YQLog("")
    }
    @objc fileprivate func rightBarButtonItemClick() {
        guard let qrCodeVC = UIStoryboard.init(name: "QRCode", bundle: nil).instantiateInitialViewController() else {
            YQLog("创建控制器失败")
            return
        }
        present(qrCodeVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func titleBtnClick(button: UIButton) {
        
        let popoverVC : YQPopoverViewController = YQPopoverViewController()
        
        //  设置转场代理
        popoverVC.transitioningDelegate = animateManager
        //  设置转场动画样式 (自定义)
        popoverVC.modalPresentationStyle = UIModalPresentationStyle.custom
        
        present(popoverVC, animated: true, completion: nil)
    }
    
    @objc func titleChange() {
        titleBtn.isSelected = !titleBtn.isSelected
    }
}

// MARK: -- UITableViewDataSourse
extension YQHomeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeListVM.statusArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kHomeTableViewCell) as! YQHomeTableViewCell
        
        cell.homeViewModal = homeListVM.statusArr[indexPath.item]
        cell.delegate = self
        
        // 取消cell的选中状态
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if indexPath.row == homeListVM.statusArr.count - 1  {
            isLastData = true
            loadData()            
        } else {
            isLastData = false
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let homeVM = homeListVM.statusArr[indexPath.item]
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kHomeTableViewCell) as! YQHomeTableViewCell
        let height = cell.calculateCellHeight(viewModal: homeVM)
        YQLog(height)
        return height
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -60 {
            refresh.isBeginRefresh = true
        }
    }
    

}

extension YQHomeViewController: YQHomeBasicTableViewCellDelegate {
    func homeBasicTableViewCell(_ view: YQHomeBasicTableViewCell, pictureUrl: [URL]?, indexPath: IndexPath) {
        let pictureShowVC = YQPictureShowViewController(bmiddle_pic: pictureUrl, indexPath: indexPath)
        present(pictureShowVC, animated: true, completion: nil)
    }
}



