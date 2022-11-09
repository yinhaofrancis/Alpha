//
//  File.swift
//  SPUAlert
//
//  Created by wenyang on 2022/11/8.
//

import UIKit

public protocol AlertPresentationControllerDelegate:AnyObject{
    
    func present(backgroundView:UIView,presentedController:UIViewController)
    
    func dismiss(backgroundView:UIView,presentedController:UIViewController)
    
}

public protocol AlertTransitionAnimationDelegate:AnyObject{
    
    func present(top:UIView,bottom:UIView?,complete: @escaping (Bool)->Void)
    
    func dismiss(top:UIView,bottom:UIView?,complete: @escaping (Bool)->Void)
    
    var during:TimeInterval { get }
    
}

public class DefaultAlertTransitionAnimationDelegate:AlertTransitionAnimationDelegate{
    
    public func present(top: UIView, bottom: UIView?, complete: @escaping (Bool) -> Void) {
        top.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        top.alpha = 0
        UIView .animate(withDuration: self.during, delay: 0, options: [.curveEaseInOut]) {
            top.transform = .identity
            top.alpha = 1
        } completion: { b in
            complete(b)
        }
    }
    
    public func dismiss(top: UIView, bottom: UIView?, complete: @escaping (Bool) -> Void) {
        UIView .animate(withDuration: self.during, delay: 0, options: [.curveEaseInOut]) {
            top.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            top.alpha = 0
        } completion: { b in
            complete(b)
        }
    }

    public var during: TimeInterval = 0.25
    
    public static let animation:DefaultAlertTransitionAnimationDelegate = DefaultAlertTransitionAnimationDelegate()
}
public class DefaultSheetTransitionAnimationDelegate:AlertTransitionAnimationDelegate{
    
    public func present(top: UIView, bottom: UIView?, complete: @escaping (Bool) -> Void) {
        let deltaY = UIScreen.main.bounds.size.height - top.frame.minY
        top.transform = CGAffineTransform(translationX: 0, y: deltaY)
        UIView .animate(withDuration: self.during, delay: 0, options: [.curveEaseInOut]) {
            top.transform = .identity
        } completion: { b in
            complete(b)
        }
    }
    
    public func dismiss(top: UIView, bottom: UIView?, complete: @escaping (Bool) -> Void) {
        let deltaY = UIScreen.main.bounds.size.height - top.frame.minY
        UIView .animate(withDuration: self.during, delay: 0, options: [.curveEaseInOut]) {
            top.transform = CGAffineTransform(translationX: 0, y: deltaY)
        } completion: { b in
            complete(b)
        }
    }

    public var during: TimeInterval = 0.25
    
    public static let animation:DefaultSheetTransitionAnimationDelegate = DefaultSheetTransitionAnimationDelegate()
}

public class DefaultAlertPresentationControllerDelegate:AlertPresentationControllerDelegate{
    
    public func present(backgroundView: UIView,presentedController:UIViewController) {
        
        backgroundView.alpha = 0
        
        presentedController.transitionCoordinator?.animate(alongsideTransition: { ctx in
            
            backgroundView.alpha = 1
            
        })
    }
    
    public func dismiss(backgroundView: UIView,presentedController:UIViewController) {
        
        presentedController.transitionCoordinator?.animate(alongsideTransition: { ctx in
            
            backgroundView.alpha = 0
            
        })
    }
    public static let animation:DefaultAlertPresentationControllerDelegate = DefaultAlertPresentationControllerDelegate()
}


public class AlertPresentationController:UIPresentationController{
    
    public enum Style{
        case alert
        
        case sheet
    }
    
    public var style:Style = .alert
    
    public var constraintWidth:CGFloat = 300
    
    public var backgroundView:UIView = UIView()
    
    public var button:UIButton = UIButton()
    
    public var touchBackAction:(()->Void)?
    
    public unowned var animation:AlertPresentationControllerDelegate = DefaultAlertPresentationControllerDelegate.animation
    
