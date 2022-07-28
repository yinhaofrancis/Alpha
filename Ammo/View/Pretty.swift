//
//  Pretty.swift
//  Ammo
//
//  Created by hao yin on 2022/6/27.
//

import Foundation
import UIKit

public class PrettyJSON{
    public var stack:[String] = []
    private var last:String{
        self.stack.last ?? ""
    }
    public var attribute:NSAttributedString{
        var current:String = ""
        let result = NSMutableAttributedString()
        for i in code{
            if self.last == "\""{
                if(i == "\""){
                    stack.removeLast(1)
                    current += "\""
                    result.append(self.keyStrStopWord(str: current))
                    current = ""
                }else{
                    current.append(i)
                }
                
            }else{
                if i == "{"{
                    stack.append(String(i))
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                }else if i == "}"{
                    stack.removeLast(1)
                    result.append(self.keyStopWord(str: current))
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                    current = ""
                }else if i == "["{
                    stack.append(String(i))
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                }else if i == "]"{
                    stack.removeLast(1)
                    result.append(self.keyWord(str:String(i) + "\n"))
                    result.append(self.space(n: stack.count))
                    current = ""
                }else if i == ","{
                    result.append(self.keyStopWord(str: current))
                    result.append(self.keyWord(str: ",\n"))
                    result.append(self.space(n: stack.count))
                    current = ""
                }else if i == "\""{
                    stack.append("\"")
                    current += "\""
                }else if i == ":"{
                    result.append(self.keyStartWord(str: current))
                    result.append(self.keyWord(str: ":"))
                    current = ""
                }else{
                    current += String(i)
                }
            }
            
        }
        return result
    }
    private func space(n:Int)->NSAttributedString{
        if(n == 0){
            return NSAttributedString()
        }else{
            return NSAttributedString(string: (0 ..< n).reduce(into: "") { partialResult, _ in
                partialResult += "\t"
            }, attributes: [
                .font:UIFont.systemFont(ofSize: 15)
            ])
        }
    }
    private func keyWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemBlue
        ])
    }
    private func keyStartWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemOrange
        ])
    }
    private func keyStopWord(str:String)->NSAttributedString{
        if str.starts(with: "\""){
            return self.keyStrStopWord(str: str)
        }else{
            return self.keyValStopWord(str: str)
        }
    }
    private func keyStrStopWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemRed
        ])
    }
    private func keyValStopWord(str:String)->NSAttributedString{
        return NSAttributedString(string: str, attributes: [
            .font:UIFont.systemFont(ofSize: 15),
            .foregroundColor:UIColor.systemYellow
        ])
    }
    
    public var code:String
    public init(code:Data) throws{
        try JSONSerialization.jsonObject(with: code)
        guard let str = String(data: code, encoding: .utf8) else { throw NSError(domain: "json error", code: 0)}
        self.code = str
    }
}


@objc public protocol AMScrollState:NSObjectProtocol{
    var lock:Bool { get set }
    var sliver:AMSliverScrollState? { get set }
}
@objc public protocol AMSliverScrollState:NSObjectProtocol{
    var contentOffset:CGPoint { get set }
//    var contentSize:CGSize{ get set }
}

public class AMScrollView:UIScrollView,AMScrollState{
    public var sliver: AMSliverScrollState?
    
    
    public var lock: Bool = false
    
    public override var contentOffset: CGPoint{
        get{
            return super.contentOffset
        }
        set{
            if(lock){
                return
            }else{
                super.contentOffset = newValue
                self.sliver?.contentOffset = newValue
            }
        }
    }
}
public class AMTableView:UITableView,AMScrollState{
    public var sliver: AMSliverScrollState?
    
    
    public var lock: Bool = false
    
    public override var contentOffset: CGPoint{
        get{
            return super.contentOffset
        }
        set{
            if(lock){
                return
            }else{
                super.contentOffset = newValue
                self.sliver?.contentOffset = newValue
            }
        }
    }
}

public class AMCollectionView:UICollectionView,AMScrollState{
    public var sliver: AMSliverScrollState?
    

    public var lock:Bool = false;
    
    public override var contentOffset: CGPoint{
        get{
            return super.contentOffset
        }
        set{
            if(lock){
                return
            }else{
                super.contentOffset = newValue
                self.sliver?.contentOffset = newValue
            }
        }
    }
}


public class AMPageView:AMScrollView{
    
    public weak var pageDelegate:AMPageViewDelegate?
    
    public var contentViews:[Int:UIView] = [:]
    
