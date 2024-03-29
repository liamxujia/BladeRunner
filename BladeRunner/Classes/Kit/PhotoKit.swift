//
//  PhotoKit.swift
//  BladeRunner
//
//  Created by liam on 2020/8/3.
//

import UIKit
import MobileCoreServices
import SwifterSwift

class PhotoKit: NSObject {
    enum ImageType {
        case png
        case jpg
    }

    /// 根据传入图片数组创建gif动图
        ///
        /// - Parameters:
        ///   - images: 源图片数组
        ///   - imageName: 生成gif图片名称
        ///   - imageCuont: 图片总数量
    func compositionImage(_ images: [UIImage], _ imageName: String) {

        //在Document目录下创建gif文件
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let gifPath = docs[0] + "/\(imageName)" + ".gif"
        guard let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath as CFString, .cfurlposixPathStyle, false), let destinaiton = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) else { return }

        // 设置每帧图片播放时间
        let cgimageDic = [kCGImagePropertyGIFDelayTime as String: 0.1]
        let gifDestinaitonDic = [kCGImagePropertyGIFDictionary as String: cgimageDic]

        //添加gif图像的每一帧元素
        for cgimage in images {
            CGImageDestinationAddImage(destinaiton, (cgimage as AnyObject).cgImage!!, gifDestinaitonDic as CFDictionary)
        }

        // 设置gif的彩色空间格式、颜色深度、执行次数
        let gifPropertyDic = NSMutableDictionary()
        gifPropertyDic.setValue(kCGImagePropertyColorModelRGB, forKey: kCGImagePropertyColorModel as String)
        gifPropertyDic.setValue(16, forKey: kCGImagePropertyDepth as String)
        gifPropertyDic.setValue(1, forKey: kCGImagePropertyGIFLoopCount as String)

        //设置gif属性
        let gifDicDest = [kCGImagePropertyGIFDictionary as String: gifPropertyDic]
        CGImageDestinationSetProperties(destinaiton, gifDicDest as CFDictionary)

        //生成gif
        CGImageDestinationFinalize(destinaiton)

        print(gifPath)
    }

    /// 把gif动图分解成每一帧图片
        ///
        /// - Parameters:
        ///   - imageType: 分解后的图片格式
        ///   - path: gif路径
        ///   - locatioin: 分解后图片保存路径（如果为空则保存在默认路径）
        ///   - imageName: 分解后图片名称
    func decompositionImage( _ imageType: ImageType, _ path: String) -> [UIImage] {
        var images = [UIImage]()
        //把图片转成data
        let gifDate = try! Data(contentsOf: URL(fileURLWithPath: path))
        guard let gifSource = CGImageSourceCreateWithData(gifDate as CFData, nil) else { return images }
        //计算图片张数
        let count = CGImageSourceGetCount(gifSource)

        let dosc: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let directory = dosc[0] + "/"
        var imagePath = ""
        let imageName = String(randomOfLength: 16)
        //逐一取出

        for i in 0...count - 1 {
            guard let imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, nil) else { return images }
            let image = UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: .up)
            images.append(image)
            //根据选择不同格式生成对应图片已经路径
            switch imageType {
            case .jpg:
                guard let imageData = image.jpegData(compressionQuality: 1) else { return images }
                imagePath = directory + "\(imageName)" + "\(i)" + ".jpg"
                try? imageData.write(to: URL.init(fileURLWithPath: imagePath), options: .atomic)
            case .png:
                guard let imageData = image.pngData() else { return images }
                imagePath = directory + "\(imageName)" + "\(i)" + ".png"
                //生成图片
                try? imageData.write(to: URL.init(fileURLWithPath: imagePath), options: .atomic)
            }
            print(imagePath)
        }
        return images
    }
}
