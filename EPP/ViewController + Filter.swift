//
//  ViewController + Filter.swift
//  EPP
//
//  Created by 신광현 on 11/11/2019.
//  Copyright © 2019 shin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController{
    func BrightControll(_ value: CGFloat){
        
             // -0.2 ~ 0.2
        let aa: CIImage = ciimg.applyingFilter("CIColorControls",parameters: ["inputBrightness": value,])
        
        // UIImage > CIImage > CGImage > UIImage 순서 틀릴시 오류
        let context = CIContext(options: nil)
        
        guard let cgimg = context.createCGImage(aa, from: aa.extent) else {return}
        
        let uiimg: UIImage = UIImage(cgImage: cgimg)
        
        FirstImage = uiimg
        SourceView.image = FirstImage
    }
    
    func ContrastControll(_ value: CGFloat){
        
        // -0.18 ~ 0.18
        let aa: CIImage = ciimg.applyingFilter("CIColorControls",parameters: [kCIInputContrastKey: 1 + value,])
        
        let context = CIContext(options: nil)
        
        guard let cgimg = context.createCGImage(aa, from: aa.extent) else {return}
        
        let uiimg: UIImage = UIImage(cgImage: cgimg)
        
        FirstImage = uiimg
        SourceView.image = FirstImage
    }
}
