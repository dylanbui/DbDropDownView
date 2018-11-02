//
//  CalendarView.swift
//  DbDropDownView
//
//  Created by Dylan Bui on 11/2/18.
//  Copyright © 2018 Dylan Bui. All rights reserved.
//

import UIKit

class CalendarView: UIControl
{
    @IBOutlet weak var calendar: FSCalendar!
    
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    // first date in the range
    private var firstDate: Date?
    // last date in the range
    private var lastDate: Date?
    private var datesRange: [Date]?
    
    // Default Init
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        defineCalendar()
    }

    public required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        defineCalendar()
    }

    // -- convenience --
    convenience init()
    {
        self.init(frame: .zero)
        defineCalendar()
    }

    private func defineCalendar() -> Void
    {
        // Do any additional setup after loading the view.
        calendar.allowsMultipleSelection = true
        calendar.calendarHeaderView.backgroundColor = UIColor.white
        
        calendar.locale = Locale(identifier: "vi")
        calendar.calendarHeaderView.calendar.locale = Locale(identifier: "vi")
        calendar.calendarHeaderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        calendar.calendarWeekdayView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        
        calendar.appearance.headerDateFormat = "M - YYYY"
        
        calendar.appearance.headerTitleColor = UIColor.init(red: 95, green: 95, blue: 95, alpha: 1.0)
        
        calendar.appearance.weekdayTextColor = UIColor.init(red: 95, green: 95, blue: 95, alpha: 1.0)
        
        calendar.appearance.titleDefaultColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.54) // Xam
        calendar.appearance.titleTodayColor = UIColor.init(red: 241, green: 116, blue: 35, alpha: 1.0) // Cam
        calendar.appearance.eventSelectionColor = UIColor.white
        calendar.appearance.eventOffset = CGPoint(x: 0, y: -7)
        // calendar.today = nil // Hide the today circle
        calendar.register(FormatCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.clipsToBounds = true // Remove top/bottom line
        
        calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
        calendar.addGestureRecognizer(scopeGesture)
    }
}

