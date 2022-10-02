//
//  Controller.swift
//  Ammo
//
//  Created by wenyang on 2022/9/22.
//

import Foundation
import UIKit
import ObjectiveC

public class YHPageContentView:UIView{

    public weak var scrollView:UIScrollView?
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    public func didScroll(scrollView:UIScrollView){
        
    }
    public fileprivate(set) var index:Int = 0
    public private(set) var contentOffset:CGFloat = 0
    public func setContentOffset(offset:CGFloat){
        self.contentOffset = offset
    }
}
@objc public protocol YHPageViewIndicate:NSObjectProtocol{
    func indicateOffset(offset:CGFloat)
    weak var pageView:YHPageView? { get set }
    var view:UIView { get }
}
@objc public protocol YHPageViewPage:NSObjectProtocol{
    weak var pageView:YHPageView? { get set }
    var view:UIView { get }
    var scrollView:UIScrollView { get }
}
@objc public protocol YHPageViewDelegate:NSObjectProtocol{
    @objc func numberOfPage()->NSInteger
    @objc func pageOfIndex(index:Int)->YHPageViewPage
    @objc optional func headerView()->UIView
    @objc optional func indicateView()->YHPageViewIndicate
    @objc optional func heightOfHeaderView()->NSInteger
    @objc optional func heightOfIndicateView()->NSInteger
    @objc optional func headerScrollOffset()->NSInteger
}

