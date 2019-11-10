//
//  ViewController + PickerDelegate.swift
//  EPP
//
//  Created by 신광현 on 20/07/2019.
//  Copyright © 2019 shin. All rights reserved.
//

//680 × 512
//85:64
import UIKit

extension ViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage
        {
            
            SourceView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
            
            // orientation을 default로 바꾸어줘야 이미지가 회전하지 않음.
            let newImage = UIImage(cgImage: image.cgImage!, scale:image.scale, orientation: UIImage.Orientation(rawValue: 0)!)
            SourceView.image = newImage
            
            //inpaint 작업을 도중에 취소하기위해 초기 이미지를 저장
            FirstImage = newImage
            SourceView.center = CGPoint(x: 180, y: 333)

            print(info)
            
        }
        dismiss(animated: true, completion: nil)
    }
}
