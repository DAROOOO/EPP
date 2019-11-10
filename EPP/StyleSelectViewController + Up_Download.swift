//
//  StyleSelectViewController + Up_Download.swift
//  EPP
//
//  Created by 신광현 on 26/08/2019.
//  Copyright © 2019 shin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

extension StayleSelectViewController{
    
    func upload_style(_ img: UIImage, _ taskname: String, _ stylename: String){
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let txtdRef = storageRef.child("Queue.txt")
        var txtdata = Data()
        var string: String = String()
        var addstring: String = String()
        showActivityIndicator(uiView: self.MainView)
        
        txtdRef.getData(maxSize: 9999 * 9999){ data, error in
            if let error = error{
                print("get text error?")
                print(error)
            }else{
                txtdata = data!
                string = String(data: txtdata, encoding: .utf8)!
                print(string)
                //Queue에 추가될 str  = .style/wave/user1
                addstring = string + String(".") + taskname + String("/") + stylename + String("/user1")
                print(addstring)
                if (img.size.width*img.size.height)>(800*800){
                    self.Up_DownTimer(self.ResizeImg(img), addstring, taskname, stylename)
                }
                else{
                    self.Up_DownTimer(img, addstring, taskname, stylename)
                }
                
            }
        }
    }
    
    func Up_DownTimer(_ img: UIImage, _ AllQstr: String, _ taskname: String, _ stylename: String){
        
        //task = style/wave/user1.png
        let task = taskname + String("/") + stylename + String("/user1.png")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let uploadRef = storageRef.child(task)
        let txtdRef = storageRef.child("Queue.txt")
        var data = Data()
        var txtdata = Data()
        
        data = img.pngData()!
        txtdata = AllQstr.data(using: String.Encoding.utf8)!
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        //이미지 업로드
        _ = uploadRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error{
                print("up error?")
                print(error)
            }
        }
        
        //Queue 갱신(업로드) 현재 테스크로 입력
        let txtmetadata = StorageMetadata()
        txtmetadata.contentType = "text/plain"
        _ = txtdRef.putData(txtdata, metadata: txtmetadata) { (metadata, error) in
            if let error = error{
                print("up txt error")
                print(error)
            }
        }
        
        styletimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(styledownload), userInfo: nil, repeats: true)
        }
    
    @objc func styledownload(){
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        //detection img > 2CGPoint for drawRect
        var downloadRef: StorageReference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let metadata = StorageMetadata()
        
        // style/wave/user1_result.png
        let downRefstr = String("style/") + stylename + String("/user1_result.png")
        
        downloadRef = storageRef.child(downRefstr)
        metadata.contentType = "image/png"
        
        downloadRef.getData(maxSize: 9999*9999){ data, error in
            if let error = error{
                print(error)
            }else{
                let image = UIImage(data: data!)
                rootView.SourceView.image = image
                self.styletimer.invalidate()
                print("이미지뷰 이미지??")
                downloadRef.delete()
                self.hideActivityIndicator(uiView: self.MainView)
                //_ = self.navigationController?.tr_popToRootViewController()
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
        print("실행중")
    }
    
    
// 800 * 800 보다 이미지가 클 경우, 이미지를 줄여주는 함수.
// 이미지가 너무 크면 변환이 되지않음.
    func ResizeImg(_ img: UIImage) -> (UIImage){
        print(img.size)
        let scale = ((800*800)/(img.size.width*img.size.height)).squareRoot()
        print(scale)
        var imgs = UIImage()
        //CGSIze
        let canvasSize = CGSize(width: round(img.size.width*scale), height: round(img.size.height*scale))
        print(canvasSize)
        
        UIGraphicsBeginImageContext(canvasSize)
        img.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
        imgs = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imgs
    }
}
