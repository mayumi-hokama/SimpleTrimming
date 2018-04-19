//
//  UIImage+Extension.swift
//  Trimming
//
//  Created by hokama_mayumi on 2018/04/16.
//  Copyright © 2018年 Drecom Co.,Ltd. All rights reserved.
//

import UIKit

extension UIImage {

    func fixOrientation() -> UIImage? {

        // upの場合は特に何もしない
        if case .up = self.imageOrientation { return self }

        guard let cgImage = self.cgImage else { return nil }

        // コンテキストを生成
        guard let space = cgImage.colorSpace, let ctx: CGContext = CGContext.init(data: nil,
                                                  width: Int(size.width),
                                                  height: Int(size.height),
                                                  bitsPerComponent: cgImage.bitsPerComponent,
                                                  bytesPerRow: 0,
                                                  space: space,
                                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }

        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: .pi / -2)
        default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: self.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: self.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        default:
            break
        }


        ctx.concatenate(transform)

        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        guard let createImage = ctx.makeImage() else { return nil }
        let image = UIImage(cgImage: createImage)
        return image
    }
}