    public var contentView = UIStackView()
    public var page:Int = 1{
        didSet{
            if self.width != nil{
                self.removeConstraint(self.width!)
            }
            self.width = contentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: CGFloat(self.page))
            self.addConstraint(self.width!)
        }
    }
    public var width:NSLayoutConstraint?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
        let constaint = [
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ]
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(constaint)
        contentView.distribution = .fillEqually
        self.isPagingEnabled = true
        self.contentInsetAdjustmentBehavior = .never
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubview(contentView)
        let constaint = [
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ]
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(constaint)
        contentView.distribution = .fillEqually
        self.isPagingEnabled = true
        self.contentInsetAdjustmentBehavior = .never
    }
    public override var contentOffset: CGPoint{
        didSet{
            if(self.frame.width == 0){
                return
            }
            let c = Int(contentOffset.x / self.frame.width)
            guard let paged = self.pageDelegate else { return }
            self.loadPageView(index: c, pd: paged)
        }
    }
    public func reloadData(){
        if(self.frame.width == 0){
            return
        }
        guard let paged = self.pageDelegate else { return }
        self.page = paged.numberOfPage
        let c = Int(contentOffset.x / self.frame.width)
        
        self.contentView.arrangedSubviews.forEach { v in
            v.removeFromSuperview()
        }
        for _ in 0 ..< self.page{
            let v = UIView()
            v.isOpaque = true
            v.backgroundColor = self.backgroundColor
            self.contentView.addArrangedSubview(v)
        }
        self.loadPageView(index: c, pd: paged)
    }
    public override var backgroundColor: UIColor?{
        didSet{
            for i in self.contentView.arrangedSubviews{
                i.backgroundColor = backgroundColor
            }
        }
    }
    func dequeuePageView(index:Int,pd:AMPageViewDelegate){
        if index < 0{
            return
        }
        if(index >= self.page){
            return
        }
        let paged = pd
        if self.contentViews[index] == nil{
            let v = paged.viewAtIndex(index: index)
            let c = self.contentView.arrangedSubviews[index]
            c.addSubview(v)
            c .addConstraints([
                v.leadingAnchor.constraint(equalTo: c.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: c.trailingAnchor),
                v.topAnchor.constraint(equalTo: c.topAnchor),
                v.bottomAnchor.constraint(equalTo: c.bottomAnchor)
            ])
            v.translatesAutoresizingMaskIntoConstraints = false
            self.contentViews[index] = v
        }
    }
    func loadPageView(index:Int,pd:AMPageViewDelegate){
        self.dequeuePageView(index: index - 1, pd: pd)
        self.dequeuePageView(index: index, pd: pd)
        self.dequeuePageView(index: index + 1, pd: pd)
    }
}
@objc public protocol AMNestViewDelegate:NSObjectProtocol{
    func headerView()->UIView
    func headerHeight()->CGFloat
    func scrollViewTopOffset()->CGFloat
    func scrollView()->UIScrollView
}
public class AMNestContainerView:UIView,UIGestureRecognizerDelegate{
    public var contentOffset:CGPoint{
        get{
            self.bounds.origin
        }
        set{
            self.bounds.origin = newValue
        }
    }
    public var contentSize:CGSize{
        guard let nd = self.nestViewDelegate else { return .zero }
        return CGSize(width: self.frame.width, height: self.self.frame.height + nd.headerHeight() - nd.scrollViewTopOffset())
    }
    private var pan:UIPanGestureRecognizer!
    public weak var nestViewDelegate:AMNestViewDelegate?{
        didSet{
            self.reloadData()
        }
    }
    private var height:NSLayoutConstraint?
    private var offset:NSLayoutConstraint?
    public override init(frame:CGRect) {
        super.init(frame: .zero)
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(AMNestContainerView.handle(pan:)))
        self.addGestureRecognizer(self.pan)
        self.pan.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(AMNestContainerView.handle(pan:)))
        self.addGestureRecognizer(self.pan)
        self.pan.delegate = self
    }
    private var start:CGPoint = .zero
    private var startConstentOffset:CGPoint = .zero
    private var lastV:CGPoint = .zero
    @objc public func handle(pan:UIPanGestureRecognizer){
        switch(pan.state){
        case .began:
            self.start = pan.location(in: self.window)
            self.startConstentOffset = self.contentOffset
            self.lastV = .zero
            break
        case .changed:
            let current = pan.location(in: self.window)
            let currentV = pan.velocity(in: self.window)
            if(self.lastV.y <= 0 && currentV.y >= 0){
                self.startConstentOffset = self.contentOffset
                self.start = pan.location(in: self.window)
            }else if(self.lastV.y >= 0 && currentV.y <= 0){
                self.startConstentOffset = self.contentOffset
                self.start = pan.location(in: self.window)
            }
            self.lastV = currentV
           
            let deltay = current.y - self.start.y
            
            if(self.startConstentOffset.y - deltay < 0){
                self.contentOffset.y = 0
            }else if(self.startConstentOffset.y - deltay > self.contentSize.height - self.frame.height){
                self.contentOffset.y = self.contentSize.height - self.frame.height
            }else{
                self.contentOffset.y = self.startConstentOffset.y - deltay
            }
            
            break
        default:
            UIView .animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                if self.contentOffset.y < 0 {
                    self.contentOffset.y = 0
                }else if self.contentOffset.y > self.contentSize.height - self.frame.height{
                    self.contentOffset.y = self.contentSize.height - self.frame.height
                }
            } completion: { b in
                
            }

            
            break
        }
    }
    public func reloadData(){
        self.subviews.forEach({$0.removeFromSuperview()})
        guard let nd = self.nestViewDelegate else { return }
        let header = nd.headerView()
        let scroll = nd.scrollView()
        self.addSubview(header)
        self.addSubview(scroll)
        let h = header.heightAnchor.constraint(equalToConstant: nd.headerHeight())
        let offset = scroll.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -nd.scrollViewTopOffset())
        self.offset = offset
        self.height = h
        self.addConstraints([
            header.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            header.topAnchor.constraint(equalTo: self.topAnchor),
            h
        ])
        header.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        self.addConstraints([
            scroll.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: header.bottomAnchor),
            offset
        ])
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
    }
}


