//
//  EditSelectViewController.swift
//  EPP
//
//  Created by 신광현 on 05/08/2019.
//  Copyright © 2019 shin. All rights reserved.
//

import UIKit
import Foundation
import VideoToolbox


class StayleSelectViewController: UIViewController{
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet var MainView: UIView!
    
    var styletimer = Timer()
    var stylename = String()
    
    @IBAction func BackButtonTapped(_ sender: Any) {
        //self.navigationController?.tr_popViewController({ () -> Void in print("pop");})
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        
        let button1 = UIButton(frame: CGRect(x: 0, y: 50, width: 375, height: 200))
        button1.setImage(UIImage(named: "castle_monet"), for: UIControl.State.normal)
//        button1.backgroundColor = .red
        button1.addTarget(self, action: #selector(monetStayletrans), for: .touchUpInside)
        
        let button2 = UIButton(frame: CGRect(x: 0, y: 300, width: 375, height: 200))
        button2.setImage(UIImage(named: "castle_lamuse"), for: UIControl.State.normal)
//        button2.backgroundColor = .red
        button2.addTarget(self, action: #selector(la_museStayleTrans), for: .touchUpInside)
        
        let button3 = UIButton(frame: CGRect(x: 0, y: 550, width: 375, height: 200))
        button3.setImage(UIImage(named: "castle_rain"), for: UIControl.State.normal)
//        button3.backgroundColor = .red
        button3.addTarget(self, action: #selector(rain_princessStayletrans), for: .touchUpInside)
        
        let button4 = UIButton(frame: CGRect(x: 0, y: 800, width: 375, height: 200))
        button4.setImage(UIImage(named: "castle_scream"), for: UIControl.State.normal)
//        button4.backgroundColor = .red
        button4.addTarget(self, action: #selector(screamStayletrans), for: .touchUpInside)
        
        let button5 = UIButton(frame: CGRect(x: 0, y: 1050, width: 375, height: 200))
        button5.setImage(UIImage(named: "castle_udine"), for: UIControl.State.normal)
//        button5.backgroundColor = .red
        button5.addTarget(self, action: #selector(udnieStayletrans), for: .touchUpInside)
        
        let button6 = UIButton(frame: CGRect(x: 0, y: 1300, width: 375, height: 200))
        button6.setImage(UIImage(named: "castle_wreck"), for: UIControl.State.normal)
//        button6.backgroundColor = .red
        button6.addTarget(self, action: #selector(wreckStayletrans), for: .touchUpInside)
        
        let button7 = UIButton(frame: CGRect(x: 0, y: 1550, width: 375, height: 200))
        button7.setImage(UIImage(named: "castle_wave"), for: UIControl.State.normal)
//        button7.backgroundColor = .red
        button7.addTarget(self, action: #selector(WaveStayleTrans), for: .touchUpInside)
        
        scroll.addSubview(button1)
        scroll.addSubview(button2)
        scroll.addSubview(button3)
        scroll.addSubview(button4)
        scroll.addSubview(button5)
        scroll.addSubview(button6)
        scroll.addSubview(button7)

        
    }
    //#6D676E
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    @objc func WaveStayleTrans(_ sender: Any) {
        stylename = "wave"
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        let rootImg = rootView.SourceView.image!
        upload_style(rootImg, "style", stylename)
        
    }
    @objc func la_museStayleTrans(_ sender: Any) {
        stylename = "la_muse"
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        let rootImg = rootView.SourceView.image!
        upload_style(rootImg, "style", stylename)
        
    }
    @objc func rain_princessStayletrans(_ sender: Any) {
        stylename = "rain_princess"
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        let rootImg = rootView.SourceView.image!
        upload_style(rootImg, "style", stylename)
        
    }
    @objc func screamStayletrans(_ sender: Any) {
        stylename = "scream"
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        let rootImg = rootView.SourceView.image!
        upload_style(rootImg, "style", stylename)
        
    }
    @objc func udnieStayletrans(_ sender: Any) {
        stylename = "wave"
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        let rootImg = rootView.SourceView.image!
        upload_style(rootImg, "style", stylename)
        
    }
    @objc func wreckStayletrans(_ sender: Any) {
        stylename = "wreck"
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        let rootImg = rootView.SourceView.image!
        upload_style(rootImg, "style", stylename)
        

    }
    @objc func monetStayletrans(_ sender: Any) {
        stylename = "monet"
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        let rootImg = rootView.SourceView.image!
        upload_style(rootImg, "style", stylename)
        

    }
  
    
    
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    

    func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    

    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    /*
     Define UIColor from hex value
     @param rgbValue - hex color value
     @param alpha - transparency level
     */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
