//
//  ViewController.swift
//  EPP
//
//  Created by 신광현 on 19/07/2019.
//  Copyright © 2019 shin. All rights reserved.
//
//
//
import UIKit
import FirebaseStorage
import Firebase
//import TransitionTreasury
//import TransitionAnimation




class ViewController: UIViewController{
    //var tr_pushTransition: TRNavgationTransitionDelegate?
    //var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBOutlet weak var FilterButtonView: UIView!
    @IBOutlet weak var InpaintButtonView: UIView!
    @IBOutlet weak var MainButtonView: UIView!
    @IBOutlet weak var PaintButtonView: UIView!
    //@IBOutlet weak var InpaintToolBar: UIToolbar!
    @IBOutlet weak var MainToolBar: UIToolbar!
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var SourceView: UIImageView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var Iv: UIImageView!
    @IBOutlet weak var SpaceButton: UIButton!
    
    @IBOutlet var PanRec: UIPanGestureRecognizer!
    @IBOutlet var PinchRec: UIPinchGestureRecognizer!

    @IBOutlet weak var InpaintExitButton: UIButton!

    @IBOutlet weak var CropButton: UIButton!
    @IBOutlet weak var RectButton: UIButton!
    @IBOutlet weak var RevertButton: UIButton!
    @IBOutlet weak var InpaintButton: UIButton!
    @IBOutlet weak var DetectButton: UIButton!
    @IBOutlet weak var PaintButton: UIButton!
    @IBOutlet weak var mergeButton: UIButton!
    @IBOutlet weak var BrightButton: UIButton!
    @IBOutlet weak var ContrastButton: UIButton!
    @IBOutlet weak var cplusbutton: UIButton!
    @IBOutlet weak var cminusbutton: UIButton!
    @IBOutlet weak var bplusbutton: UIButton!
    @IBOutlet weak var bminusbutton: UIButton!
    
    @IBAction func InpaintExitTapped(_ sender: Any) {
        //InpaintToolBar.isHidden = true
        InpaintButtonView.isHidden = true
        PaintButtonView.isHidden = true
        mergeButton.isHidden = true
        InpaintExitButton.isHidden = true
        MainToolBar.isHidden = false
        MainButtonView.isHidden = false
        CropButton.isHidden = false
        RectButton.isHidden = true
        RevertButton.isHidden = true
        InpaintButton.isHidden = true
        DetectButton.isHidden = true
        ImageView.isHidden = true
        SpaceButton.isHidden = false
        FilterButtonView.isHidden = true
        BrightButton.tintColor = UIColor.white
        cnt4 = false
        ContrastButton.tintColor = UIColor.white
        cnt3 = false
        ciimg = nil
        
        isdrawing = false
        iscustomdraw = false
        SourceView.isUserInteractionEnabled = true
        InpImgs.MaskimgArray.removeAll()
        InpImgs.originimgArray.removeAll()
        SourceView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: SourceView.image!.size)
        SourceView.center = CGPoint(x: 180, y: 333)
        MainView.backgroundColor = UIColorFromHex(rgbValue: 0x3E517A)
        scale = 1.0
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func ContractTapped(_ sender: Any) {
        
        if cnt3 == false{
            UIView.transition(with: MainView, duration: 0.5, options: .transitionCrossDissolve,
            animations: {
               self.FilterButtonView.isHidden = false
               // 에니메이션 적용할 메소드 작성
            }, completion:nil)
            ContrastButton.tintColor = UIColor.gray
            cplusbutton.isHidden = false
            cminusbutton.isHidden = false
            bplusbutton.isHidden = true
            bminusbutton.isHidden = true
            cnt3 = true
        }
        else{
            FilterButtonView.isHidden = true
            ContrastButton.tintColor = UIColor.white
            cnt3 = false
        }
    }
    @IBAction func BrightTapped(_ sender: Any) {
        if cnt4 == false{
            UIView.transition(with: MainView, duration: 0.5, options: .transitionCrossDissolve,
            animations: {
               self.FilterButtonView.isHidden = false
               // 에니메이션 적용할 메소드 작성
            }, completion:nil)
//            FilterButtonView.isHidden = false
            BrightButton.tintColor = UIColor.gray
            cplusbutton.isHidden = true
            cminusbutton.isHidden = true
            bplusbutton.isHidden = false
            bminusbutton.isHidden = false
            cnt4 = true
        }
        else{
            FilterButtonView.isHidden = true
            BrightButton.tintColor = UIColor.white
            cnt4 = false
        }
    }
    @IBAction func ContrastPlus(_ sender: Any) {
        ContrastValue += CGFloat(0.05)
        ContrastControll(ContrastValue)
    }
    @IBAction func Contrastminus(_ sender: Any) {
        ContrastValue -= CGFloat(0.05)
        ContrastControll(ContrastValue)
    }
    @IBAction func BrightPlus(_ sender: Any) {
        BrightValue += CGFloat(0.05)
        BrightControll(BrightValue)
    }
    @IBAction func Brightminus(_ sender: Any) {
        BrightValue -= CGFloat(0.05)
        BrightControll(BrightValue)
    }
    
