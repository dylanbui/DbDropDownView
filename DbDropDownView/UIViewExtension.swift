//
//  UIViewExtension.swift
//  DbDropDownView
//
//  Created by Dylan Bui on 12/21/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

// MARK: - Properties Layout
public extension UIView {
    
    /// SwifterSwift: x origin of view.
    public var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    /// SwifterSwift: y origin of view.
    public var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    /// SwifterSwift: Width of view.
    public var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    // SwifterSwift: Height of view.
    public var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    /// SwifterSwift: Size of view.
    public var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    public var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            x = newValue.x
            y = newValue.y
        }
    }
    
    /// SwifterSwift: center x origin of view.
    public var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center.x = newValue
        }
    }
    
    /// SwifterSwift: center y origin of view.
    public var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center.y = newValue
        }
    }
    
    /// SwifterSwift: x origin of view.
    public var top: CGFloat {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
    
    /// SwifterSwift: y origin of view.
    public var left: CGFloat {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    
    /// SwifterSwift: bottom origin of view.
    public var bottom: CGFloat {
        get {
            return y + height
        }
        set {
            y = newValue - height
        }
    }
    
    /// SwifterSwift: bottom origin of view.
    public var right: CGFloat {
        get {
            return x + width
        }
        set {
            x = newValue - width
        }
    }
}


extension UIView
{
    @objc fileprivate func touchBackground(sender: UITapGestureRecognizer)
    {
        hideSameSheetView()
    }
    
    func displaySameSheetView() -> Void
    {
        // -- Width full screen --
        //        var frame = self.frame
        //        frame.size.width = UIScreen.main.bounds.size.width
        //        self.frame = frame
        
        let tableListHeight: CGFloat = 100
        let tableYOffset: CGFloat = 5
        
        //        return Int(UIScreen.main.bounds.size.width)
        //        return Int(UIScreen.main.bounds.size.height)
        self.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 1, width: UIScreen.main.bounds.size.width, height: tableListHeight)
        //self.backgroundColor = UIColor.blue
        self.alpha = 0
        
        // -- Add to root view --
        guard let vclRoot = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("RootViewController not found")
        }
        vclRoot.view.addSubview(self)
        
        
        // 1. create a gesture recognizer (tap gesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchBackground(sender:)))
        // 2. add the gesture recognizer to a view
        vclRoot.view.addGestureRecognizer(tapGesture)
        
        
        // -- Animation display --
        
        UIView.animate(withDuration: 0.9,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        
                        // -- Default .TopToBottom --
                        var valY = vclRoot.view.frame.maxY + tableYOffset
                        if true { //self.displayDirection == .BottomToTop {
                            //                            valY = vclRoot.view.frame.minY - (tableListHeight+tableYOffset)
                            valY = vclRoot.view.frame.maxY - (tableListHeight+tableYOffset)
                        }
                        
                        self.frame = CGRect(x: vclRoot.view.frame.minX,
                                            y: valY,
                                            width: vclRoot.view.frame.width,
                                            height: tableListHeight)
                        self.alpha = 1
                        //                        self.dismissableView.alpha = 1
                        
        }, completion: { (didFinish) -> Void in
            
        })
    }
    
    func hideSameSheetView() -> Void
    {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        
                        // -- Default .TopToBottom --
                        var valY = self.frame.minY
                        if true { //self.displayDirection == .BottomToTop {
                            valY = self.frame.maxY + self.frame.size.height
                        }
                        
                        self.frame = CGRect(x: self.frame.minX,
                                            y: valY,
                                            width: self.frame.width,
                                            height: 0)
                        self.alpha = 0
                        //                        self.dismissableView.alpha = 0
                        
                        
                        
        }, completion: { (didFinish) -> Void in
            //self.dismissableView.removeFromSuperview()
            self.removeFromSuperview()
        })
        
    }
    
    private func safeAreaBottomPadding() -> CGFloat!
    {
        var bottomPadding: CGFloat! = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom
            return bottomPadding
        }
        return 0
    }
    
    
}
