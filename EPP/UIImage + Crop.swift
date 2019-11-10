//
//  UIImage + Crop.swift
//  EPP
//
//  Created by 신광현 on 21/07/2019.
//  Copyright © 2019 shin. All rights reserved.
//

import UIKit

extension UIImage {
    
    func cropped(boundingBox: CGRect) -> UIImage? {
        print("UIImage size")
        print(self.size)
        guard let cgImage = self.cgImage?.cropping(to: boundingBox) else {
            return nil
        }
        let img: UIImage = UIImage(cgImage: cgImage)
        return img
    }
    
    func c_resize(_ ratio: CGFloat) -> UIImage?{
        let returnimg : UIImage
        let canvasSize = CGSize(width: self.size.width*ratio, height: self.size.height*ratio)
        UIGraphicsBeginImageContext(canvasSize)
        self.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
        returnimg = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return returnimg
    }
}
