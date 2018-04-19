//
//  CropOverlayView.swift
//  Trimming
//
//  Created by hokama_mayumi on 2018/04/12.
//  Copyright © 2018年 Drecom Co.,Ltd. All rights reserved.
//

import UIKit

final class CropOverlayView: UIView {

    var touchView: UIView!
    // 透明に描画する領域
    var path: UIBezierPath? = nil
    var cropRect: CGRect!

    private lazy var hollowLayer: CALayer = {
        // ベースのlayer
        let layer = CALayer()
        layer.bounds = self.bounds
        layer.position = CGPoint(x: self.center.x, y: self.center.y)
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.7

        // くり抜きたい範囲のパスを指定
        let path =  UIBezierPath(rect: self.cropRect!)
        path.append(UIBezierPath(rect: overlayLayer.bounds))

        overlayLayer.path = path.cgPath
        overlayLayer.position = CGPoint(
            x: layer.bounds.width / 2.0,
            y: layer.bounds.height / 2.0
        )
        layer.mask = overlayLayer
        return layer
    }()

    lazy var overlayLayer: CAShapeLayer = {
        let mask = CAShapeLayer()
        mask.bounds = self.bounds
        mask.fillRule = kCAFillRuleEvenOdd
        mask.fillColor = UIColor.black.cgColor
        return mask
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func layoutSublayers(of layer: CALayer) {
        layer.addSublayer(hollowLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if self.point(inside: point, with: event) {
            return touchView
        }
        return nil
    }
}
