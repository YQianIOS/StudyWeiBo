//
//  YQMyQRCodeViewController.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/13.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

class YQMyQRCodeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建一个二维码滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        //  滤镜恢复默认设置
        filter?.setDefaults()
        //  给滤镜添加数据
        let dataStr : String = "Hello world"
        guard let data = dataStr.data(using: String.Encoding.utf8) else {
            return
        }
        //  利用kvc给滤镜赋值
        filter?.setValue(data, forKey: "inputMessage")
        
        //  返回图片
        guard let ciImage = filter?.outputImage else {
            return
        }
        
        imageView.image = createNonInterpolatedUIImageFormCIImage(image: ciImage, size: 500)
        
    }

    /**
     生成高清二维码
     
     - parameter image: 需要生成原始图片
     - parameter size:  生成的二维码的宽高
     */
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        
        // 1.创建bitmap;
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale);
        bitmapRef.draw(bitmapImage, in: extent)
        
        // 2.保存bitmap到图片
        let scaledImage: CGImage = bitmapRef.makeImage()!
        
        return UIImage(cgImage: scaledImage)
    }

}
