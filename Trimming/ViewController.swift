//
//  ViewController.swift
//  Trimming
//
//  Created by hokama_mayumi on 2018/04/12.
//  Copyright © 2018年 Drecom Co.,Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapSelectedImage(_ sender: Any) {
        showSelectImageActionSheet()
    }

    func showSelectImageActionSheet() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.addAction(UIAlertAction(title: "写真を取る", style: .default, handler: { [weak self] _ in
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                if status == .authorized || status == .notDetermined {
                    self?.showImagePickerController(sourceType: .camera)
                } else {
                }
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            controller.addAction(UIAlertAction(title: "ライブラリから選択", style: .default, handler: { [weak self] _ in
                let status = PHPhotoLibrary.authorizationStatus()
                if status == .authorized || status == .notDetermined {
                    self?.showImagePickerController(sourceType: .photoLibrary)
                } else {
                }
            }))
        }
        controller.addAction(UIAlertAction(title: "やめる", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        var image: UIImage!

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            image = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            image = originalImage
        } else {
            return
        }
        // トリミング画面へ遷移
        let vc = TrimmingViewController()
        var makePath: UIBezierPath {
            return UIBezierPath()
        }

        vc.originalImage = image
        vc.delegate = self
        picker.dismiss(animated: true, completion: { [weak self] in
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    }
}

extension ViewController: TrimmingImageProtocol {
    var aspectH: CGFloat { return 9 }
    var aspectW: CGFloat { return 16 }

    func croppedImage(_ image: UIImage) {
        imageView.image = image
        print("完成", image)
    }
}
