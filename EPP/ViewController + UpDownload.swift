//
//  ViewController + Up:Download.swift
//  EPP
//
//  Created by 신광현 on 22/07/2019.
//  Copyright © 2019 shin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage


extension ViewController{
    
    //inpaint 전용 task name 파라미터 불필요
    func upload_inpaint(_ img: UIImage, _ maskimg: UIImage, _ modelname: String){
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let txtdRef = storageRef.child("Queue.txt")
        var txtdata = Data()
        var string: String = String()
        var addstring: String = String()
        
        txtdRef.getData(maxSize: 9999 * 9999){ data, error in
            if let error = error{
                print("get text error?")
                print(error)
            }else{
                txtdata = data!
                string = String(data: txtdata, encoding: .utf8)!
                print(string)
                
                //Queue에 추가될 str  = .inpaint/place2/user1
                addstring = string + String(".inpaint/") + modelname + String("/user1")
                
                print(addstring)
                self.Up_DownTimer(img, maskimg, addstring, modelname)
            }
        }
    }
  
    
    //detect, taskname = detection
    func upload_detect(_ img: UIImage, _ taskname: String){
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let txtdRef = storageRef.child("Queue.txt")
        var txtdata = Data()
        var string: String = String()
        var addstring: String = String()
        
        txtdRef.getData(maxSize: 9999 * 9999){ data, error in
            if let error = error{
                print("get text error?")
                print(error)
            }else{
                txtdata = data!
                string = String(data: txtdata, encoding: .utf8)!
                print(string)
                
                addstring = string + String(".") + taskname + String("/user1")
                print(addstring)
                self.Up_DownTimer(img, addstring, taskname)
            }
        }
    }
   
    
    //inpaint
    func Up_DownTimer(_ img: UIImage, _ maskimg: UIImage, _ str: String, _ modelname: String){
        let ImgUploadStr = String("inpaint/") + modelname + String("/user1o.png")
        let maskImgUploadStr = String("inpaint/") + modelname + String("/user1m.png")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let uploadRef = storageRef.child(ImgUploadStr)
        let maskuploadRef = storageRef.child(maskImgUploadStr)
        let txtdRef = storageRef.child("Queue.txt")
        var data = Data()
        var mask = Data()
        var txtdata = Data()
        
        data = img.pngData()!
        mask = maskimg.pngData()!
        txtdata = str.data(using: String.Encoding.utf8)!
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        _ = uploadRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error{
                print("up error?")
                print(error)
            }
        }
        
        _ = maskuploadRef.putData(mask, metadata: metadata) { (metadata, error) in
            if let error = error{
                print("up error?")
                print(error)
            }
        }
        
        let txtmetadata = StorageMetadata()
        txtmetadata.contentType = "text/plain"
        _ = txtdRef.putData(txtdata, metadata: txtmetadata) { (metadata, error) in
            if let error = error{
                print("up txt error")
                print(error)
            }
        }
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(inpdownload), userInfo: nil, repeats: true)
    }
    
    //detect style
    func Up_DownTimer(_ img: UIImage, _ Q_str: String, _ taskname: String){
        let task = taskname + String("/user1.png")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let uploadRef = storageRef.child(task)
        let txtdRef = storageRef.child("Queue.txt")
        var data = Data()
        var txtdata = Data()
        
        data = img.pngData()!
        txtdata = Q_str.data(using: String.Encoding.utf8)!
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        //이미지 업로드
        _ = uploadRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error{
                print("up error?")
                print(error)
            }
        }
        
        //Queue 갱신(업로드)
        let txtmetadata = StorageMetadata()
        txtmetadata.contentType = "text/plain"
        _ = txtdRef.putData(txtdata, metadata: txtmetadata) { (metadata, error) in
            if let error = error{
                print("up txt error")
                print(error)
            }
        }
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(detectdownload), userInfo: nil, repeats: true)
        

    }
    
    //inpaint input(img,img) retrun(img)
    @objc func inpdownload(){
        
        // inpaint/place2/user1_result.png
        let downloadStr = String("inpaint/") + inpaint_model_name + String("/user1_result.png")
        var downloadRef: StorageReference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let metadata = StorageMetadata()
    
        downloadRef = storageRef.child(downloadStr)
        metadata.contentType = "image/png"
        
        downloadRef.getData(maxSize: 1*1024*1024){ data, error in
            if let error = error{
                print(error)
            }else{
                let image = UIImage(data: data!)
                self.SourceView.image = image
                self.timer.invalidate()
                downloadRef.delete()
                self.hideActivityIndicator(uiView: self.MainView)
            }
        }
        
        print("실행중")
    }
    @objc func detectdownload(){
        //detection img > 2CGPoint for drawRect
        var downloadRef: StorageReference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let metadata = StorageMetadata()
        
        downloadRef = storageRef.child("detection/user1_result.txt")
        metadata.contentType = "text/plain"
        
        downloadRef.getData(maxSize: 1*1024*1024){ data, error in
            if let error = error{
                print(error)
            }else{
                self.timer.invalidate()
                
                //str to 2CGPoint for drawrect
                let str = String(data: data!, encoding: .utf8)
                let strarr = str?.split(separator: "/")
                
                //발견한 사람수가 0명일시 Alert
                if strarr?.count == 0{
                    print("없음!")
                    let alert = UIAlertController(title: "Alert", message: "Didn't find human", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler : nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    for i in strarr!{
                        let points = i.split(separator: ".")
                        print(CGPoint(x: Int(points[1])!,y: Int(points[0])!))
                        print(CGPoint(x: Int(points[3])!,y: Int(points[2])!))
                        self.drawRect(CGPoint(x: Int(points[1])!,y: Int(points[0])!),toPoint: CGPoint(x: Int(points[3])!,y: Int(points[2])!))
                    }
                }
                
                downloadRef.delete()
                self.hideActivityIndicator(uiView: self.MainView)
            }
        }
        print("실행중")
    }
    
    
    
}
