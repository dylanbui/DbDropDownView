//
//  DbDropDown.swift
//  SearchTextField
//
//  Created by Dylan Bui on 10/28/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

import Foundation
import UIKit


public class DbDropDown: UIControl
{
    ////////////////////////////////////////////////////////////////////////
    // Public interface
    
    /// Force the results list to adapt to RTL languages
    public var forceRightToLeft = false
    
    /// Set the results list's header
    public var resultsListHeader: UIView?
    
    // Move the table around to customize for your layout
    public var tableYOffset: CGFloat = 5.0
    public var tableCornerRadius: CGFloat = 5.0
    /// Maximum height of the table list
    public var tableListHeight = 100
    
    public fileprivate(set) var selectedIndex: Int?
    public var hideOptionsWhenSelect = true
    public var animationType: DbDropDownAnimationType = .Default
    //    public var animationType: UIDropDownAnimationType = .Classic
    //    public var animationType: UIDropDownAnimationType = .Bouncing

    
    /// Set an array of SearchTextFieldItem's to be used for suggestions
    open func dataSourceItems(_ items: [DbDropDownItem]) {
        dataSourceItems = items
    }
    
    /// Set an array of strings to be used for suggestions
    open func dataSourceStrings(_ strings: [String]) {
        var items = [DbDropDownItem]()
        
        for value in strings {
            items.append(DbDropDownItem(title: value))
        }
        
        dataSourceItems(items)
    }
    
    public var placeholder: String! {
        didSet {
            title.text = placeholder
            title.adjustsFontSizeToFitWidth = true
        }
    }
    
    /// Set your custom visual theme, or just choose between pre-defined DbSelectBoxTheme.lightTheme() and DbSelectBoxTheme.darkTheme() themes
    open var theme = DbDropDownTheme.darkTheme()
    
    ////////////////////////////////////////////////////////////////////////
    // Private implementation
    
    fileprivate var tableView: UITableView!
    fileprivate var title: UILabel!
    fileprivate var arrow: DbDropDownArrow!
    
    fileprivate var fontConversionRate: CGFloat = 0.7
    fileprivate static let cellIdentifier = "DbSelectBoxCell"
    
    fileprivate var dataSourceItems = [DbDropDownItem]()
    
    // Closures
//    fileprivate var privatedidSelect: (String, Int) -> () = {option, index in }
    fileprivate var privatedidSelect: ([DbDropDownItem], Int) -> () = {options, index in }
//    (_ filteredResults: [DbSelectBoxItem], _ index: Int) -> Void
//    public typealias DbSelectBoxItemHandler = (_ filteredResults: [DbSelectBoxItem], _ index: Int) -> Void
    
    fileprivate var privateTableWillAppear: () -> () = { }
    fileprivate var privateTableDidAppear: () -> () = { }
    fileprivate var privateTableWillDisappear: () -> () = { }
    fileprivate var privateTableDidDisappear: () -> () = { }
    
    // Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    fileprivate func setup()
    {
        title = UILabel(frame: CGRect(x: 0,
                                      y: 0,
                                      width: (self.frame.width-self.frame.height),
                                      height: self.frame.height))
        title.textAlignment = .center
        self.addSubview(title)
        
        let arrowContainer = UIView(frame: CGRect(x: title.frame.maxX,
                                                  y: 0,
                                                  width: title.frame.height,
                                                  height: title.frame.height))
        arrowContainer.isUserInteractionEnabled = false
        self.addSubview(arrowContainer)
        
        arrow = DbDropDownArrow(origin: CGPoint(x: theme.arrowPadding,
                                      y: theme.arrowPadding),
                      size: arrowContainer.frame.width-(theme.arrowPadding*2))
        arrow.backgroundColor = .black
        arrowContainer.addSubview(arrow)
        
        self.layer.cornerRadius = 3
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        
        self.addTarget(self, action: #selector(touch), for: .touchUpInside)
    }
    
    @objc fileprivate func touch()
    {
        isSelected = !isSelected
        isSelected ? showDropDown() : hideDropDown()
    }
    
    // Create the filter table and shadow view
    fileprivate func buildTableView()
    {
        tableView = UITableView(frame: CGRect.zero)
        
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = theme.borderWidth > 0 ? theme.borderWidth : 0.5
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableHeaderView = resultsListHeader
        if forceRightToLeft {
            tableView.semanticContentAttribute = .forceRightToLeft
        }
        
        // Re-set frames and theme colors
        
        //TableViews use estimated cell heights to calculate content size until they
        //  are on-screen. We must set this to the theme cell height to avoid getting an
        //  incorrect contentSize when we have specified non-standard fonts and/or
        //  cellHeights in the theme. We do it here to ensure updates to these settings
        //  are recognized if changed after the tableView is created
        tableView.estimatedRowHeight = theme.cellHeight
        
//        let tableHeight: CGFloat = CGFloat(maxResultsListHeight)
//        let tableViewFrame = CGRect(x: 0, y: 0, width: self.frame.width - 4, height: tableHeight)
//        self.tableView?.frame = tableViewFrame
        
        tableView.layer.borderColor = theme.borderColor.cgColor
        tableView.layer.cornerRadius = tableCornerRadius
        tableView.separatorColor = theme.separatorColor
        tableView.backgroundColor = theme.bgColor
        
        tableView.reloadData()
    }
    
    // Class methods
    public func resign() -> Bool
    {
        if isSelected {
            hideDropDown()
        }
        return true
    }
    
    // Actions Methods
    public func didSelect(completion: @escaping (_ options: [DbDropDownItem], _ index: Int) -> ())
    {
        privatedidSelect = completion
    }
    
    public func tableWillAppear(completion: @escaping () -> ())
    {
        privateTableWillAppear = completion
    }
    
    public func tableDidAppear(completion: @escaping () -> ())
    {
        privateTableDidAppear = completion
    }
    
    public func tableWillDisappear(completion: @escaping () -> ())
    {
        privateTableWillDisappear = completion
    }
    
    public func tableDidDisappear(completion: @escaping () -> ())
    {
        privateTableDidDisappear = completion
    }
    
    
    public func showDropDown()
    {
        
        privateTableWillAppear()
        
        self.buildTableView()
        
//        let tableHeight: CGFloat = CGFloat(maxResultsListHeight)
//        let tableViewFrame = CGRect(x: 0, y: 0, width: self.frame.width - 4, height: tableHeight)
//        self.tableView?.frame = tableViewFrame
        
        tableView.frame = CGRect(x: self.frame.minX,
                                 y: self.frame.minY,
                                 width: self.frame.width,
                                 height: self.frame.height)
        tableView.alpha = 0
        
        self.superview?.insertSubview(tableView, belowSubview: self)
        
        switch animationType {
        case .Default:
            UIView.animate(withDuration: 0.9,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: { () -> Void in
                            
                            self.tableView.frame = CGRect(x: self.frame.minX,
                                                      y: self.frame.maxY+self.tableYOffset,
                                                      width: self.frame.width,
                                                      height: CGFloat(self.tableListHeight))
                            self.tableView.alpha = 1
                            
                            self.arrow.position = .up
                            
            }, completion: { (didFinish) -> Void in
                            self.privateTableDidAppear()
            })
        case .Bouncing:
            tableView.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
            
            UIView.animate(withDuration: 0.9,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: { () -> Void in
                            
                            self.tableView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                            self.tableView.frame = CGRect(x: self.frame.minX,
                                                      y: self.frame.maxY+self.tableYOffset,
                                                      width: self.frame.width,
                                                      height: CGFloat(self.tableListHeight))
                            self.tableView.alpha = 1
                            
                            self.arrow.position = .up
                            
            }, completion: { (didFinish) -> Void in
                self.privateTableDidAppear()
            })
        case .Classic:
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut, animations: {
                            
                            self.tableView.frame = CGRect(x: self.frame.minX,
                                                      y: self.frame.maxY+self.tableYOffset,
                                                      width: self.frame.width,
                                                      height: CGFloat(self.tableListHeight))
                            self.tableView.alpha = 1
                            
                            self.arrow.position = .up
                            
            }, completion: { (finished) in
                self.privateTableDidAppear()
            })
        
        }
        
    }
    
