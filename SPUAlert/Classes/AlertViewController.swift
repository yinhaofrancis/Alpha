//
//  AlertViewController.swift
//  SPUAlert
//
//  Created by wenyang on 2022/11/8.
//

import UIKit

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

public class AlertViewController: UIViewController {
    let dialogImage:UIImageView = UIImageView()
    let dialogContent:UILabel = UILabel()
    let dialogtitle:UILabel = UILabel()
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(dialogImage)
        self.edge(view: dialogImage)
        let stack = UIStackView(arrangedSubviews: [self.dialogtitle,self.dialogContent])
        self.view.addSubview(stack)
        self.edge(view: stack)
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 30
        
        dialogContent.numberOfLines = 0
        dialogContent.textColor = UIColor(named: "alert_subtitle_color")
        dialogContent.text = "dadadasdf sfasd \n asdasj hasjd asj das\nasdjhas jhas jas jshdaj"
        
        dialogtitle.numberOfLines = 0
        dialogtitle.textColor = UIColor(named: "alert_title_color")
        dialogtitle.font = UIFont .systemFont(ofSize: 24)
        dialogtitle.text = "dadadasdf"

    }
    
    public func edge(view:UIView,edge:UIEdgeInsets = UIEdgeInsets.zero){
        let c = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(edge.left)-[view]-\(edge.right)-|", metrics: nil, views: ["view":view]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(edge.top)-[view]-\(edge.bottom)-|", metrics: nil, views: ["view":view])
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(c)
    }
    func createAsset(){
        let color = UIColor.colorCurrentBundle(name: "alert_background_color", compatibleWith: self.traitCollection)
        let image = AlertAssetsImage.alertBackgroundImage(color: color!)
        self.dialogImage.image = image
    }
    public var transition:AlertTransitionManager = AlertTransitionManager()
    
    public init(title:String,content:String,titles:[String]) {
        super.init(nibName: nil, bundle: nil)
        self.transition.configController(controller: self)
        self.transition.style = .alert
        self.transition.touchBackAction = {
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            if #available(iOS 13.0, *) {
                self.overrideUserInterfaceStyle = .dark
            } else {
                // Fallback on earlier versions
            }
        }
    }
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.createAsset()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
