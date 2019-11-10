//
//  ViewController + DrawRect.swift
//  EPP
//
//  Created by 신광현 on 20/07/2019.
//  Copyright © 2019 shin. All rights reserved.
//
import UIKit

extension ViewController{
    

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        lastPoint = touch?.location(in: SourceView)
        if isdrawing{
            drawRect(firstPoint, toPoint: lastPoint)
        }
        if iscustomdraw{
            
        }
        
   
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if iscustomdraw{
           if let touch = touches.first {
                let currentPoint = touch.location(in: SourceView)
                drawLineFrom(firstPoint!, toPoint: currentPoint)
                firstPoint = currentPoint
            }
        }
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        firstPoint = touch?.location(in: SourceView)
        if isdrawing{
            
        }
        if iscustomdraw{
                   
        }
       
    }
    
    func drawRect(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        let canvasSize = InpImgs.originimgArray.last?.size
        
        let dRect :CGRect = CGRect(x: round(fromPoint.x), y: round(fromPoint.y), width: round(toPoint.x-fromPoint.x), height: round(toPoint.y-fromPoint.y))
        
        UIGraphicsBeginImageContext(canvasSize!)
        if let context = UIGraphicsGetCurrentContext() {
            // original image
            InpImgs.originimgArray.last?.draw(in: CGRect(x: 0, y: 0, width: canvasSize!.width, height: canvasSize!.height))
            
            context.setFillColor(UIColor.white.cgColor)
            context.addRect(dRect)
            context.fill(dRect)
            
            // Rect후의 image 구조체에 append
            InpImgs.originimgArray.append(UIGraphicsGetImageFromCurrentImageContext()!)
            SourceView.image = InpImgs.originimgArray.last
            
            
            // mask image
            InpImgs.MaskimgArray.last?.draw(in: CGRect(x: 0, y: 0, width: canvasSize!.width, height: canvasSize!.height))
            context.setFillColor(UIColor.white.cgColor)
            context.addRect(dRect)
            context.fill(dRect)
            
            // Rect후의 mask image 구조체에 append
            InpImgs.MaskimgArray.append(UIGraphicsGetImageFromCurrentImageContext()!)
            maskimg = UIGraphicsGetImageFromCurrentImageContext()!
            Iv.image = InpImgs.MaskimgArray.last
            
        }
        UIGraphicsEndImageContext()
    }
    

    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        let canvasSize = SourceView.image?.size
        UIGraphicsBeginImageContextWithOptions(canvasSize!, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            SourceView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize!.width, height: canvasSize!.height))
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            context.setLineCap( CGLineCap.round)
            context.setLineWidth(5.0)
            context.setStrokeColor(UIColor.red.cgColor)
            context.setBlendMode( CGBlendMode.normal)
            context.strokePath()
            SourceView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
}
