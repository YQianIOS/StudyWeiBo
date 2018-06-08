//
//  String-extention.swift
//  StudyWeiBo
//
//  Created by yizhiton on 2017/11/15.
//  Copyright © 2017年 yizhiton. All rights reserved.
//

import UIKit

extension String {
    
    // 获取缓存目录的路径
    func getCachesDirector() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        let nameStr = (self as NSString).lastPathComponent
        let pathStr = (path as NSString) .appendingPathComponent(nameStr)
        
        return pathStr
    }
    
    // 快速生成文档路径
    func getDocumentDirector() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        let nameStr = (self as NSString).lastPathComponent
        let pathStr = (path as NSString) .appendingPathComponent(nameStr)
        
        return pathStr
    }
    
    // 快速生成临时路径
    func getTemporaryDirector() -> String {
        let path = NSTemporaryDirectory()
        let nameStr = (self as NSString).lastPathComponent
        let pathStr = (path as NSString) .appendingPathComponent(nameStr)
        
        return pathStr
    }
}
