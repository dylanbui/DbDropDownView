//
//  DbDropDownCommon.swift
//  SearchTextField
//
//  Created by Dylan Bui on 10/28/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

import Foundation
import UIKit

public enum DbDropDownAnimationType: Int {
    case Default
    case Bouncing
    case Classic // This is DropDown
}


////////////////////////////////////////////////////////////////////////
// Search Text Field Theme

public struct DbDropDownTheme
{
    public var cellHeight: CGFloat
    public var bgColor: UIColor
    public var bgCellColor: UIColor
    public var borderColor: UIColor
    public var borderWidth : CGFloat = 0
    public var separatorColor: UIColor
    public var titlefont: UIFont
    public var titleFontColor: UIColor
    public var subtitleFont: UIFont
    public var subtitleFontColor: UIColor
    
    public var checkmarkColor: UIColor? // = nil , dont use checkmark
    public var placeholderColor: UIColor?
    // -- Arrow --
    public var arrowPadding: CGFloat = 7.0
    
    init(cellHeight: CGFloat,
         bgColor:UIColor,
         borderColor: UIColor, separatorColor: UIColor, font: UIFont, fontColor: UIColor, subtitleFontColor: UIColor? = nil)
    {
        self.cellHeight = cellHeight
        self.borderColor = borderColor
        self.separatorColor = separatorColor
        self.bgColor = bgColor
        self.bgCellColor = bgColor
        
        self.titlefont = font
        self.titleFontColor = fontColor
        
        self.subtitleFont = font
        self.subtitleFontColor = subtitleFontColor ?? fontColor
    }
    
    public static func lightTheme() -> DbDropDownTheme
    {
        return DbDropDownTheme(cellHeight: 30,
                                bgColor: UIColor (red: 1, green: 1, blue: 1, alpha: 0.6),
                                borderColor: UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0),
                                separatorColor: UIColor.clear, font: UIFont.systemFont(ofSize: 10), fontColor: UIColor.black)
    }
    
    public static func darkTheme() -> DbDropDownTheme
    {
        return DbDropDownTheme(cellHeight: 30,
                               bgColor: UIColor (red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6),
                               borderColor: UIColor (red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0),
                               separatorColor: UIColor.clear, font: UIFont.systemFont(ofSize: 10), fontColor: UIColor.white)
    }
    
    public static func testTheme() -> DbDropDownTheme
    {
        var theme = DbDropDownTheme(cellHeight: 40,
                               bgColor: UIColor (red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6),
                               borderColor: UIColor (red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0),
                               separatorColor: UIColor.lightGray, font: UIFont.systemFont(ofSize: 13), fontColor: UIColor.blue)
        
        theme.subtitleFont = UIFont.italicSystemFont(ofSize: 10)
        theme.subtitleFontColor = UIColor.brown
        theme.checkmarkColor = UIColor.red // User checkmark
        return theme
    }
}


////////////////////////////////////////////////////////////////////////
// Select Item

open class DbDropDownItem
{
    // Attributed vars
    public var attributedTitle: NSMutableAttributedString?
    public var attributedSubtitle: NSMutableAttributedString?
    
    // Public interface
    public var title: String
    public var subtitle: String?
    public var image: UIImage?
    
    public var rawData: Any?
    
    public init(title: String, subtitle: String?, image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    public init(title: String, subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public init(title: String) {
        self.title = title
    }
}


// Arrow
enum DbDropDownPosition
{
    case left
    case down
    case right
    case up
}

class DbDropDownArrow: UIView
{
    
    var position: DbDropDownPosition = .down {
        didSet{
            switch position {
            case .left:
                self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                break
                
            case .down:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
                
            case .right:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
                
            case .up:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
            }
        }
    }
    
    init(origin: CGPoint, size: CGFloat) {
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        // Get size
        let size = self.layer.frame.width
        
        // Create path
        let bezierPath = UIBezierPath()
        
        // Draw points
        let qSize = size/4
        
        bezierPath.move(to: CGPoint(x: 0, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size/2, y: qSize*3))
        bezierPath.addLine(to: CGPoint(x: 0, y: qSize))
        bezierPath.close()
        
        // Mask to path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}

