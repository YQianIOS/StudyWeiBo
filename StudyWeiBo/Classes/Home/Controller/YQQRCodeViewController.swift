//
//  YQQRCodeViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/10.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit
import AVFoundation

class YQQRCodeViewController: UIViewController {

    //  底部工具条
    @IBOutlet weak var tabBar: UITabBar!
    
    //  扫描线的约束
    @IBOutlet weak var scanLine: UIImageView!
    @IBOutlet weak var scanTopConstraint: NSLayoutConstraint!
    
    //  扫描框的高度
    @IBOutlet weak var scanViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var scanResultLabel: UILabel!
    
    
    
    fileprivate lazy var containView : UIView = { [weak self] in
        let containView : UIView = UIView(frame: self!.view.bounds)
        containView.backgroundColor = UIColor.clear
        return containView
    }()
    
    // MARK: -- 二维码扫描设置 -- 懒加载
        //  输入对象
    fileprivate lazy var inputCapture : AVCaptureDeviceInput? = {
        let device : AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        return try? AVCaptureDeviceInput(device: device)
    }()
    
        //  输出对象
    fileprivate lazy var outCapture : AVCaptureMetadataOutput = {
       let outCapture = AVCaptureMetadataOutput()
        
        // 设置输出对象解析数据时感兴趣的范围
        // 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
        // 通过对这个值的观察, 我们发现传入的是比例
        // 注意: 参照是以横屏的左上角作为, 而不是以竖屏
        // out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
        outCapture.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        return outCapture
    }()
    
        //  会话
    fileprivate lazy var session : AVCaptureSession = AVCaptureSession()
    
        //  添加预览图层
    fileprivate lazy var previewLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.selectedItem = tabBar.items?.first
        tabBar.delegate = self
        
        //  添加扫描功能
        addQrCode()
    }
    
    //  只能在这里开始动画, 此时视图才加载...
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  开始动画
        startAnimation()
    }

    @IBAction func leftBarButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rightBarButtonClick(_ sender: Any) {
        // 打开相册
          //  判断是否能够打开相册
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) else {
            YQLog("打开相册失败")
            return
        }
        
        //  创建相册控制器
        let imagePicker : UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: -- 打开相册选择图片的代理方法
extension YQQRCodeViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 获取相册中选中的图片
        guard let imageInfo = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            YQLog("获取图片失败")
            return
        }
        DispatchQueue.main.async {
            
            guard let ciImage = CIImage(image: imageInfo) else {
                return
            }
            
            //  识别选中图片的二维码
            //  创建一个探测器
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
            
            guard let results = detector?.features(in: ciImage) else {
                return
            }
            
            for result in results {
                YQLog((result as! CIQRCodeFeature).messageString)
            }
        }
    }
}

// MARK: -- 添加扫描功能
extension YQQRCodeViewController {
    fileprivate func addQrCode() {
        guard session.canAddInput(inputCapture) else {
            YQLog("添加输入对象失败")
            return
        }
        
        guard session.canAddOutput(outCapture) else {
            YQLog("添加输出对象失败")
            return
        }
        
        session.addInput(inputCapture)
        session.addOutput(outCapture)
        
        //  设置输出能够解析的数据类型
        outCapture.metadataObjectTypes = outCapture.availableMetadataObjectTypes
        //  监听输出解析出的数据
        outCapture.setMetadataObjectsDelegate(self, queue: DispatchQueue.main )
        
        //  添加预览视图
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = UIScreen.main.bounds
        
        //  添加扫描结果框的容器视图
        view.layer.addSublayer(containView.layer)
        
        //  开始扫描
        session.startRunning()
    }
}

// MARK: -- 扫描结果代理
extension YQQRCodeViewController : AVCaptureMetadataOutputObjectsDelegate {
    //  只要扫描到结果就会调用
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //  不管有没有结果 都清除
        removeScanView()
        
        guard let metadataObject = metadataObjects.last as? AVMetadataObject else {
            YQLog("未解析出数据")
            return
        }
        // 转换前: corners { 0.3,0.7 0.5,0.7 0.5,0.4 0.3,0.4 }
        // 转换后: corners { 40.0,230.3 30.9,403.9 216.5,416.3 227.1,244.2 }
        // 通过预览图层将corners值转换为我们能识别的类型
        let metaData = previewLayer.transformedMetadataObject(for: metadataObject)
        guard let metaCodeObj = metaData as? AVMetadataMachineReadableCodeObject else {
            YQLog("AVMetadataMachineReadableCodeObject格式转换失败")
            return
        }
        // 绘制扫描图片
        drawScanView(metaCodeObj)
        
        scanResultLabel.text = (metadataObject as AnyObject).stringValue
    }
    
    // 绘制扫描图片
    private func drawScanView(_ metaCodeObj: AVMetadataMachineReadableCodeObject) {
        
        guard let corners = metaCodeObj.corners as? [[String : AnyObject]] else {
            YQLog("解析CGPoint数据失败")
            return
        }
        //  绘制图片的类
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2
        
        //  创建Bezier路径...
        let bezierPath = UIBezierPath()
        
        guard let firstPoint = CGPoint(dictionaryRepresentation: corners[0] as CFDictionary) else {
            YQLog("获取坐标点失败")
            return
        }
        bezierPath.move(to: firstPoint)
        
        for index in 1..<corners.count {
            guard let movePoint = CGPoint(dictionaryRepresentation: corners[index] as CFDictionary) else {
                YQLog("获取坐标点失败")
                return
            }
            bezierPath.addLine(to: movePoint)
        }
        // 封闭绘图
        bezierPath.close()
        // 将绘制的图添加到绘制层中
        shapeLayer.path = bezierPath.cgPath
        
        containView.layer.addSublayer(shapeLayer)
    }
    
    // 移除扫描结果框
    private func removeScanView() {
        guard let layers = containView.layer.sublayers else {
            return
        }
        for layer in layers {
            layer.removeFromSuperlayer()
        }
    }
    
}

// MARK: -- UITabBarDelegate代理方法
extension YQQRCodeViewController : UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        scanViewHeightContraint.constant = item.tag == 1 ? 150 : 250
        view.layoutIfNeeded()
        
        //  先移除之前的动画
        scanLine.layer.removeAllAnimations()
        
        //  再添加动画
        startAnimation()
    }
}

// MARK: -- 开始扫描动画
extension YQQRCodeViewController {
    fileprivate func startAnimation() {
        scanTopConstraint.constant = -scanViewHeightContraint.constant
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 2.0) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.scanTopConstraint.constant = self.scanViewHeightContraint.constant
            self.view.layoutIfNeeded()
        }
    }
}