    public override func presentationTransitionWillBegin() {
//
        
        self.containerView?.addSubview(self.backgroundView)
        
        self.backgroundView.frame = self.containerView?.frame ?? UIScreen.main.bounds
        
        self.backgroundView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        self.backgroundView.addSubview(button)
        
        button.frame = self.backgroundView.bounds
        
        button.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        self.animation.present(backgroundView: self.backgroundView, presentedController: self.presentedViewController)
        
        super.presentationTransitionWillBegin()

    }
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
    }
    public override func dismissalTransitionWillBegin() {
    
        self.animation.dismiss(backgroundView: self.backgroundView, presentedController: self.presentedViewController)
        super.dismissalTransitionWillBegin()
        
    }
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
    }
    
    @objc public func close(){
        if let call = self.touchBackAction{
            self.presentedViewController.dismiss(animated: true)
            call()
        }
    }
    public override var frameOfPresentedViewInContainerView: CGRect{
        
        let centerSize = self.presentedViewController.view.systemLayoutSizeFitting(CGSize(width: self.constraintWidth, height: UIScreen.main.bounds.height))
        
        switch(self.style){
            
        case .alert:
            let x = (UIScreen.main.bounds.size.width - centerSize.width) / 2;
            
            let y = (UIScreen.main.bounds.size.height - centerSize.height) / 2;
            
            return CGRect(x: x, y: y, width: centerSize.width, height: centerSize.height)
        case .sheet:
            let x = (UIScreen.main.bounds.size.width - centerSize.width) / 2;
            
            let y = (UIScreen.main.bounds.size.height - centerSize.height) - (self.containerView?.safeAreaInsets.bottom ?? 0);
            
            return CGRect(x: x, y: y, width: centerSize.width, height: centerSize.height)
        }
    }
    
    public override func containerViewWillLayoutSubviews() {
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,source:UIViewController) {
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
}


public class AlertTransitionAnimation:NSObject,UIViewControllerAnimatedTransitioning{
    
    public unowned var delegate:AlertTransitionAnimationDelegate = DefaultAlertTransitionAnimationDelegate.animation
    public var isPresentation:Bool = true
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.delegate.during
    }
    public func top(transitionContext: UIViewControllerContextTransitioning)->UIView?{
        if (self.isPresentation){
            return transitionContext.view(forKey: .to)
        }else{
            return transitionContext.view(forKey: .from)
        }
    }
    public func bottom(transitionContext: UIViewControllerContextTransitioning)->UIView?{
        if (!self.isPresentation){
            return transitionContext.view(forKey: .to)
        }else{
            return transitionContext.view(forKey: .from)
        }
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let top = self.top(transitionContext: transitionContext) else {
            transitionContext.completeTransition(true)
            return
        }
        if(isPresentation){
            transitionContext.containerView.addSubview(top)
        }
        
        let bottom = self.bottom(transitionContext: transitionContext)
        if  let bottom {
            if(self.isPresentation){
                transitionContext.containerView.addSubview(bottom)
                transitionContext.containerView.sendSubviewToBack(bottom)
            }
        }
        if(isPresentation){
            self.delegate.present(top: top, bottom: bottom) { b in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }else{
            self.delegate.dismiss(top: top, bottom: bottom) { b in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

public class AlertTransitionManager:NSObject,UIViewControllerTransitioningDelegate{
    
    public var constraintWidth:CGFloat = 300
    
    public var backgroundColor:UIColor = UIColor.black.withAlphaComponent(0.8)
    
    public var touchBackAction:(()->Void)?
    
    public var style:AlertPresentationController.Style = .alert
    
    public unowned var transitionAnimation:AlertTransitionAnimationDelegate = DefaultAlertTransitionAnimationDelegate.animation
    public unowned var presentAnimation:AlertPresentationControllerDelegate = DefaultAlertPresentationControllerDelegate.animation
    
    public func configController(controller:UIViewController){
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self;
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let c = AlertPresentationController(presentedViewController: presented, presenting: presenting, source: source)
        c.style = self.style
        c.constraintWidth = self.constraintWidth
        c.touchBackAction = self.touchBackAction
        c.animation = self.presentAnimation
        c.backgroundView.backgroundColor = self.backgroundColor
        return c
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = AlertTransitionAnimation()
        animation.isPresentation = true
        animation.delegate = self.transitionAnimation
        return animation
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = AlertTransitionAnimation()
        animation.isPresentation = false
        animation.delegate = self.transitionAnimation
        return animation
    }
}
