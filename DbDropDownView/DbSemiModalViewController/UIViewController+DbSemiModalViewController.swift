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

private let dbSemiModalOverlayTag = 10001
private let dbSemiModalScreenshotTag = 10002
private let dbSemiModalModalViewTag = 10003

public enum DbSemiModalOption: String {
    case traverseParentHierarchy
    case pushParentBack
    case animationDuration
    case parentAlpha
    case parentScale
    case shadowOpacity
    case transitionStyle
    case disableCancel
    case backgroundView
}

public enum DbSemiModalTransitionStyle: String {
    case slideUp
    case fadeInOut
    case fadeIn
    case fadeOut
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
        //let targetParentVC = parentTargetViewController()
        
        if targetView.subviews.contains(view) {
            return
        }
        
        objc_setAssociatedObject(view, &dbSemiModalPresentingViewController, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
//        NotificationCenter.default.addObserver(targetParentVC,
//                                               selector: #selector(interfaceOrientationDidChange(_:)),
//                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
//                                               object: nil)
        
        let semiViewHeight = view.frame.size.height
        let semiViewFrame = CGRect(x: 0, y: targetView.height - semiViewHeight, width: targetView.width, height: semiViewHeight)
        
        let overlay = overlayView()
        targetView.addSubview(overlay)
        
        let screenshot = addOrUpdateParentScreenshotInView(overlay)
        
        let duration = optionForKey(.animationDuration) as! TimeInterval
        UIView.animate(withDuration: duration, animations: {
            screenshot.alpha = CGFloat(self.optionForKey(.parentAlpha) as! Double)
            // screenshot.alpha = 1.0
        })
        
        let transitionStyle = optionForKey(.transitionStyle) as! DbSemiModalTransitionStyle
        if transitionStyle == .slideUp {
            view.frame = semiViewFrame.offsetBy(dx: 0, dy: +semiViewHeight)
        } else {
            view.frame = semiViewFrame
        }
        
        view.alpha = 0
        
//        if transitionStyle == .fadeIn || transitionStyle == .fadeOut {
//            view.alpha = 0
//        }
        
//        if UIDevice.isPad() {
//            view.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
//        } else {
//            view.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
//        }
        view.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        view.tag = dbSemiModalModalViewTag
//        view.isUserInteractionEnabled = false
        
        targetView.addSubview(view)
//        targetView.insertSubview(overlay, belowSubview: view)
//        targetView.insertSubview(view, aboveSubview: overlay)
//        targetView.bringSubview(toFront: view)
//        targetView.sendSubview(toBack: overlay)
        
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = Float(optionForKey(.shadowOpacity) as! Double)
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        UIView.animate(withDuration: duration, animations: {
            if transitionStyle == .slideUp {
                view.frame = semiViewFrame
            } else if transitionStyle == .fadeIn || transitionStyle == .fadeInOut {
                // view.alpha = 1
            }
            view.alpha = 1
        }, completion: { finished in
            if finished {
                NotificationCenter.default.post(name: .dbSemiModalDidShow, object: self)
                completion?()
            }
        })
    }
    
    func parentTargetViewController() -> UIViewController {
        var viewController: UIViewController = self
        
        if optionForKey(.traverseParentHierarchy) as! Bool {
            while viewController.parent != nil {
                viewController = viewController.parent!
            }
        }
        
        return viewController
    }
    
    func parentTargetView() -> UIView {
        return parentTargetViewController().view
    }
    
    @discardableResult
    func addOrUpdateParentScreenshotInView(_ screenshotContainer: UIView) -> UIView {
        let targetView = parentTargetView()
        let semiView = targetView.viewWithTag(dbSemiModalModalViewTag)

        screenshotContainer.isHidden = true
        semiView?.isHidden = true

        var snapshotView = screenshotContainer.viewWithTag(dbSemiModalScreenshotTag) ?? UIView()
        snapshotView.removeFromSuperview()

        snapshotView = targetView.snapshotView(afterScreenUpdates: true) ?? UIView()
        snapshotView.tag = dbSemiModalScreenshotTag

        screenshotContainer.addSubview(snapshotView)

//        if optionForKey(.pushParentBack) as! Bool {
//            let animationGroup = DbPushBackAnimationGroup(forward: true,
//                                                        viewHeight: parentTargetView().height,
//                                                        options: self.options())
//            snapshotView.layer.add(animationGroup, forKey: "pushedBackAnimation")
//        }

        screenshotContainer.isHidden = false
        semiView?.isHidden = false

        return snapshotView
    }
    
//    @objc func interfaceOrientationDidChange(_ notification: Notification) {
//        guard let overlay = parentTargetView().viewWithTag(dbSemiModalOverlayTag) else { return }
//        let view = addOrUpdateParentScreenshotInView(overlay)
//        view.alpha = CGFloat(self.optionForKey(.parentAlpha) as! Double)
//
//    }
    
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
//                let originX = UIDevice.isPad() ? (targetView.width - modal.width) / 2 : 0
                let originX: CGFloat = 0.0
                modal.frame = CGRect(x: originX, y: targetView.height, width: modal.width, height: modal.height)
            } else if transitionStyle == .fadeOut || transitionStyle == .fadeInOut {
                // modal.alpha = 0.0
            }
            modal.alpha = 0.0
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
        
//        if let screenshot = overlay.subviews.first {
//            if let pushParentBack = optionForKey(.pushParentBack) as? Bool , pushParentBack {
//                let animationGroup = DbPushBackAnimationGroup(forward: false,
//                                                            viewHeight: parentTargetView().height,
//                                                            options: self.options())
//                screenshot.layer.add(animationGroup, forKey: "bringForwardAnimation")
//            }
//            UIView.animate(withDuration: duration, animations: {
//                screenshot.alpha = 1
//            }, completion: { finished in
//                if finished {
//                    NotificationCenter.default.post(name: .dbSemiModalDidHide, object: self)
//                    completion?()
//                }
//            })
//        }
        
    }
    
    func overlayView() -> UIView
    {
        var overlay: UIView
        if let backgroundView = optionForKey(.backgroundView) as? UIView {
            overlay = backgroundView
        } else {
            overlay = UIView()
        }
        
        overlay.frame = parentTargetView().bounds
        overlay.backgroundColor = UIColor.black
        // overlay.alpha = 0.0
        overlay.isUserInteractionEnabled = true
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.tag = dbSemiModalOverlayTag
        
        if optionForKey(.disableCancel) as! Bool {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSemiModalView))
//            let tttttapGesture = UITapGestureRecognizer(target: self, action: #selector(touchOverlayBackground(sender:)))
            overlay.addGestureRecognizer(tapGesture)
        }
        return overlay
    }
    
    @objc fileprivate func touchOverlayBackground(sender: UITapGestureRecognizer)
    {
        print("sender.view?.tag = \(String(describing: sender.view?.tag))")
        if (sender.view?.tag == dbSemiModalOverlayTag) {
            print("overlay")
        } else {
            print("thang nao do")
        }
        
        dismissSemiModalView()
    }

    
}