public class YHPageView:UIView,UIScrollViewDelegate,UIGestureRecognizerDelegate{
    @objc @IBOutlet public weak var indicate:YHPageViewIndicate?
    @objc @IBOutlet public weak var delegate:YHPageViewDelegate?{
        didSet{
            if(oldValue == nil){
                self.reload()
            }
        }
    }
    public var index:Int{
        get{
            Int(self.pageScrollView.contentOffset.x / self.frame.width)
        }
        set{
            self.pageScrollView.contentOffset = CGPoint(x: CGFloat(newValue) * self.frame.width, y: 0)
        }
    }
   //主动操作
    public func reloadHeader(){
        self.headerView?.removeFromSuperview()
        self.indicate?.view.removeFromSuperview()
        self.resize()
        self.loadHeader()
        self.loadIndicate()
    }
    public func resize(){
        guard let delegate = delegate else {
            return
        }
        let hh = delegate.heightOfHeaderView?() ?? 0
        let hi = delegate.heightOfIndicateView?() ?? 0
        self.headerHeight?.constant = CGFloat(hh)
        self.indicateHeight?.constant = CGFloat(hi)
        
        
        self.headerScrollOffset = delegate.headerScrollOffset?() ?? 0
        
//        self.mainContentHeight?.constant = CGFloat(-self.headerScrollOffset);
        self.limitOfScroll = hh + hi - self.headerScrollOffset;
        
        if Int(self.mainScrollView.contentOffset.y) > self.limitOfScroll{
            self.mainTop?.constant = -CGFloat(self.limitOfScroll)
        }
    }
    public func reload(){
        self.content.forEach { i in
            i.value.view.removeFromSuperview()
        }
        
        self.content.removeAll()
        guard let delegate = delegate else {
            return
        }
        self.loadPage(index: self.index)
        if let widthConstaint = widthConstaint {
            self.pageScrollView.removeConstraint(widthConstaint)
        }
        let w = self.pageContentView.widthAnchor.constraint(equalTo: self.pageScrollView.frameLayoutGuide.widthAnchor, multiplier: CGFloat(delegate.numberOfPage()), constant: 0)
        self.widthConstaint = w;
        self.pageScrollView.addConstraints([
            w
        ])
        self.scrollToIndex(index: self.index, animation: false)
        self.reloadHeader()
        
    }
    public func scrollToIndex(index:Int,animation:Bool){
        if(animation){
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.scrollToIndex(index: index, animation: false)
            } completion: { b in
                
            }
        }else{
            self.pageScrollView.contentOffset = CGPoint(x: CGFloat(index) * self.frame.width, y: 0)
            self.loadPage(index: index)
        }
        
    }
    func loadPage(index:Int){
        guard let delegate = self.delegate else { return }
        
        if(delegate.numberOfPage() > index && index >= 0){
            if nil == self.content[index]{
                let page = delegate.pageOfIndex(index: index)
                self.content[index] = page
                let view = page.view
//                page.scrollView.isScrollEnabled = false
                page.scrollView.panGestureRecognizer.isEnabled = false
                page.scrollView.showsVerticalScrollIndicator = false
                page.scrollView.showsHorizontalScrollIndicator = false
                self.pageContentView.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                page.scrollView.contentOffset =  CGPoint(x: 0, y: 0 - page.scrollView.contentInset.top)
                self.pageContentView.addConstraints([
                    view.topAnchor.constraint(equalTo: self.pageContentView.topAnchor),
                    view.bottomAnchor.constraint(equalTo: self.pageContentView.bottomAnchor),
                    NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.pageContentView, attribute: .trailing, multiplier: CGFloat(index + 1) / CGFloat(delegate.numberOfPage()), constant: 0)
                ])
                self.pageScrollView.addConstraints([
                    view.widthAnchor.constraint(equalTo: self.pageScrollView.frameLayoutGuide.widthAnchor)
                ])
            }
            self.syncSubscrollContent(index: self.index)
            self.syncSubscrollOffset(index: self.index)
        }
        
    }

    
    //uiscroll view delegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.pageScrollView == scrollView){
            self.indicate?.indicateOffset(offset: scrollView.contentOffset.x / self.frame.width)
            if(scrollView.panGestureRecognizer.velocity(in: self).x > 0){
                self.loadPage(index: index)
            }else if (scrollView.panGestureRecognizer.velocity(in: self).x < 0){
                self.loadPage(index: index + 1)
            }
        }
        if(self.mainScrollView == scrollView){
            self.syncSubscrollContent(index: self.index)
            if self.limitOfScroll > Int(scrollView.contentOffset.y){
                self.mainTop?.constant = -scrollView.contentOffset.y
                self.content.forEach { i in
                    let cscroll  = i.value.scrollView
                    cscroll.bounces = false
                    self.mainScrollView.bounces = true
                    cscroll.contentOffset =  CGPoint(x: 0, y: 0 - cscroll.contentInset.top)
                }
            }else{
                self.mainTop?.constant = -CGFloat(self.limitOfScroll)
                guard let cscroll = self.currentScroll else { return }
                cscroll.bounces = true;
                self.mainScrollView.bounces = false;
//                self.currentScroll?.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y - CGFloat(self.limitOfScroll) - cscroll.contentInset.top)
            }
        }
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if(scrollView == self.pageScrollView){
            self.loadPage(index: self.index)
        }
        
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView == self.pageScrollView){
            self.loadPage(index: self.index)

        }
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(decelerate == false){
            if(scrollView == self.pageScrollView){
                self.loadPage(index: self.index)
            }
        }
    }
    
    
    public lazy var pageScrollView:UIScrollView = {
        let pageScroll = UIScrollView()
        self.mainScrollView.addSubview(pageScroll)
        pageScroll.translatesAutoresizingMaskIntoConstraints = false;
        let top = pageScroll.topAnchor.constraint(equalTo: self.indicateGuide.bottomAnchor)
        let bottom = pageScroll.bottomAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.bottomAnchor)
        self.addConstraints([
            pageScroll.leadingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.leadingAnchor),
            pageScroll.trailingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.trailingAnchor),
            top,
            bottom
        ])
        pageScroll.isPagingEnabled = true
        pageScroll.delegate = self
        pageScroll.showsVerticalScrollIndicator = false;
        pageScroll.showsHorizontalScrollIndicator = false;
        return pageScroll
    }()
    public lazy var mainScrollView:YHPagerScrollView = {
        let view = YHPagerScrollView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        view.delegate = self
        view.page = self
        return view
    }()
    // 页容器
    private lazy var pageContentView:UIView = {
        let view = UIView()
        self.pageScrollView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.pageScrollView .addConstraints([
            view.topAnchor.constraint(equalTo: self.pageScrollView.frameLayoutGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.pageScrollView.frameLayoutGuide.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.pageScrollView.contentLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.pageScrollView.contentLayoutGuide.trailingAnchor)
        ])
        return view
    } ()
    
    
    private lazy var headerGuide:UILayoutGuide = {
        let g = UILayoutGuide()
        self.addLayoutGuide(g)
        let top = g.topAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.topAnchor)
        let height = g.heightAnchor.constraint(equalToConstant: 0)
        self.mainTop = top
        self.headerHeight = height
        self.addConstraints([
            g.leadingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.leadingAnchor),
            g.trailingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.trailingAnchor),
            top,
            height
        ])
        
        return g
    }()
    
    private lazy var indicateGuide:UILayoutGuide = {
        let g = UILayoutGuide()
        self.addLayoutGuide(g)
        let top = g.topAnchor.constraint(equalTo: self.headerGuide.bottomAnchor)
        let height = g.heightAnchor.constraint(equalToConstant: 0)
        self.indicateHeight = height
        self.addConstraints([
            g.leadingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.leadingAnchor),
            g.trailingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.trailingAnchor),
            top,
            height
        ])
        
        return g
    }()
    public func loadHeader(){
        guard let header = delegate?.headerView?() else {
            return
        }
        self.headerView = header
        header.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(header)
        self.addConstraints([
            header.leadingAnchor.constraint(equalTo: self.headerGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: self.headerGuide.trailingAnchor),
            header.topAnchor.constraint(equalTo: self.headerGuide.topAnchor),
            header.bottomAnchor.constraint(equalTo: self.headerGuide.bottomAnchor),
        ])
    }
    public func loadIndicate(){
        guard let header = delegate?.indicateView?() else {
            return
        }
        let view = header.view
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(header.view)
        header.pageView = self
        self.indicate = header
        self.addConstraints([
            view.leadingAnchor.constraint(equalTo: self.indicateGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.indicateGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.indicateGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.indicateGuide.bottomAnchor),
        ])
    }
    private func syncSubscrollContent(index:Int){
        guard let scroll = self.scrollView(at: index) else { return }
        let min = CGFloat(self.limitOfScroll) + self.frame.size.height
        self.mainScrollView.contentSize = CGSize(width: self.frame.width, height: max(scroll.contentSize.height, min))
    }
    private func syncSubscrollOffset(index:Int){
        guard let scroll = self.scrollView(at: index) else { return }
        self.mainScrollView.delegate = nil
        guard let mt = mainTop else { return }
        if(Int(-mt.constant) == self.limitOfScroll){
            self.mainScrollView.contentOffset = CGPoint(x: 0, y: Int(scroll.contentOffset.y + scroll.contentInset.top) + self.limitOfScroll)
        }
        self.mainScrollView.delegate = self
    }
    //当前页的scrollView
    fileprivate var currentScroll:UIScrollView?{
        return self.scrollView(at: self.index)
    }
    private func scrollView(at:Int)->UIScrollView?{
        return content[self.index]?.scrollView
    }
    var limitOfScroll:Int = 0
    var headerView:UIView?

    var headerScrollOffset:Int = 0;
    //缓存页
    private var content:[Int:YHPageViewPage] = [:]
    // page 宽度
    private var widthConstaint:NSLayoutConstraint?
    // 顶部约束
    private var mainTop:NSLayoutConstraint?
    //header 高度
    private var headerHeight:NSLayoutConstraint?
    //指示器高度
    private var indicateHeight:NSLayoutConstraint?
}
public class YHPagerScrollView:UIScrollView,UIGestureRecognizerDelegate{
    weak var page:YHPageView?{
        didSet{
            self.panGestureRecognizer.delegate = self
        }
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let p = self.page else { return false }
        if(otherGestureRecognizer.view == p.currentScroll && otherGestureRecognizer .isKind(of: UIPanGestureRecognizer.self)){
            return true
        }
        return false
    }
}