@objc public protocol AMPageViewDelegate:NSObjectProtocol{
    var numberOfPage:Int { get }
    func viewAtIndex(index:Int)->UIView
}

public class AMPageContainerView:UIView,UIGestureRecognizerDelegate {
    private var pages:[Int:UIView] = [:]
    private var constraintMap:[Int:NSLayoutConstraint] = [:]
    private var pan:UIPanGestureRecognizer!
    public weak var pageDelegate:AMPageViewDelegate?

    public var contentOffset:CGPoint{
        get{
            self.bounds.origin
        }
        set{
            self.bounds.origin = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(AMPageContainerView.handle(pan:)))
        self.addGestureRecognizer(self.pan)
        self.pan.delegate = self
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(AMPageContainerView.handle(pan:)))
        self.addGestureRecognizer(self.pan)
        self.pan.delegate = self
    }
    private var start:CGPoint = .zero
    private var startOffset:CGPoint = .zero
    public var fpage:CGFloat {
        get{
            self.contentOffset.x / self.frame.width
        }
        set{
            self.contentOffset.x = newValue * self.frame.width
            if self.contentOffset.x < 0{
                self.contentOffset.x = 0;
            }
        }
    }
    public var page:Int{
        get{
            return Int(floor(self.fpage + 0.5))
        }
        set{
            self.fpage = CGFloat(self.fpage)
        }
    }
    public var pageNumber:Int{
        return self.pageDelegate?.numberOfPage ?? 0
    }
    @objc public func handle(pan:UIPanGestureRecognizer){
        self.dequeueView(index: self.page - 1)
        self.dequeueView(index: self.page)
        self.dequeueView(index: self.page + 1)
        switch(pan.state){
            
        case .began:
            self.start = pan.location(in: self.window)
            self.startOffset = self.contentOffset
            break
        case .changed:
            let current = pan.location(in: self.window)
            let deltaX = current.x - self.start.x
            print(self.contentOffset,CGFloat(self.pageNumber - 1) * self.frame.width)
            if(self.contentOffset.x >= 0 && self.contentOffset.x <= CGFloat(self.pageNumber - 1) * self.frame.width ){
                self.contentOffset.x = self.startOffset.x - deltaX
            }else{
                if(deltaX < 0){
                    self.contentOffset.x = self.startOffset.x + sqrt(abs(deltaX))
                }else{
                    self.contentOffset.x = self.startOffset.x - sqrt(abs(deltaX))
                }
            }
            break
        default:
            let p = self.fpage - floor(self.fpage)
            let current = pan.velocity(in: self.window)
            if self.fpage > CGFloat(self.pageNumber - 1){
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
                    self.fpage = CGFloat(self.pageNumber - 1)
                } completion: { b in
                    
                }
            }else{
                if p > 0.5{
                    if(current.x > 100){
                        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
                            self.fpage = floor(self.fpage);
                        } completion: { b in
                            
                        }
                    }else{
                        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
                            
                            if(self.fpage + 1 < CGFloat(self.pageNumber)){
                                self.fpage = floor(self.fpage) + 1;
                            }else{
                                self.fpage = CGFloat(self.page)
                            }
                            
                        } completion: { b in
                            
                        }
                    }
                }else{
                    if(current.x < -100){
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
                            if(self.fpage + 1 < CGFloat(self.pageNumber)){
                                self.fpage = floor(self.fpage) + 1;
                            }else{
                                self.fpage = CGFloat(self.page)
                            }
                            
                        } completion: { b in
                            
                        }
                    }else{
                        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut,.allowUserInteraction]) {
                            self.fpage = floor(self.fpage);
                        } completion: { b in
                            
                        }
                    }
                }

            }
            break
        }
    }
    private func dequeueView(index:Int){
        if(index < 0) { return }
        if(index >= self.pageNumber) { return }
        guard let pd = self.pageDelegate else { return  }
        if self.pages[index] != nil {
            let n = self.constraintMap[index]
            n?.constant = self.frame.width * CGFloat(index)
        }else{
            let v = pd.viewAtIndex(index: index)
            self.pages[index] = v
            self.addSubview(v)
            let left = v.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.width * CGFloat(index))
            let n = [
                left,
                v.topAnchor.constraint(equalTo: self.topAnchor),
                v.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                v.widthAnchor.constraint(equalTo: self.widthAnchor)
            ]
            v.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraints(n)
            self.constraintMap[index] = left
        }
        
        
        
    }
    public func reloadData(){
        for i in self.pages{
            i.value.removeFromSuperview()
        }
        self.pages.removeAll()
        self.constraintMap.removeAll()
        self.dequeueView(index: self.page  - 1)
        self.dequeueView(index: self.page)
        self.dequeueView(index: self.page  + 1)
    }
}

