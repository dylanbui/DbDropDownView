//
//  UIViewExtension.swift
//  DbDropDownView
//
//  Created by Dylan Bui on 11/2/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

import Foundation


extension UIView
{
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
                            valY = vclRoot.view.frame.minY - (tableListHeight+tableYOffset)
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
                            valY = self.frame.minY + self.frame.size.height
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