    // 그림 그리기 on/off 버튼
    @IBAction func PaintButtonTapped(_ sender: Any) {
        if cnt2 == true{
            iscustomdraw = false
            SourceView.isUserInteractionEnabled = true
            //InpaintToolBar.items?[0].tintColor = UIColor.white
            PaintButton.tintColor = UIColor.white
            cnt2 = false
        }
        else{
            iscustomdraw = true
            SourceView.isUserInteractionEnabled = false
            MainView.isMultipleTouchEnabled = false
            //InpaintToolBar.items?[0].tintColor = UIColor.gray
            PaintButton.tintColor = UIColor.gray
            cnt2 = true
        }
    }
    
    // crop이미지와 원본이미지 덮어씌우는 버튼
    @IBAction func mergeButtonTapped(_ sender: Any) {
        
        let cropratio =  680 / m_cropsiz.width
        let mergepoint_x = m_croppoint.x * cropratio
        let mergepoint_y = m_croppoint.y * cropratio
//        print(m_cropsiz.width)
//        print(m_cropsiz.height)
//        print(cropratio)
//        print(mergepoint_x)
//        print(mergepoint_y)
                
        // 프레임을 줄일경우 / crop을 줄일경우
        if cropratio < 1{
            let ratioimg = FirstImage.c_resize(cropratio)
//            print("이미지사이즈")
//            print(FirstImage.size)
//            print(ratioimg?.size)
//            print(SourceView.image?.size)
            let canvasSize = ratioimg?.size
            UIGraphicsBeginImageContext(canvasSize!)
            ratioimg?.draw(in: CGRect(x: 0, y: 0, width: canvasSize!.width, height: canvasSize!.height))
            SourceView?.image!.draw(at: CGPoint(x: mergepoint_x,y:mergepoint_y))
            SourceView.image = UIGraphicsGetImageFromCurrentImageContext()!
            
            UIGraphicsEndImageContext()
        }
        else{
            let mergeimg : UIImage
            let canvasSize = CGSize(width: m_cropsiz.width, height: m_cropsiz.height)
            UIGraphicsBeginImageContext(canvasSize)
            SourceView.image!.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            mergeimg = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            let canvasSize1 = FirstImage.size
            UIGraphicsBeginImageContext(canvasSize1)
            FirstImage.draw(in: CGRect(x: 0, y: 0, width: canvasSize1.width, height: canvasSize1.height))
            mergeimg.draw(at: CGPoint(x: m_croppoint.x,y:m_croppoint.y))
            SourceView.image = UIGraphicsGetImageFromCurrentImageContext()!
            
            UIGraphicsEndImageContext()
        }
        FirstImage = SourceView.image!
        mergeButton.isHidden = true
    }
    
    
    
