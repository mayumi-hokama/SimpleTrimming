//
//  TrimmingViewController.swift
//  Trimming
//
//  Created by hokama_mayumi on 2018/04/12.
//  Copyright © 2018年 Drecom Co.,Ltd. All rights reserved.
//

import UIKit

protocol TrimmingImageProtocol: class {
    // Cropする画像のAspect比
    var aspectH: CGFloat { get }
    var aspectW: CGFloat { get }

    // protocol採用側で上書けるように定義してます。必要があれば上書きしてください。
    func maskRect() -> CGRect
    func maskPath() -> UIBezierPath

    // croppedImage
    func croppedImage(_ image: UIImage)
}

extension TrimmingImageProtocol where Self: UIViewController {

    func maskRect() -> CGRect {

        var maskSize: CGSize
        var width, height: CGFloat!

        width = self.view.frame.width
        height = width * aspectH / aspectW

        maskSize = CGSize(width: width, height: height)

        let viewWidth: CGFloat = self.view.frame.width
        let viewHeight: CGFloat = self.view.frame.height

        let maskRect = CGRect(x: (viewWidth - maskSize.width) * 0.5,
                              y: (viewHeight - maskSize.height) * 0.5,
                              width: maskSize.width,
                              height: maskSize.height)
        return maskRect
    }

    func maskPath() -> UIBezierPath {

        let rect: CGRect = maskRect()
        let point1 = CGPoint(x: rect.minX, y: rect.maxY)
        let point2 = CGPoint(x: rect.maxX, y: rect.maxY)
        let point3 = CGPoint(x: rect.maxX, y: rect.minY)
        let point4 = CGPoint(x: rect.minX, y: rect.minY)

        let path = UIBezierPath()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point4)
        path.close()

        return path
    }
}

class TrimmingViewController: UIViewController {

    lazy private var scrollView: TrimmingScrollView = {
        let scrollView = TrimmingScrollView(withImage: self.originalImage)
        return scrollView
    }()

    private lazy var overlayView: CropOverlayView = {
        let view = CropOverlayView(frame: self.view.frame)
        view.path = self.delegate?.maskPath()
        view.cropRect = self.delegate?.maskRect()
        view.touchView = scrollView
        return view
    }()

    // 保存ボタン
    private lazy var doneButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(tapDoneButton))
    }()

    // カメラ、またはライブラリから選択された画像
    var originalImage: UIImage!

    // delegate
    weak var delegate: TrimmingImageProtocol?

    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "TrimmingBG")!)
        view.clipsToBounds = true
        navigationItem.rightBarButtonItem = doneButton
        view.addSubview(scrollView)
        view.addSubview(overlayView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // scrollViewの調整
        if let delegate = self.delegate {
            scrollView.frame = delegate.maskRect()
            scrollView.setMinMaxZoomScale()
            scrollView.setInitContentOffset()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func tapDoneButton() {
        let cropRect = self.cropRect()
        let image = scrollView.cropImageView.image!

        var correctRect = checkCropRect(image: image, cropRect: cropRect)
        correctRect = correctRect.applying(CGAffineTransform(scaleX: image.scale, y: image.scale))

        let cropCGImage = image.cgImage?.cropping(to: correctRect)
        let croppedImage = UIImage(cgImage: cropCGImage!, scale: image.scale, orientation: image.imageOrientation).fixOrientation()
        self.delegate?.croppedImage(croppedImage!)
        self.navigationController?.popViewController(animated: true)
    }

    private func cropRect() -> CGRect {

        var cropRect = CGRect()

        // 現在のズームscale
        let zoomScale = 1.0 / scrollView.zoomScale

        // 現在のscroll位置からクロップする位置を割り出す
        cropRect.origin.x = floor(scrollView.contentOffset.x * zoomScale)
        cropRect.origin.y = floor(scrollView.contentOffset.y * zoomScale)
        // 大きさ
        cropRect.size.width = floor(scrollView.bounds.width * zoomScale)
        cropRect.size.height = floor(scrollView.bounds.height * zoomScale)

        return cropRect
    }

    private func checkCropRect(image: UIImage, cropRect: CGRect) -> CGRect {

        var cropRect = cropRect
        let imageSize = image.size
        let x = cropRect.minX
        let y = cropRect.minY
        let width = cropRect.width
        let height = cropRect.height

        switch image.imageOrientation {
        case .right, .rightMirrored:
            cropRect.origin.x = y
            cropRect.origin.y = floor(imageSize.width - width - x)
            cropRect.size.width = height
            cropRect.size.height = width
        case .left, .leftMirrored:
            cropRect.origin.x = floor(imageSize.height - cropRect.height - y)
            cropRect.origin.y = x
            cropRect.size.width = height
            cropRect.size.height = width
        case .down, .downMirrored:
            cropRect.origin.x = floor(imageSize.width - cropRect.width - x)
            cropRect.origin.y = floor(imageSize.height - cropRect.height - y)
        default:
            break
        }

        return cropRect
    }
}
