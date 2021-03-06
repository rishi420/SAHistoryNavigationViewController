//
//  SAHistoryNavigationTransitionController.swift
//  SAHistoryNavigationViewController
//
//  Created by 鈴木大貴 on 2015/05/26.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit

class SAHistoryNavigationTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private(set) var navigationControllerOperation: UINavigationControllerOperation
    private var currentTransitionContext: UIViewControllerContextTransitioning?
    private var backgroundView: UIView?
    private var alphaView: UIView?
    private let kDefaultScale: CGFloat = 0.8
    private let kDefaultDuration: NSTimeInterval = 0.3
    
    required init(operation: UINavigationControllerOperation) {
        navigationControllerOperation = operation
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return kDefaultDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewContoller = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewContoller = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        currentTransitionContext = transitionContext
        let containerView = transitionContext.containerView()
        
        if let fromView = fromViewContoller?.view, toView = toViewContoller?.view {
            switch navigationControllerOperation {
                case .Push:
                    pushAnimation(transitionContext, toView: toView, fromView: fromView, containerView: containerView)
                case .Pop:
                    popAnimation(transitionContext, toView: toView, fromView: fromView, containerView: containerView)
                case .None:
                    let cancelled = transitionContext.transitionWasCancelled()
                    transitionContext.completeTransition(!cancelled)
            }
        }
    }
}

//MARK: - Internal Methods
extension SAHistoryNavigationTransitionController {
    func forceFinish() {
        let navigationControllerOperation = self.navigationControllerOperation
        if let backgroundView = backgroundView, alphaView = alphaView {
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64((kDefaultDuration + 0.1) * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue()) { [weak self] in
                if let currentTransitionContext = self?.currentTransitionContext {
                    
                    let toViewContoller = currentTransitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
                    let fromViewContoller = currentTransitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
                    
                    if let fromView = fromViewContoller?.view, toView = toViewContoller?.view {
                        switch navigationControllerOperation {
                        case .Push:
                            self?.pushAniamtionCompletion(currentTransitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
                        case .Pop:
                            self?.popAniamtionCompletion(currentTransitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
                        case .None:
                            let cancelled = currentTransitionContext.transitionWasCancelled()
                            currentTransitionContext.completeTransition(!cancelled)
                        }
                        self?.currentTransitionContext = nil
                        self?.backgroundView = nil
                        self?.alphaView = nil
                    }
                }
            }
        }
    }
}

//MARK: - Private Methods
extension SAHistoryNavigationTransitionController {
    private func popAnimation(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, containerView: UIView) {
        
        let backgroundView = UIView(frame: containerView.bounds)
        backgroundView.backgroundColor = .blackColor()
        containerView.addSubview(backgroundView)
        self.backgroundView = backgroundView
        
        toView.frame = containerView.bounds
        toView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kDefaultScale, kDefaultScale)
        containerView.addSubview(toView)
        
        let alphaView = UIView(frame: containerView.bounds)
        alphaView.backgroundColor = .blackColor()
        alphaView.alpha = 0.7
        containerView.addSubview(alphaView)
        self.alphaView = alphaView
        
        fromView.frame = containerView.bounds
        containerView.addSubview(fromView)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseOut, animations: {
            
            toView.transform = CGAffineTransformIdentity
            fromView.frame.origin.x = containerView.frame.size.width
            alphaView.alpha = 0.0
            
            }) { [weak self] finished in
                if finished {
                    self?.popAniamtionCompletion(transitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
                }
        }
    }
    
    private func popAniamtionCompletion(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, backgroundView: UIView, alphaView: UIView) {
        let cancelled = transitionContext.transitionWasCancelled()
        if cancelled {
            toView.transform = CGAffineTransformIdentity
            toView.removeFromSuperview()
        } else {
            fromView.removeFromSuperview()
        }
        
        backgroundView.removeFromSuperview()
        alphaView.removeFromSuperview()
        
        transitionContext.completeTransition(!cancelled)
        
        currentTransitionContext = nil
        self.backgroundView = nil
        self.alphaView = nil
    }
    
    private func pushAnimation(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, containerView: UIView) {
        
        let backgroundView = UIView(frame: containerView.bounds)
        backgroundView.backgroundColor = .blackColor()
        containerView.addSubview(backgroundView)
        self.backgroundView = backgroundView
        
        fromView.frame = containerView.bounds
        containerView.addSubview(fromView)
        
        let alphaView = UIView(frame: containerView.bounds)
        alphaView.backgroundColor = .blackColor()
        alphaView.alpha = 0.0
        containerView.addSubview(alphaView)
        self.alphaView = alphaView
        
        toView.frame = containerView.bounds
        toView.frame.origin.x = containerView.frame.size.width
        containerView.addSubview(toView)
        
        let kDefaultScale = self.kDefaultScale
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseOut, animations: {
            
            fromView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kDefaultScale, kDefaultScale)
            toView.frame.origin.x = 0.0
            alphaView.alpha = 0.7
            
            }) { [weak self] finished in
                if finished {
                    self?.pushAniamtionCompletion(transitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
                }
        }
    }
    
    private func pushAniamtionCompletion(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, backgroundView: UIView, alphaView: UIView) {
        let cancelled = transitionContext.transitionWasCancelled()
        if cancelled {
            toView.removeFromSuperview()
        }
        
        fromView.transform = CGAffineTransformIdentity
        backgroundView.removeFromSuperview()
        fromView.removeFromSuperview()
        alphaView.removeFromSuperview()
        
        transitionContext.completeTransition(!cancelled)
        
        currentTransitionContext = nil
        self.backgroundView = nil
        self.alphaView = nil
    }
}