    // inpaint 모델 input : image(680 * 512) + mask image(680*512)
    @IBAction func CropButtonTapped(_ sender: Any) {
        //현재 스케일에 비례해서 이미지를 잘라줘야함
        let rr: CGFloat = (-SourceView.frame.origin.x)*(1/scale)
        let xx: CGFloat = ((192*(1/scale))-((SourceView.frame.origin.y)*(1/scale)))

        SourceView.image = SourceView.image!.cropped(boundingBox: CGRect(origin: CGPoint(x: rr, y: xx), size: CGSize(width: 375*(1/scale), height: 282*(1/scale))))
        print("포인트!!")
        print(rr)
        print(xx)
        m_croppoint = CGPoint(x: rr, y: xx)
        print("회색사각이미지")
        print(SourceView.image!.size)
        m_cropsiz = SourceView.image!.size
        
        let canvasSize = CGSize(width: 680, height: 512)
        UIGraphicsBeginImageContext(canvasSize)
        SourceView.image!.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
        SourceView.image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
//        SourceView.image = SourceView.image.
        
        //이미지뷰의 바운드와 이미지의 사이즈를 같게 설정, 터치의 위치를 동기화하기위해
        SourceView.bounds.size = (SourceView.image?.size)!
        InpImgs.originimgArray.append(SourceView.image!)
        SourceView.center = CGPoint(x: 180, y: 333)
        SourceView.transform = SourceView.transform.scaledBy(x: scale, y: scale)
        scale = 1.0

        //mask 이미지 생성
        let maskcanvers = SourceView.bounds.size
        UIGraphicsBeginImageContext(maskcanvers)
        if let context = UIGraphicsGetCurrentContext() {
            let mRect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: maskcanvers)
            context.setFillColor(UIColor.black.cgColor)
            context.addRect(mRect)
            context.fill(mRect)
            InpImgs.MaskimgArray.append(UIGraphicsGetImageFromCurrentImageContext()!)
        }
        UIGraphicsEndImageContext()
        Iv.image = InpImgs.MaskimgArray.last
        ImageView.isHidden = true
        CropButton.isHidden = true
        RectButton.isHidden = false
        RevertButton.isHidden = false
        InpaintButton.isHidden = false
        DetectButton.isHidden = false
        fitratio()
    }
    
    @IBAction func DrawButtonTapped(_ sender: Any) {
        if cnt == true{
            isdrawing = false
            SourceView.isUserInteractionEnabled = true
            //InpaintToolBar.items?[0].tintColor = UIColor.white
            RectButton.tintColor = UIColor.white
            cnt = false
        }
        else{
            isdrawing = true
            SourceView.isUserInteractionEnabled = false
            MainView.isMultipleTouchEnabled = false
            //InpaintToolBar.items?[0].tintColor = UIColor.gray
            RectButton.tintColor = UIColor.gray
            cnt = true
        }
        print(InpImgs.MaskimgArray.count)
        print(InpImgs.originimgArray.count)
    }
    
    @IBAction func SpaceButtonTapped(_ sender: Any) {
        if cnt1 == true{
            MainButtonView.isHidden = false
            SpaceButton.tintColor = UIColor.black
            cnt1 = false
        }
        else{
            MainButtonView.isHidden = true
            SpaceButton.tintColor = UIColor.gray
            cnt1 = true
        }
    }
    
    // revert button
    @IBAction func PopimgButtonTapped(_ sender: Any) {
        if(InpImgs.originimgArray.count >= 2){
            _ = InpImgs.originimgArray.popLast()
            _ = InpImgs.MaskimgArray.popLast()
            Iv.image = InpImgs.MaskimgArray.last
            SourceView.image = InpImgs.originimgArray.last
        }
    }
    
    // inpaint button
    @IBAction func ServerButtonTapped(_ sender: Any) {
        upload_inpaint(InpImgs.originimgArray.last!, InpImgs.MaskimgArray.last!, inpaint_model_name)
        showActivityIndicator(uiView: MainView)
        mergeButton.isHidden = false
    }
    
    // detect button
    @IBAction func DetectMLButtonTapped(_ sender: Any) {
        upload_detect(SourceView.image!, "detection")
        showActivityIndicator(uiView: MainView)

    }

    // 사진 저장 버튼
    @IBAction func restoreimageButtonTapped(_ sender: Any) {
        let alert1 = UIAlertController(title: "알림", message: "사진을 저장 하겠습니까?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "YES", style: .destructive){ (action) in
            UIImageWriteToSavedPhotosAlbum(self.SourceView.image!, self, nil, nil);
        }
        let NOAction = UIAlertAction(title: "NO", style: .destructive, handler : nil)
        alert1.addAction(OKAction)
        alert1.addAction(NOAction)
        self.present(alert1, animated: true, completion: nil)
    }
    
    // EditSelectionView로 serge
    @IBAction func EditButtonTapped(_ sender: Any) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditSelectViewController") as! EditSelectViewController
        vc.title = "EditView"
        navigationController?.pushViewController(vc, animated: true)
        ciimg = CIImage(image: SourceView.image!)!
    }
    
    @IBAction func HelpButtonTapped(_ sender: Any) {
        showActivityIndicator(uiView: MainView)
    }
    
    
    // 사진 불러오기 및 init
    @IBAction func LibButtonTapped(_ sender: Any) {
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
        
        // 이거 안하면 SourceView 트랜스폼 체계 다 무너져서 새로운 사진 추가할때마다 PanGesture속도가 달라짐
        SourceView.transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        MainView.transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        scale = 1.0
        
//        let newImage = UIImage(cgImage: SourceView.image!.cgImage!, scale: SourceView.image!.scale, orientation: .down)
        
        //사진 방향 체크
//        print(newImage.imageOrientation)
        
    }
    
    @IBAction func SVPinchAction(_ pinch: UIPinchGestureRecognizer) {
        SourceView.transform = SourceView.transform.scaledBy(x: PinchRec.scale, y: PinchRec.scale)
        scale = scale * PinchRec.scale
        PinchRec.scale = 1.0
        let state = pinch.state
        switch(state){
        case.ended:
            fitratio()
//            print("스케일!")
//            print(scale)
//            print("프레임사이즈")
//            print(SourceView.frame.size)
//            print("바운드사이즈")
//            print(SourceView.bounds)
//            print("이미지사이즈")
//            print(SourceView.image!.size)
            MainView.transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
        case .possible:
            print("")
        case .began:
            print("")
        case .changed:
            print("")
        case .cancelled:
            print("")
        case .failed:
            print("")
        @unknown default:
            print("")
        }
    }
    
    @IBAction func SVPanAction(_ sender: UIPanGestureRecognizer) {
        transition = PanRec.translation(in: MainView)
        PanRec.setTranslation(CGPoint.zero, in: SourceView)
        
        // 터치 이벤트 Pan이랑 Pinch 구별 터치 최대 갯수 제한
        PanRec.maximumNumberOfTouches = 1
        let state = sender.state
        
        switch(state){
        case.ended:
            fitratio()
        case .possible:
            print("")
        case .began:
            print("")
        case .changed:
            SourceView.center = CGPoint(x: SourceView.center.x + (transition.x), y: SourceView.center.y + (transition.y))
            print(transition.x * scale)
//            print("스케일!")
//            print(scale)
        case .cancelled:
            print("")
        case .failed:
            print("")
        @unknown default:
            print("")
        }
        transition.x = 0.0
        transition.y = 0.0
        
    }
    
    
    var isdrawing = false
    var iscustomdraw = false
    
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    
    let picker = UIImagePickerController()
    let MV: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
    
    // 스크롤 스피드 조절
    var transition: CGPoint!
    var scale: CGFloat = 1.0
    
    var timer = Timer()
    var maskimg = UIImage()
    
    //draw버튼 상태
    var cnt = false
    //Space버튼 상태
    var cnt1 = false
    //paint버튼 상태
    var cnt2 = false
    //contract버튼 상태
    var cnt3 = false
    //bright버튼 상태
    var cnt4 = false
    
    var InpImgs = InpaintImgStruct()
    var FirstImage = UIImage()
    
    var inpaint_model_name = String()
    
    //merge관련 변수
    var m_croppoint: CGPoint!
    var m_cropsiz: CGSize!
    
    var ciimg: CIImage!
    var ContrastValue: CGFloat = CGFloat(0.05)
    var BrightValue: CGFloat = CGFloat(0.05)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // ** INIT ** //
        ImageView.isHidden = true
        Iv.isHidden = true
        mergeButton.isHidden = true
        InpaintButtonView.isHidden = true
        PaintButtonView.isHidden = true
        CropButton.isHidden = false
        RectButton.isHidden = true
        RevertButton.isHidden = true
        InpaintButton.isHidden = true
        DetectButton.isHidden = true
        InpaintExitButton.isHidden = true
        FilterButtonView.isHidden = true
        
        isdrawing = false
        SourceView.isUserInteractionEnabled = true
        navigationController?.isNavigationBarHidden = true
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
        MainView.backgroundColor = UIColorFromHex(rgbValue: 0x3E517A)
        
        //tint color 변경가능하게 해주는 코드
        SpaceButton.setImage(SpaceButton.currentImage?.withRenderingMode(.alwaysTemplate), for:.normal)
        
        // 버튼들의 렌더링모드를 템플릿으로 해주어야 이미지틴트 색이 바뀐다.
        let cropimg = UIImage(named: "Cropimg")?.withRenderingMode(.alwaysTemplate)
        CropButton.setImage(cropimg, for: .normal)
        
        let rectimg = UIImage(named: "Drawimg")?.withRenderingMode(.alwaysTemplate)
        RectButton.setImage(rectimg, for: .normal)
        
        let revertimg = UIImage(named: "Reverimg")?.withRenderingMode(.alwaysTemplate)
        RevertButton.setImage(revertimg, for: .normal)
        
        let inpaintimg = UIImage(named: "inpaintimg")?.withRenderingMode(.alwaysTemplate)
        InpaintButton.setImage(inpaintimg, for: .normal)
        
        let detectimg = UIImage(named: "Detectimg")?.withRenderingMode(.alwaysTemplate)
        DetectButton.setImage(detectimg, for: .normal)
        
        let pencilimg = UIImage(named: "pencil")?.withRenderingMode(.alwaysTemplate)
        PaintButton.setImage(pencilimg, for: .normal)
        
        let mergeimg = UIImage(named: "mergeimg")?.withRenderingMode(.alwaysTemplate)
        mergeButton.setImage(mergeimg, for: .normal)
        
        let contrastimg = UIImage(named: "contrastimg")?.withRenderingMode(.alwaysTemplate)
        ContrastButton.setImage(contrastimg, for: .normal)
        
        let brightimg = UIImage(named: "brightimg")?.withRenderingMode(.alwaysTemplate)
        BrightButton.setImage(brightimg, for: .normal)
        
    }


    // 뷰 크기 조절 함수 //
    func fitratio(){
        print(MV.frame.width)
        //뷰의 w크기가 슈퍼뷰의 w크기보다 작을때 뷰의 크기를 키움
        if SourceView.frame.width < MV.frame.width{
            let ratio: CGFloat = CGFloat(MV.frame.width / SourceView.frame.width)
            SourceView.transform = SourceView.transform.scaledBy(x: ratio, y: ratio)
            SourceView.center = CGPoint(x: 180, y: 333)
            scale = scale * ratio
            print(SourceView.frame)
            print(MV.frame)
            print(SourceView.frame.origin.x)
            print(ratio)
        }
        if SourceView.frame.height < 282{
            let ratio: CGFloat = CGFloat(282 / SourceView.frame.height)
            SourceView.transform = SourceView.transform.scaledBy(x: ratio, y: ratio)
            SourceView.center = CGPoint(x: 180, y: 333)
            scale = scale * ratio
     
        }
        //뷰의 공백이 오른쪽일때 공백만큼 translate
        if(SourceView.frame.origin.x < 0){
            if(SourceView.center.x+SourceView.frame.width/2 < MV.frame.width){
                print((MV.frame.width - (SourceView.center.x+SourceView.frame.width/2)))
                SourceView.center = CGPoint(x: SourceView.center.x + (MV.frame.width - (SourceView.center.x+SourceView.frame.width/2)) , y: SourceView.center.y)
            }
            
        }
        //뷰의 공백이 왼쪽일떄 공백만큼 translate
        if((SourceView.frame.origin.x+SourceView.frame.width) > MV.frame.width){
            
            if(SourceView.frame.origin.x > 0){
                print("??")
                SourceView.center = CGPoint(x: SourceView.center.x - (SourceView.center.x-SourceView.frame.width/2) , y: SourceView.center.y)
            }
        }
        //이미지뷰가 메인뷰보다 height가 클때 위아래 공백 처리
        /*
        if(SourceView.frame.height > MV.frame.height){
            if(((SourceView.center.y) - (SourceView.frame.height)/2)>50){
                SourceView.center.y = SourceView.center.y - (((SourceView.center.y) - (SourceView.frame.height)/2)-50)
            }
            else if((SourceView.center.y + (SourceView.frame.height/2))<MV.frame.height){
                if((MV.frame.height - (SourceView.center.y+(SourceView.frame.height/2)))>50){
                    SourceView.center.y = SourceView.center.y + ((MV.frame.height - (SourceView.center.y+(SourceView.frame.height/2)))-50)
                }
            }
        }*/
        if((SourceView.center.y+(SourceView.frame.height/2))<474){
            SourceView.center.y = 474 - (SourceView.frame.height)/2
        }
        else if((SourceView.center.y-(SourceView.frame.height/2))>192){
            SourceView.center.y = 192 + (SourceView.frame.height)/2
        }
    }
    
    

    // ** indicator 설정 ** //
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
    
    //alpha = 투명도
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}
