
//
//  AMPageView.swift
//  Ammo
//
//  Created by wenyang on 2022/9/22.
//

import Foundation
import UIKit
import ObjectiveC

public class AMPageContentView:UIView{

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
@objc public protocol AMPageViewIndicate:NSObjectProtocol{
    func indicateOffset(offset:CGFloat)
    weak var pageView:AMPageView? { get set }
    var view:UIView { get }
}
@objc public protocol AMPageViewPage:NSObjectProtocol{
    weak var pageView:AMPageView? { get set }
    var view:UIView { get }
    var scrollView:UIScrollView { get }
    func viewPageDidLoad()
}
@objc public protocol AMPageViewDelegate:NSObjectProtocol{
    @objc func numberOfPage()->NSInteger
    @objc func pageOfIndex(index:Int)->AMPageViewPage
    @objc optional func headerView()->UIView
    @objc optional func indicateView()->AMPageViewIndicate
    @objc optional func heightOfHeaderView()->NSInteger
    @objc optional func heightOfIndicateView()->NSInteger
    @objc optional func headerScrollOffset()->NSInteger
}
@objc public class AMPageViewCell:UICollectionViewCell{
    public var view:UIView?{
        didSet{
            oldValue?.removeFromSuperview()
            guard let view = view else {
                return
            }
            self.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false;
            self.contentView .addConstraints([
                view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
        }
    }
}

public class AMPageView:UIView,UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate?.numberOfPage() ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(AMPageViewCell.self)", for: indexPath) as! AMPageViewCell
        cell.view = self.loadPage(index: indexPath.item)?.view
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    @objc @IBOutlet public weak var indicate:AMPageViewIndicate?
    @objc @IBOutlet public weak var delegate:AMPageViewDelegate?{
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
        self.loadHeader()
        self.loadIndicate()
    }
    public func resize(){
        guard let delegate = delegate else {
            return
        }
        guard let mt = self.mainTop else { return }
        let hh = delegate.heightOfHeaderView?() ?? 0
        let hi = delegate.heightOfIndicateView?() ?? 0
        self.headerHeight?.constant = CGFloat(hh)
        self.indicateHeight?.constant = CGFloat(hi)
        self.headerScrollOffset = delegate.headerScrollOffset?() ?? 0
        self.limitOfScroll = hh + hi - self.headerScrollOffset
        self.pageHeight?.constant = CGFloat(-self.headerScrollOffset)
        guard let sc = self.currentScroll else { return }
        if(sc.contentOffset.y + sc.contentInset.top > 0.01){
            mt.constant = -CGFloat(limitWithAdjust)
        }else{
            mt.constant = -CGFloat(mainScrollView.contentInset.top)
        }
        
    }
    public func reload(){
        
        self.content.removeAll()
        
        self.reloadHeader()
        self.resize()
        self.pageScrollView.reloadData()
        self.scrollToIndex(index: self.index, animation: false)
        self.mainScrollView.showsVerticalScrollIndicator = false
        self.mainScrollView.showsHorizontalScrollIndicator = false
        
    }
    public func scrollToIndex(index:Int,animation:Bool){
        RunLoop.main.perform(inModes: [.common]) {
            if(animation){
                UIView .animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                    self.pageScrollView.contentOffset = CGPoint(x:CGFloat(index) * self.frame.width, y: 0)
                } completion: { b in
                    RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.5))
                }
            }else{
                self.pageScrollView.contentOffset = CGPoint(x:CGFloat(index) * self.frame.width, y: 0)
            }
//            self.loadPage(index: index)
            RunLoop.main.run(mode: .tracking, before: Date(timeIntervalSinceNow: 0.5))
        }
        RunLoop.main.run(mode: .tracking, before: Date(timeIntervalSinceNow: 0.5))
    }
    func loadPage(index:Int)->AMPageViewPage?{
        guard let delegate = self.delegate else { return nil }
        
        if(delegate.numberOfPage() > index && index >= 0){
            if nil == self.content[index]{
                let page = delegate.pageOfIndex(index: index)
                self.content[index] = page
                page.scrollView.panGestureRecognizer.isEnabled = false
                page.scrollView.showsVerticalScrollIndicator = false
                page.scrollView.showsHorizontalScrollIndicator = false
                RunLoop.main.perform(inModes: [.default]) {
                    page.viewPageDidLoad()
                }
                return page
            }else{
                return self.content[index]
            }
        }
        return nil
    }

    
    //uiscroll view delegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.pageScrollView == scrollView){
            let findex = scrollView.contentOffset.x / self.frame.width
            self.indicate?.indicateOffset(offset: findex)
        }
        if(self.mainScrollView == scrollView){
            self.syncSubscrollContent(index: self.index)
            if self.limitWithAdjust > Int(scrollView.contentOffset.y){
                self.mainTop?.constant = -scrollView.contentOffset.y
                self.content.forEach { i in
                    let cscroll  = i.value.scrollView
                    cscroll.bounces = false
                    self.mainScrollView.bounces = true
                    cscroll.contentOffset =  CGPoint(x: 0, y: 0 - cscroll.contentInset.top)
                }
            }else{
                self.mainTop?.constant = -CGFloat(self.limitWithAdjust)
                guard let cscroll = self.currentScroll else { return }
                cscroll.bounces = true;
                self.mainScrollView.bounces = false;
            }
        }
        
    }
    public lazy var pageScrollView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        layout.scrollDirection = .horizontal
        let pageScroll = UICollectionView(frame: .zero, collectionViewLayout: layout)
        pageScroll.register(AMPageViewCell.self, forCellWithReuseIdentifier: "\(AMPageViewCell.self)")
        self.mainScrollView.addSubview(pageScroll)
        pageScroll.contentInsetAdjustmentBehavior = .never
        pageScroll.translatesAutoresizingMaskIntoConstraints = false;
        let top = pageScroll.topAnchor.constraint(equalTo: self.indicateGuide.bottomAnchor)
        let bottom = pageScroll.heightAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.heightAnchor,constant: -CGFloat(self.headerScrollOffset))
        self.pageHeight = bottom
        self.addConstraints([
            pageScroll.leadingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.leadingAnchor),
            pageScroll.trailingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.trailingAnchor),
            top,
            bottom
        ])
        pageScroll.isPagingEnabled = true
        pageScroll.delegate = self
        pageScroll.dataSource = self
        pageScroll.showsVerticalScrollIndicator = false;
        pageScroll.showsHorizontalScrollIndicator = false;
        return pageScroll
    }()
    public lazy var mainScrollView:AMPagerScrollView = {
        let view = AMPagerScrollView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
        view.delegate = self
        view.contentInsetAdjustmentBehavior = .never
        view.page = self
        return view
    }()
    
    private lazy var headerGuide:UILayoutGuide = {
        let g = UILayoutGuide()
        self.mainScrollView.addLayoutGuide(g)
        let top = g.topAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.topAnchor)
        let height = g.heightAnchor.constraint(equalToConstant: 0)
        self.mainTop = top
        self.headerHeight = height
        self.mainScrollView.addConstraints([
            g.leadingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.leadingAnchor),
            g.trailingAnchor.constraint(equalTo: self.mainScrollView.frameLayoutGuide.trailingAnchor),
            top,
            height
        ])
        
        return g
    }()
    
    private lazy var indicateGuide:UILayoutGuide = {
        let g = UILayoutGuide()
        self.mainScrollView.addLayoutGuide(g)
        let top = g.topAnchor.constraint(equalTo: self.headerGuide.bottomAnchor)
        let height = g.heightAnchor.constraint(equalToConstant: 0)
        self.indicateHeight = height
        self.mainScrollView.addConstraints([
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
        self.mainScrollView.addSubview(header)
        self.mainScrollView.addConstraints([
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
        self.mainScrollView.addSubview(header.view)
        header.pageView = self
        self.indicate = header
        self.mainScrollView.addConstraints([
            view.leadingAnchor.constraint(equalTo: self.indicateGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.indicateGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.indicateGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.indicateGuide.bottomAnchor),
        ])
    }
    fileprivate func syncSubscrollContent(index:Int){
        guard let scroll = self.scrollView(at: index) else { return }
        let min = CGFloat(self.limitWithAdjust) + self.frame.size.height
        self.mainScrollView.contentSize = CGSize(width: self.frame.width, height: max(scroll.contentSize.height, min))
        if let h = self.headerView {
            self.mainScrollView.sendSubviewToBack(h)
        }
        if let iv = self.indicate?.view{
            self.mainScrollView.sendSubviewToBack(iv)
        }
        
    }
    fileprivate func syncSubscrollOffset(index:Int){

        self.mainScrollView.delegate = nil
        guard let mt = mainTop else { return }
        if(Int(-mt.constant) == self.limitWithAdjust){
            self.mainScrollView.contentOffset = self.mainShouldContentOffset
        }
        self.mainScrollView.delegate = self
        self.mainScrollView.contentInsetAdjustmentBehavior = .never
    }
    //当前页的scrollView
    fileprivate var currentScroll:UIScrollView?{
        return self.scrollView(at: self.index)
    }
    private func scrollView(at:Int)->UIScrollView?{
        return content[self.index]?.scrollView
    }
    public func adjustedContentInsetDidChange() {
        self.resize()
    }
    var limitOfScroll:Int = 0
    
    var headerView:UIView?
    var headerScrollOffset:Int = 0;
    var limitWithAdjust:Int{
        return self.limitOfScroll - Int(self.mainScrollView.adjustedContentInset.top)
    }
    public var mainShouldContentOffset:CGPoint{
        guard let currentScroll = currentScroll else {
            return self.mainScrollView.contentOffset
        }
        return CGPoint(x: 0, y: Int(currentScroll.contentOffset.y + currentScroll.contentInset.top) + self.limitWithAdjust)
    }
    //缓存页
    private var content:[Int:AMPageViewPage] = [:]
    // 顶部约束
    private var mainTop:NSLayoutConstraint?
    //header 高度
    private var headerHeight:NSLayoutConstraint?
    //pageHeight 高度
    private var pageHeight:NSLayoutConstraint?
    //指示器高度
    private var indicateHeight:NSLayoutConstraint?
}
public class AMPagerScrollView:UIScrollView,UIGestureRecognizerDelegate{
    weak var page:AMPageView?{
        didSet{
            self.panGestureRecognizer.delegate = self
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let p = self.page else { return false }
        if(otherGestureRecognizer.view == p.currentScroll && otherGestureRecognizer .isKind(of: UIPanGestureRecognizer.self)){
            guard let page = page else {
                return false
            }
            page.syncSubscrollOffset(index:page.index)
            page.syncSubscrollContent(index:page.index)
            return true
        }
        return false
    }
    public override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        self.page?.adjustedContentInsetDidChange()
    }
}
