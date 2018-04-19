//
//  TrimmingScrollView.swift
//  Trimming
//
//  Created by hokama_mayumi on 2018/04/12.
//  Copyright © 2018年 Drecom Co.,Ltd. All rights reserved.
//

import UIKit

final class TrimmingScrollView: UIScrollView {

    // クロップするimageView
    var cropImageView: UIImageView!

    // オリジナル画像のサイズ
    private var cropImageSize: CGSize!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(withImage image: UIImage) {
        self.init()
        self.cropImageView = UIImageView(image: image)
        addSubview(self.cropImageView)
        contentSize = image.size
        cropImageSize = image.size
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMinMaxZoomScale() {
        // 自身のサイズ
        let boundsSize = bounds.size

        // 自身のviewから画像サイズで割ってScale値を出す
        let wScale = boundsSize.width / cropImageSize.width
        let hScale = boundsSize.height / cropImageSize.height

        var minScale = max(wScale, hScale)
        var maxScale = max(wScale, hScale)

        zoomScale = maxScale

        let xImageScale = maxScale * cropImageSize.width / boundsSize.width
        let yImageScale = maxScale * cropImageSize.height / boundsSize.height
        // imageのScale値（縦長か横長か）
        let maxImageScale = max(xImageScale, yImageScale)
        maxScale = max(maxScale, maxImageScale)

        if minScale > maxScale { minScale = maxScale }

        // TODO: 調整する
        minimumZoomScale = minScale
        maximumZoomScale = maxScale
    }

    func setInitContentOffset() {
        // 画像を中心に表示させるようにcontentOffsetを変える
        let boundsSize = bounds.size
        let frameToCenter = cropImageView.frame

        var contentOffset = CGPoint(x: 0, y: 0)

        if frameToCenter.width > boundsSize.width {
            contentOffset.x = (frameToCenter.width - boundsSize.width) * 0.5
        } else {
            contentOffset.x = 0
        }

        if frameToCenter.height > boundsSize.height {
            contentOffset.y = (frameToCenter.height - boundsSize.height) * 0.5
        } else {
            contentOffset.y = 0
        }

        setContentOffset(contentOffset, animated: false)
    }

    private func setupView() {
        bouncesZoom = true
        scrollsToTop = false
        zoomScale = 1.0
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        contentInset = .zero
        clipsToBounds = false
    }
}

extension TrimmingScrollView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cropImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {

        var frameToCenter = cropImageView.frame

        if frameToCenter.width < self.bounds.width {
            frameToCenter.origin.x = (self.bounds.width - frameToCenter.width) * 0.5
        } else {
            frameToCenter.origin.x = 0
        }

        // center vertically
        if frameToCenter.height < self.bounds.height {
            frameToCenter.origin.y = (self.bounds.height - frameToCenter.height) * 0.5
        } else {
            frameToCenter.origin.y = 0
        }

        cropImageView.frame = frameToCenter;
    }
}