    public func hideDropDown()
    {
        privateTableWillDisappear()
        
        switch self.animationType {
        case .Default, .Classic:
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: { () -> Void in
                            self.tableView.frame = CGRect(x: self.frame.minX,
                                                      y: self.frame.minY,
                                                      width: self.frame.width,
                                                      height: 0)
                            self.tableView.alpha = 0
                            
                            self.arrow.position = .down
            }, completion: { (didFinish) -> Void in
                self.tableView.removeFromSuperview()
                self.isSelected = false
                self.privateTableDidDisappear()
            })
            
        case .Bouncing:
            
            UIView.animate(withDuration: 0.9,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: { () -> Void in
                            
                            self.tableView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                            self.tableView.center = CGPoint(x: self.frame.midX, y: self.frame.minY)
                            self.tableView.alpha = 0
                            
                            self.arrow.position = .down
            }, completion: { (didFinish) -> Void in
                self.tableView.removeFromSuperview()
                self.isSelected = false
                self.privateTableDidDisappear()
            })
            
        }
        
    }
    
}

extension DbDropDown: UITableViewDelegate, UITableViewDataSource
{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataSourceItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: DbDropDown.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: DbDropDown.cellIdentifier)
        }
        
        // print("title = \(dataSourceItems[(indexPath as NSIndexPath).row].title)")
        // -- Format cell --
        cell!.backgroundColor = theme.bgCellColor
        
        cell!.layoutMargins = UIEdgeInsets.zero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.textLabel?.font = theme.titlefont
        cell!.textLabel?.textColor = theme.titleFontColor
        
        cell!.detailTextLabel?.font = UIFont(name: theme.subtitleFont.fontName, size: theme.subtitleFont.pointSize * fontConversionRate)
        cell!.detailTextLabel?.textColor = theme.subtitleFontColor
        
        // -- Fill data to cell --
        cell!.textLabel?.text = dataSourceItems[(indexPath as NSIndexPath).row].title
        cell!.detailTextLabel?.text = dataSourceItems[(indexPath as NSIndexPath).row].subtitle
        
        if let attributedTitle = dataSourceItems[(indexPath as NSIndexPath).row].attributedTitle {
            cell!.textLabel?.attributedText = attributedTitle
        }
        if let attributedSubtitle = dataSourceItems[(indexPath as NSIndexPath).row].attributedSubtitle {
            cell!.detailTextLabel?.attributedText = attributedSubtitle
        }
        
        cell!.imageView?.image = dataSourceItems[(indexPath as NSIndexPath).row].image

        // -- Check use checkmark --
        cell!.accessoryType = .none
        if theme.checkmarkColor != nil {
            cell!.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
            cell?.tintColor = theme.checkmarkColor
        }
        
        cell!.selectionStyle = .none
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return theme.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // let index = indexPath.row
        //itemSelectionHandler?(filterDataSource, index)
        // clearResults()
        
        selectedIndex = (indexPath as NSIndexPath).row
        
        title.alpha = 0.0
        title.text = "\(self.dataSourceItems[(indexPath as NSIndexPath).row].title)"
        
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
            self.title.alpha = 1.0
        })
        
        tableView.reloadData()
        
        if hideOptionsWhenSelect {
            hideDropDown()
        }
        
        privatedidSelect(dataSourceItems, selectedIndex!)
        
    }
}
