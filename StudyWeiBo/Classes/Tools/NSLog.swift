//
//  NSLog.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/2.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

// 自定义打印信息
func YQLog<Type>(_ message : Type, fileName : String = #file, methodName : String = #function, lineNumber : Int = #line) {
    //  两种方法截取字符串都可以
//    let file : String = (fileName as NSString).components(separatedBy: "/").last!
    
      #if DEBUG    //  也可以直接用系统的...
//    #if HEIHEI   //  HEIHEI  为自定义的debug标记
    let file : String = (fileName as NSString).pathComponents.last!
    let className : String = (file as NSString).components(separatedBy: ".").first!
    
    print("\(className).\(methodName)[\(lineNumber)]: \(message)")
    
    #endif
}
