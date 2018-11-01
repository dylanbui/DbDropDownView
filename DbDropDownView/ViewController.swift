//
//  ViewController.swift
//  SearchTextField
//
//  Created by Dylan Bui on 10/27/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var btnShow: UIButton!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var anchor: UIView!
    @IBOutlet weak var anchorPanel: UIView!
    
    var selectBox: DbSelectBox!
    var listView: DbDropDownView!
    
    var listViewPanel: DbDropDownView!
    
    var sheet: DbSheetView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // -- example 1 --
        self.selectBox = DbSelectBox(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        self.selectBox.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY - 150)
        self.selectBox.dropDownView.dataSourceStrings(["Mexico", "USA", "England", "France", "Germany", "Spain", "Italy", "Canada"])
        self.selectBox.placeholder = "Select your country..."
        // Max results list height - Default: No limit
        self.selectBox.dropDownView.tableListHeight = 200
        
        self.selectBox.didSelect { (options, index) in
            print("selectBox: \(options.count) at index: \(index)")
        }

        self.view.addSubview(self.selectBox)

        // -- example 2 --
        listView = DbDropDownView(withAnchorView: anchor)
        listView.dataSourceStrings(["Mexico", "USA", "England", "France", "Germany", "Spain", "Italy", "Canada"])
        
        var theme = DbDropDownViewTheme.testTheme()
        theme.cellHeight = 0 // use auto
        listView.theme = theme
        listView.animationType = .Bouncing
        listView.tableListHeight = 160
        
        listView.registerCellNib(nib: UINib(nibName: "DropDownCell", bundle: nil),
                                 forCellReuseIdentifier: "dropDownCell")
        
//        listView.registerCellNib(nib: UINib(nibName: "CustomDropDownCell", bundle: nil),
//                                 forCellReuseIdentifier: "customDropDownCell")
        
//        listView.cellConfiguration { (options, indexPath, cell) in
//            guard let ddCell = cell as? CustomDropDownCell else {
//                print("Khong dung kieu CustomDropDownCell")
//                return
//            }
//
//            // Setup your custom UI components
//            // cell.logoImageView.image = UIImage(named: "logo_\(index % 10)")
//            guard let lbltext = ddCell.subLabel else {
//                print("Khong dung kieu ddCell.subLabel")
//                return
//            }
//
//            lbltext.text = "\(indexPath.row) - " + options[indexPath.row].title + "- CustomDropDownCell"
//        }
        
        listView.cellConfiguration { (options, indexPath, cell) in
            guard let ddCell = cell as? DropDownCell else {
                print("Khong dung kieu DropDownCell")
                return
            }
            
            // Setup your custom UI components
            // cell.logoImageView.image = UIImage(named: "logo_\(index % 10)")
            guard let lbltext = ddCell.optionLabel else {
                print("Khong dung kieu ddCell.optionLabel")
                return
            }
            
            lbltext.text = "\(indexPath.row) - " + options[indexPath.row].title + "- DropDownCell"
        }
        
        listView.didSelect { (options, index) in
            print("You just select: \(options.count) at index: \(index)")
        }
        
        
        
        
        
        // Define a header - Default: nothing
        // -- Show DbDropDownView same panel style --
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: anchorPanel.frame.width, height: 100))
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        header.textAlignment = .center
        header.font = UIFont.systemFont(ofSize: 14)
        header.text = "TP Hồ Chí Minh"
        header.textColor = UIColor.blue
        header.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        
        listViewPanel = DbDropDownView(withAnchorView: anchorPanel)
        listViewPanel.theme = .testTheme()
        listViewPanel.animationType = .Default //.Bouncing //.Classic
        listViewPanel.tableListHeight = 100
        listViewPanel.tableHeaderView = header
        // listViewPanel.isScrollEnabled = false
        listViewPanel.displayDirection = .BottomToTop
//        listViewPanel.hideOptionsWhenTouchOut = true
        listViewPanel.tableYOffset = 5
        
        
        let header_2 = UILabel(frame: CGRect(x: 0, y: 0, width: anchorPanel.frame.width, height: 200))
        header_2.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        header_2.textAlignment = .center
        header_2.font = UIFont.systemFont(ofSize: 14)
        header_2.text = "TP Hồ Chí Minh"
        header_2.textColor = UIColor.blue
        header_2.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        
        sheet = DbSheetView(withContentView: header_2)

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
//        listView = DbListView(withAnchorView: anchor)
//
//        listView.dataSourceStrings(["Mexico", "USA", "England", "France", "Germany", "Spain", "Italy", "Canada"])
//
//        listView.theme = .testTheme()
//        listView.animationType = .Classic
//        listView.tableListHeight = 160
//        // listView.isScrollEnabled = false
//        //drop.tableYOffset = 5
//
//        listView.didSelect { (options, index) in
//            print("You just select: \(options.count) at index: \(index)")
//        }

        
    }
    
    @IBAction func btnSheet_Click(_ sender: AnyObject)
    {
        sheet.show()
    }

    
    @IBAction func btnShow_Click(_ sender: AnyObject)
    {
        //self.selectBox.showSelectBox()
        listView.showDropDown()
    }

    @IBAction func btnHide_Click(_ sender: AnyObject)
    {
        //self.selectBox.hideSelectBox()
        listView.hideDropDown()
    }
    
    @IBAction func btnShowPanel_Click(_ sender: AnyObject)
    {
        listViewPanel.showDropDown()
    }

    @IBAction func btnHidePanel_Click(_ sender: AnyObject)
    {
        listViewPanel.hideDropDown()
    }


}


