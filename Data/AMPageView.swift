//
//  Scroll.swift
//  Data
//
//  Created by hao yin on 2022/8/25.
//

import UIKit

@objc public protocol AMPageViewDelegate:NSObjectProtocol{
    func numberOfChild()->Int
    func childViewAtIndex(index:Int)->UIView
    func currentScrollAtIndex(index:Int)->UIScrollView
    func topView()->UIView
    func topViewHeight()->Int
    func topViewMinHeight()->Int
}

public class AMPageView:UIView,UIScrollViewDelegate{
    public override init(frame:CGRect) {
        super.init(frame: frame)
        
        self.loadStack()
    }
    
    private func loadStack(){
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
        self.scrollView.showsVerticalScrollIndicator = false;
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.topConstaint = self.scrollView.topAnchor.constraint(equalTo: self.topAnchor)
        let scrollC = [
            self.scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.topConstaint!,
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ]
        
        let c = [
            self.stackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
            self.stackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor)
        ]
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addConstraints(c)
        self.addConstraints(scrollC)
        self.scrollView.delegate = self
        _ = AMPageView.loaded
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadStack()
    }
    @IBOutlet public weak var pageDelegate:AMPageViewDelegate?{
        didSet{
            self.reload()
        }
    }
    private var childContentViews:[Int:UIView] = [:]
    private var childScrollViews:[Int:UIScrollView] = [:]
    private var topConstaint:NSLayoutConstraint?
    private var topViewHeightConstaint:NSLayoutConstraint?
    private var topScrollConstaint:NSLayoutConstraint?
    private var topView:UIView?
    private var currentChildView:UIScrollView?{
        return self.childScrollViews[Int(self.scrollView.contentOffset.x / self.frame.width)]
    }
    public func reload(){
        for i in self.stackView.subviews{
            i.removeFromSuperview()
        }
        self.childContentViews.removeAll()
        guard let pageDelegate = pageDelegate else {
            return
        }
        self.topView?.removeFromSuperview()
        let c = pageDelegate.numberOfChild();
        if let w = self.widthConstaint{
            self.removeConstraint(w)
        }
        self.topView = pageDelegate.topView()
        if let topView = topView {
            self.topScrollConstaint = topView.topAnchor.constraint(equalTo: self.topAnchor)
            let top = [
                topView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                topView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                self.topScrollConstaint!
            ]
            self.addSubview(topView)
            self .addConstraints(top)
            self.topViewHeightConstaint = topView.heightAnchor.constraint(equalToConstant: CGFloat(pageDelegate.topViewHeight()))
            self.topView?.addConstraint(self.topViewHeightConstaint!)
            topView.translatesAutoresizingMaskIntoConstraints = false
        }
        let h = pageDelegate.topViewMinHeight()
        self.topConstaint?.constant = CGFloat(h)
        self.widthConstaint = stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: CGFloat(c))
        self.stackView.translatesAutoresizingMaskIntoConstraints = false;
        self.addConstraint(self.widthConstaint!)
        self.load(index: 0)
        self.scrollView.contentOffset = .zero
        self.load(index: 1)
        self.scrollView.isPagingEnabled = true;
    }
    @objc private func handle(pan:UIPanGestureRecognizer){
        guard let scroll =  pan.view as? UIScrollView else { return }
        self.didSubScrollViewDidScroll(scroll:scroll)
    }
    private func load(index:Int){
        guard let pageDelegate = pageDelegate else {
            return
        }
        if nil == self.childContentViews[index]{
            let count = pageDelegate.numberOfChild()
            let view = pageDelegate.childViewAtIndex(index: index)
            let scroll = pageDelegate.currentScrollAtIndex(index: index)
            self.stackView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            let w = view.widthAnchor.constraint(equalTo: self.widthAnchor)
            self.addConstraint(w)
            let l = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.stackView, attribute: .trailing, multiplier: CGFloat(index + 1) / CGFloat(count), constant: 0)
            let c = [
                view.topAnchor.constraint(equalTo: self.stackView.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor),
                l
            ]
            scroll.pageView = self
            self.childContentViews[index] = view
            self.childScrollViews[index] = scroll
            self.stackView.addConstraints(c)
        }
        let v = self.childScrollViews[index]
        v?.contentInset = UIEdgeInsets(top: CGFloat(pageDelegate.topViewHeight() - pageDelegate.topViewMinHeight()), left: 0, bottom: 0, right: 0)
        
    }
    public func didSubScrollViewDidScroll(scroll:UIScrollView){
        if(scroll == currentChildView){
            guard let dele = self.pageDelegate else { return }
            let delta = CGFloat(dele.topViewHeight() - dele.topViewMinHeight())
            if scroll.contentOffset.y >= 0{
                self.topScrollConstaint?.constant = -delta
                self.childScrollViews.values.filter({$0 != scroll}).forEach { s in
                    s.contentOffset = .zero
                }
            }else{
                self.topScrollConstaint?.constant = -delta - scroll.contentOffset.y
                self.childScrollViews.values.filter({$0 != scroll}).forEach { s in
                    s.contentOffset = scroll.contentOffset
                }
            }
        }
    }
    private var widthConstaint:NSLayoutConstraint?
    public var stackView:UIView = UIView()
    public var scrollView:UIScrollView = UIScrollView()
    public var topViewConstentOffset:CGPoint = .zero{
        didSet{
            
        }
    }
    public static let loaded:Bool = {
        guard let m1 = class_getInstanceMethod(UIScrollView.self, NSSelectorFromString("setContentOffset:")) else { return false }
        guard let m2 = class_getInstanceMethod(UIScrollView.self,#selector(UIScrollView.am_setContentOffset(content:))) else { return false }
        method_exchangeImplementations(m1, m2)
        return true
    }()
}

private var pageViewKey:String = "pageViewKey"
public class WeakContent{
    public weak var page:AMPageView?
}
extension UIScrollView{

    @objc public func am_setContentOffset(content:CGPoint){
        self.am_setContentOffset(content: content)
        self.pageView?.didSubScrollViewDidScroll(scroll: self)
    }
    public var pageView:AMPageView?{
        get{
            (objc_getAssociatedObject(self, &pageViewKey) as? WeakContent)?.page
        }
        set{
            let wc = WeakContent()
            wc.page = newValue
            objc_setAssociatedObject(self, &pageViewKey, wc, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
    }
}
