//
//  DbSemiModalViewController.swift
//  DbDropDownView
//
//  Created by Dylan Bui on 11/5/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let dbSemiModalDidShow = Notification.Name("dbSemiModalDidShow")
    static let dbSemiModalDidHide = Notification.Name("dbSemiModalDidHide")
    static let dbSemiModalWasResized = Notification.Name("dbSemiModalWasResized")
}

private var dbSemiModalViewController: Void?
private var dbSemiModalDismissBlock: Void?
private var dbSemiModalPresentingViewController: Void?

private let dbSemiModalOverlayTag = 100012
private let dbSemiModalScreenshotTag = 100022
private let dbSemiModalModalViewTag = 100032

public enum DbSemiModalOption: String {
    case traverseParentHierarchy
    case animationDuration
    case parentAlpha
    case shadowOpacity
    case contentYOffset
    case transitionStyle
    case disableCancel
    case backgroundView
}

public enum DbSemiModalTransitionStyle: String {
    case slideUp
    case slideDown
    case fadeInOut
}

extension UIViewController {
    
    public func presentSemiViewController(_ vc: UIViewController,
                                          options: [DbSemiModalOption: Any]? = nil,
                                          completion: (() -> Void)? = nil,
                                          dismissBlock: (() -> Void)? = nil) {
        registerOptions(options)
        let targetParentVC = parentTargetViewController()
        
        targetParentVC.addChildViewController(vc)
        vc.beginAppearanceTransition(true, animated: true)
        
        objc_setAssociatedObject(targetParentVC, &dbSemiModalViewController, vc, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(targetParentVC, &dbSemiModalDismissBlock, DbClosureWrapper(closure: dismissBlock), .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        presentSemiView(vc.view, options: options) {
            vc.didMove(toParentViewController: targetParentVC)
            vc.endAppearanceTransition()
            
            completion?()
        }
    }
    
    public func presentSemiView(_ view: UIView, options: [DbSemiModalOption: Any]? = nil, completion: (() -> Void)? = nil) {
        registerOptions(options)
        let targetView = parentTargetView()
        let targetParentVC = parentTargetViewController()
        
        if targetView.subviews.contains(view) {
            return
        }
        
        objc_setAssociatedObject(view, &dbSemiModalPresentingViewController, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        NotificationCenter.default.addObserver(targetParentVC,
                                               selector: #selector(interfaceOrientationDidChange(_:)),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
        
        let semiViewHeight = view.frame.size.height
        let contentYOffset: CGFloat = CGFloat(optionForKey(.contentYOffset) as! Double)
        let semiViewFrame = CGRect(x: 0, y: targetView.height - semiViewHeight - contentYOffset,
                                   width: targetView.width, height: semiViewHeight)
        
        let overlay = overlayView()
        targetView.addSubview(overlay)
        
        let screenshot = addOrUpdateParentScreenshotInView(overlay)
        
        var duration = optionForKey(.animationDuration) as! TimeInterval
        UIView.animate(withDuration: duration, animations: {
            screenshot.alpha = CGFloat(self.optionForKey(.parentAlpha) as! Double)
        })
        
        let transitionStyle = optionForKey(.transitionStyle) as! DbSemiModalTransitionStyle
        if transitionStyle == .slideUp {
            view.frame = semiViewFrame.offsetBy(dx: 0, dy: +semiViewHeight)
        } else {
            view.frame = semiViewFrame
        }
        
        view.alpha = 0
        view.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        view.tag = dbSemiModalModalViewTag
        targetView.addSubview(view)
//        targetView.insertSubview(view, aboveSubview: overlay)
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = Float(optionForKey(.shadowOpacity) as! Double)
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        duration = (transitionStyle == .slideUp || transitionStyle == .slideDown ? 0.9 : duration)
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        
                        if transitionStyle == .slideUp || transitionStyle == .slideDown {
                            view.frame = semiViewFrame
                        }
                        view.alpha = 1
                        
        }, completion: { (finished) -> Void in
            if finished {
                NotificationCenter.default.post(name: .dbSemiModalDidShow, object: self)
                completion?()
            }
        })
        
//        UIView.animate(withDuration: duration, animations: {
//            if transitionStyle == .slideUp {
//                view.frame = semiViewFrame
//            }
//            view.alpha = 1
//        }, completion: { finished in
//            if finished {
//                NotificationCenter.default.post(name: .dbSemiModalDidShow, object: self)
//                completion?()
//            }
//        })
    }
    
    @objc public func dismissSemiModalView()
    {
        dismissSemiModalViewWithCompletion(nil)
    }
    
    public func dismissSemiModalViewWithCompletion(_ completion: (() -> Void)?) {
        let targetVC = parentTargetViewController()
        
        guard let targetView = targetVC.view
            , let modal = targetView.viewWithTag(dbSemiModalModalViewTag)
            , let overlay = targetView.viewWithTag(dbSemiModalOverlayTag)
            , let transitionStyle = optionForKey(.transitionStyle) as? DbSemiModalTransitionStyle
            , let duration = optionForKey(.animationDuration) as? TimeInterval else { return }
        
        
        let vc = objc_getAssociatedObject(targetVC, &dbSemiModalViewController) as? UIViewController
        let dismissBlock = (objc_getAssociatedObject(targetVC, &dbSemiModalDismissBlock) as? DbClosureWrapper)?.closure
        
        vc?.willMove(toParentViewController: nil)
        vc?.beginAppearanceTransition(false, animated: true)
        
        UIView.animate(withDuration: duration, animations: {
            if transitionStyle == .slideUp {
                let originX: CGFloat = 0.0
                modal.frame = CGRect(x: originX, y: targetView.height, width: modal.width, height: modal.height)
            }
            modal.alpha = 0.0
            overlay.alpha = 0.0
        }, completion: { finished in
            overlay.removeFromSuperview()
            modal.removeFromSuperview()
            
            vc?.removeFromParentViewController()
            vc?.endAppearanceTransition()
            
            dismissBlock?()
            
            objc_setAssociatedObject(targetVC, &dbSemiModalDismissBlock, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            objc_setAssociatedObject(targetVC, &dbSemiModalViewController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            NotificationCenter.default.removeObserver(targetVC, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        })
        
        if let screenshot = overlay.subviews.first {
            UIView.animate(withDuration: duration, animations: {
                screenshot.alpha = 1
            }, completion: { finished in
                if finished {
                    NotificationCenter.default.post(name: .dbSemiModalDidHide, object: self)
                    completion?()
                }
            })
        }
        
    }
    
    fileprivate func parentTargetViewController() -> UIViewController {
        var viewController: UIViewController = self
        
        if optionForKey(.traverseParentHierarchy) as! Bool {
            while viewController.parent != nil {
                viewController = viewController.parent!
            }
        }
        
        return viewController
    }
    
    fileprivate func parentTargetView() -> UIView {
        return parentTargetViewController().view
    }
    
    @objc fileprivate func interfaceOrientationDidChange(_ notification: Notification) {
        guard let overlay = parentTargetView().viewWithTag(dbSemiModalOverlayTag) else { return }
        let view = addOrUpdateParentScreenshotInView(overlay)
        view.alpha = CGFloat(self.optionForKey(.parentAlpha) as! Double)
        
    }
    
    @discardableResult
    fileprivate func addOrUpdateParentScreenshotInView(_ screenshotContainer: UIView) -> UIView {
        let targetView = parentTargetView()
        let semiView = targetView.viewWithTag(dbSemiModalModalViewTag)
        
        screenshotContainer.isHidden = true
        semiView?.isHidden = true
        
        var snapshotView = screenshotContainer.viewWithTag(dbSemiModalScreenshotTag) ?? UIView()
        snapshotView.removeFromSuperview()
        // -- snapshot mobile view --
        snapshotView = targetView.snapshotView(afterScreenUpdates: true) ?? UIView()
        snapshotView.tag = dbSemiModalScreenshotTag
        
        screenshotContainer.addSubview(snapshotView)
        
        screenshotContainer.isHidden = false
        semiView?.isHidden = false
        
        return snapshotView
    }
    
    fileprivate func overlayView() -> UIView
    {
        var overlay: UIView
        if let backgroundView = optionForKey(.backgroundView) as? UIView {
            overlay = backgroundView
        } else {
            overlay = UIView()
        }
        
        overlay.frame = parentTargetView().bounds
        overlay.backgroundColor = UIColor.black
        overlay.isUserInteractionEnabled = true
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.tag = dbSemiModalOverlayTag
        
        if optionForKey(.disableCancel) as! Bool {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSemiModalView))
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchOverlayBackground(sender:)))
            overlay.addGestureRecognizer(tapGesture)
        }
        return overlay
    }
    
//    @objc fileprivate func touchOverlayBackground(sender: UITapGestureRecognizer)
//    {
//        print("sender.view?.tag = \(String(describing: sender.view?.tag))")
//        if (sender.view?.tag == dbSemiModalOverlayTag) {
//            print("overlay")
//        } else {
//            print("thang nao do")
//        }
//
//        dismissSemiModalView()
//    }

    
}

