//
//  EditSelectViewController.swift
//  EPP
//
//  Created by 신광현 on 05/08/2019.
//  Copyright © 2019 shin. All rights reserved.
//

import UIKit
//import TransitionTreasury
//import TransitionAnimation
import Foundation
import VideoToolbox


class EditSelectViewController: UIViewController{
    //var tr_pushTransition: TRNavgationTransitionDelegate?

    @IBOutlet weak var LightB: UIButton!
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var LeftB: UIButton!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var Place2Button: UIButton!
    @IBOutlet weak var ImageNetButton: UIButton!
    
    override func viewDidLoad() {
        LeftB.layer.borderColor = UIColor.lightGray.cgColor
        LeftB.layer.borderWidth = 0.5
        
        // 버튼 Line, color, think 설정
        LightB.layer.addBorder([.top, .bottom], color: UIColor.lightGray, width: 0.5)
        StackView.layer.addBorder([.bottom], color: UIColor.lightGray, width: 0.5)
        Place2Button.layer.addBorder([.top], color: UIColor.lightGray, width: 0.5)
        ImageNetButton.layer.addBorder([.top, .left], color: UIColor.lightGray, width: 0.5)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    // paint button event
    @IBAction func popVC(_ sender: Any) {
       let rootView = self.navigationController?.viewControllers[0] as! ViewController
       
        rootView.InpaintButtonView.isHidden = true
        rootView.MainButtonView.isHidden = true
        rootView.InpaintExitButton.isHidden = false
        rootView.MainView.backgroundColor = rootView.UIColorFromHex(rgbValue: 0x6D676E)
        rootView.SpaceButton.isHidden = true
    
        rootView.PaintButtonView.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    
    // style button event
    @IBAction func styleButtonTapped(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StayleSelectViewController") as! StayleSelectViewController
        vc.title = "EditView"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // inpaint place2 button event
    @IBAction func Place2ButtonTapped(_ sender: Any) {
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
       // rootView.InpaintToolBar.isHidden = false
        rootView.InpaintButtonView.isHidden = false
        rootView.MainToolBar.isHidden = true
        rootView.MainButtonView.isHidden = true
        rootView.ImageView.isHidden = false
        rootView.InpaintExitButton.isHidden = false
        rootView.MainView.backgroundColor = rootView.UIColorFromHex(rgbValue: 0x6D676E)
        rootView.inpaint_model_name = "place2"
        rootView.SpaceButton.isHidden = true
        
        navigationController?.popViewController(animated: true)
    }
    
    // inpaint imagenet button event
    @IBAction func imagenetButtonTapped(_ sender: Any) {
        
        let rootView = self.navigationController?.viewControllers[0] as! ViewController
        //rootView.InpaintToolBar.isHidden = false
        rootView.InpaintButtonView.isHidden = false
        rootView.MainToolBar.isHidden = true
        rootView.MainButtonView.isHidden = true
        rootView.ImageView.isHidden = false
        rootView.InpaintExitButton.isHidden = false
        rootView.MainView.backgroundColor = rootView.UIColorFromHex(rgbValue: 0x6D676E)
        rootView.inpaint_model_name = "imagenet"
        rootView.SpaceButton.isHidden = true
        
        navigationController?.popViewController(animated: true)
        
    }

}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
