//
//  ViewController.swift
//  XYCalendar
//
//  Created by dizzle0722@163.com on 12/16/2020.
//  Copyright (c) 2020 dizzle0722@163.com. All rights reserved.
//

import UIKit
import XYCalendar

let contentWidth: CGFloat = UIScreen.main.bounds.size.width
let contentHeight: CGFloat = UIScreen.main.bounds.size.width

class ViewController: UIViewController {
    let datePicker = XYDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(datePicker)
        addLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addLayout() {
        view.addConstraints([NSLayoutConstraint(item: datePicker,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 100),
                             NSLayoutConstraint(item: datePicker,
                                                attribute: .left,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .left,
                                                multiplier: 1,
                                                constant: 0)])
        datePicker.addConstraints([NSLayoutConstraint(item: datePicker,
                                                      attribute: .width,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1,
                                                      constant: contentWidth),
                                   NSLayoutConstraint(item: datePicker,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1,
                                                      constant: contentHeight + 40)])
    }
}

