//
//  AlertViewController.swift
//  SPUAlert
//
//  Created by wenyang on 2022/11/8.
//

import UIKit


let ratio =  UIScreen.main.bounds.width / 414

let alertWidth = 332 * ratio


extension UIColor{
    public static func colorCurrentBundle(name:String,compatibleWith:UITraitCollection?)->UIColor?{
        UIColor(named: name, in: currentBundle, compatibleWith: compatibleWith)
    }
}

public func moduleBundle(module:String)->Bundle?{
    guard let path = Bundle.main.path(forResource: module, ofType: "framework", inDirectory: "Frameworks") else { return nil }
    return Bundle(path: path)
}

public let currentBundle:Bundle? = moduleBundle(module: "SPUAlert")

@objc(SPUAlertViewController)
public class AlertViewController: UIViewController {
    let dialogImage:UIImageView = UIImageView()
    let dialogContent:UILabel = UILabel()
    let dialogtitle:UILabel = UILabel()
    let cancel:UIButton = UIButton()
    let primary:UIButton = UIButton()
    
    public var textContent:String
    
    public var buttonCancelText:String
    
    public var buttonPrimaryText:String
    
    public var callback:(Int)->Void
    
    @objc public init(title:String? = nil,content:String,cancel:String,primary:String,callback:@escaping (Int)->Void) {
        self.textContent = content
        self.buttonCancelText = cancel
        self.buttonPrimaryText = primary
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.transition.configController(controller: self)
        self.transition.style = .alert
        self.transition.touchBackAction = {
            callback(-1)
        }
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(self.view.widthAnchor.constraint(equalToConstant: alertWidth))
        
        
        self.view.addSubview(dialogImage)
        self.edge(view: dialogImage)
        let stack = UIStackView(arrangedSubviews: [self.dialogtitle,self.dialogContent])

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18 * ratio
        
        dialogContent.numberOfLines = 0
        dialogContent.textColor = UIColor.colorCurrentBundle(name: "alert_subtitle_color" ,compatibleWith: self.traitCollection)
        dialogContent.text = self.textContent
        dialogContent.font = UIFont.systemFont(ofSize: 15 * ratio)
        
        dialogtitle.numberOfLines = 0
        dialogtitle.textColor = UIColor.colorCurrentBundle(name: "alert_subtitle_color" ,compatibleWith: self.traitCollection)
        dialogtitle.font = UIFont.systemFont(ofSize: 16 * ratio , weight: .semibold)
        dialogtitle.text = self.title
        dialogtitle.isHidden = self.title == nil
        
        
        let contentContainr = UIView()
        let buttonContainer = UIStackView(arrangedSubviews: [self.cancel,self.primary])
        
        
        self.cancel.setTitleColor(UIColor.colorCurrentBundle(name: "alert_subtitle_color",compatibleWith: self.traitCollection), for: .normal)
        self.cancel.addTarget(self, action: #selector(clickBtn(btn:)), for: .touchUpInside)
        self.cancel.tag = 0
        self.cancel.titleLabel?.font = UIFont .systemFont(ofSize: 18, weight: .semibold)
        self.cancel .setTitle(self.buttonCancelText, for: .normal)
        
        
        self.primary.setTitleColor(UIColor.colorCurrentBundle(name: "alert_title_color",compatibleWith: self.traitCollection), for: .normal)
        self.primary.addTarget(self, action: #selector(clickBtn(btn:)), for: .touchUpInside)
        self.primary.setTitle(self.buttonPrimaryText, for: .normal)
        self.primary.titleLabel?.font = UIFont .systemFont(ofSize: 18, weight: .semibold)
        self.primary.tag = 1
        contentContainr.addSubview(stack)
        self.edge(view: stack,edge: UIEdgeInsets(top: 20, left: 35, bottom: 20, right: 35))
        buttonContainer.axis = .horizontal
        buttonContainer.distribution = .fillEqually
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addConstraint(buttonContainer.heightAnchor.constraint(equalToConstant: 52 * ratio))
        
        let sectionContainer = UIStackView(arrangedSubviews: [contentContainr,buttonContainer])
        sectionContainer.axis = .vertical
        self.view.addSubview(sectionContainer)
        self.edge(view: sectionContainer)
        

    }
    
    public func edge(view:UIView,edge:UIEdgeInsets = UIEdgeInsets.zero){
        let c = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(edge.left)-[view]-\(edge.right)-|", metrics: nil, views: ["view":view]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(edge.top)-[view]-\(edge.bottom)-|", metrics: nil, views: ["view":view])
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.superview?.addConstraints(c)
    }
    func createAsset(){
        let color = UIColor.colorCurrentBundle(name: "alert_background_color", compatibleWith: self.traitCollection)
        let lcolor = UIColor.colorCurrentBundle(name: "alert_line_color", compatibleWith: self.traitCollection)
        let image = AlertAssetsImage.alertBackgroundImage(color: color!, lineColor: lcolor!, size: alertWidth, radius: 3, buttomHeight: 52)
        self.dialogImage.image = image
    }
    public var transition:AlertTransitionManager = AlertTransitionManager()
    
    
    @objc public func clickBtn(btn:UIButton){
        self.dismiss(animated: true)
        self.callback(btn.tag)
    }
    
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.createAsset()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
