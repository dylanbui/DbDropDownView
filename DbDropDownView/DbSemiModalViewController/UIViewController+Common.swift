//
//  UIViewController+Commons.swift
//  DbDropDownView
//
//  Created by Dylan Bui on 11/5/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

import Foundation
import UIKit

class DbClosureWrapper: NSObject, NSCopying {
    var closure: (() -> Void)?
    
    convenience init(closure: (() -> Void)?) {
        self.init()
        self.closure = closure
    }
    
    func copy(with zone: NSZone?) -> Any {
        let wrapper: DbClosureWrapper = DbClosureWrapper()
        
        wrapper.closure = self.closure
        
        return wrapper;
    }
    
}

private var DbCustomOptions: Void?

extension UIViewController {
    
    var defaultOptions: [DbSemiModalOption: Any] {
        return [
            .traverseParentHierarchy : true,
            .animationDuration       : 0.5, // No effect if transitionStyle is : slideUp, slideDown
            .parentAlpha             : 0.3,
            .shadowOpacity           : 0.0, // Shadow for view content
            .contentYOffset          : 5.0, // Y Offect
            .transitionStyle         : DbSemiModalTransitionStyle.slideUp,
//            .transitionStyle         : DbSemiModalTransitionStyle.fadeInOut,
            .disableCancel           : true
        ]
    }
    
    func registerOptions(_ options: [DbSemiModalOption: Any]?) {
        // options always save in parent viewController
        var targetVC: UIViewController = self
        while targetVC.parent != nil {
            targetVC = targetVC.parent!
        }
        
        objc_setAssociatedObject(targetVC, &DbCustomOptions, options, .OBJC_ASSOCIATION_RETAIN)
    }
    
    func options() -> [DbSemiModalOption: Any] {
        var targetVC: UIViewController = self
        while targetVC.parent != nil {
            targetVC = targetVC.parent!
        }
        
        if let options = objc_getAssociatedObject(targetVC, &DbCustomOptions) as? [DbSemiModalOption: Any] {
            var defaultOptions: [DbSemiModalOption: Any] = self.defaultOptions
            defaultOptions.merge(options) { (_, new) in new }
            
            return defaultOptions
        } else {
            return defaultOptions
        }
    }
    
    func optionForKey(_ optionKey: DbSemiModalOption) -> Any? {
        let options = self.options()
        let value = options[optionKey]
        
        let isValidType = value is Bool ||
            value is Double ||
            value is DbSemiModalTransitionStyle ||
            value is UIView
        
        if isValidType {
            return value
        } else {
            return defaultOptions[optionKey]
        }
    }
    
}

//import QuartzCore
//
//public class DbPushBackAnimationGroup: CAAnimationGroup {
//    public convenience init(forward: Bool, viewHeight: CGFloat, options: [DbSemiModalOption: Any]) {
//        self.init()
//
//        var id1 = CATransform3DIdentity
//        id1.m34 = 1.0 / -900
//        id1 = CATransform3DScale(id1, 0.95, 0.95, 1)
//
////        let angleFactor: CGFloat = UIDevice.isPad() ? 7.5 : 15.0
//        let angleFactor: CGFloat = 15.0
//        id1 = CATransform3DRotate(id1, angleFactor * CGFloat(Double.pi) / 180.0, 1, 0, 0)
//
//        var id2 = CATransform3DIdentity
//        id2.m34 = id1.m34
//
//        let scale = CGFloat(options[.parentScale] as! Double)
////        let tzFactor: CGFloat = UIDevice.isPad() ? -0.04 : -0.08
//        let tzFactor: CGFloat = -0.08
//
//        id2 = CATransform3DTranslate(id2, 0, viewHeight * tzFactor, 0)
//        id2 = CATransform3DScale(id2, scale, scale, 1)
//
//        let animation = CABasicAnimation(keyPath: "transform")
//        animation.toValue = NSValue(caTransform3D: id1)
//
//        let animationDuration = options[.animationDuration] as! Double
//        animation.duration = animationDuration / 2
//        animation.fillMode = kCAFillModeForwards //CAMediaTimingFillMode().forwards
//        animation.isRemovedOnCompletion = false
////        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//
//        let animation2 = CABasicAnimation(keyPath: "transform")
//        animation2.toValue = NSValue(caTransform3D: forward ? id2 : CATransform3DIdentity)
//        animation2.beginTime = animation.duration
//        animation2.duration = animation.duration
//        animation2.fillMode = kCAFillModeForwards //CAMediaTimingFillMode.forwards
//        animation2.isRemovedOnCompletion = false
//
//        fillMode = kCAFillModeForwards //CAMediaTimingFillMode.forwards
//        isRemovedOnCompletion = false
//        duration = animation.duration * 2
//        animations = [animation, animation2]
//    }
//}



extension UIView {
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame = CGRect(x: x, y: y, width: newValue, height: height)
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame = CGRect(x: x, y: y, width: width, height: newValue)
        }
    }
    
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame = CGRect(x: newValue, y: y, width: width, height: height)
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame = CGRect(x: x, y: newValue, width: width, height: height)
        }
    }
    
}