public enum AMButtonContent{
    case image(UIImage)
    case imageUrl(URL,UIImage?)
    case attributedText(NSAttributedString)
    case text(UIFont,UIColor,String)
    case space(CGFloat)
}

public class AMButton:UIControl{
    public var normalContent:[AMButtonContent] = []{
        didSet{
            self.displayContent(display: self.normalContent)
            self.addTarget(self, action: #selector(handleClickDown), for: .touchDown)
            self.addTarget(self, action: #selector(handleClick), for: .touchUpInside)
            self.addTarget(self, action: #selector(handleClick), for: .touchUpOutside)
            self.addTarget(self, action: #selector(handleClick), for: .touchCancel)
        }
    }
    public var highlightContent:[AMButtonContent] = []
    public var axis:NSLayoutConstraint.Axis = .horizontal{
        didSet{
            self.stack?.axis = self.axis
        }
    }
    @objc private func handleClickDown(){
        self.displayContent(display: self.highlightContent)
    }
    @objc private func handleClick(){
        self.displayContent(display: self.normalContent)
    }
    private var stack:UIStackView?
    
    private func displayContent(display:[AMButtonContent]) {
        let vs = display.map { c -> UIView in
            switch(c){
                
            case let .image(img):
                return UIImageView(image: img, highlightedImage: nil)
            case let .imageUrl(url,image):
                let uim = UIImageView()
                uim.am_imageUrl(url: url,placeholdImage: image)
                return uim
            case let .attributedText(text):
                let l = UILabel()
                l.attributedText = text
                return l
            case let .space(value):
                let v = UIView()
                v.translatesAutoresizingMaskIntoConstraints = false
                v.addConstraints([
                    v.widthAnchor.constraint(equalToConstant: value),
                    v.heightAnchor.constraint(equalToConstant: value)
                ])
                return v
            case let .text(font,color,text):
                let l = UILabel()
                l.font = font
                l.textColor = color
                l.text = text
                return l
            }
        }
        let new = UIStackView(arrangedSubviews: vs)
        self.addSubview(new)
        self.addConstraints([
            new.leftAnchor.constraint(equalTo: self.leftAnchor),
            new.rightAnchor.constraint(equalTo: self.rightAnchor),
            new.topAnchor.constraint(equalTo: self.topAnchor),
            new.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        new.translatesAutoresizingMaskIntoConstraints = false;
        new.distribution = .equalSpacing
        new.axis = self.axis
        new.alignment = .center
        new.isUserInteractionEnabled = false
        guard let old = self.stack else { self.stack = new; return }
        UIView.transition(from: old, to: new, duration: 0.1, options: [UIView.AnimationOptions.transitionCrossDissolve]) { b in
            old.removeFromSuperview()
        }
        
        self.stack = new
    }
}
extension UIImageView{
    public func am_imageUrl(url:URL,placeholdImage:UIImage? = nil){
        self.image = placeholdImage
        StaticImageDownloader.shared.downloadImage(url: url) {[weak self] img in
            guard let image = img else { return }
            let uiimg = UIImage(cgImage: image)
            self?.image = uiimg
        }
    }
}
