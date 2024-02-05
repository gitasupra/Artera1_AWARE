//
//  ButtonExampleViewController.swift
//  Swift SDK
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import UberRides
import CoreLocation

/// This class is a base class for all the button examples (two tone background ViewController)
open class ButtonExampleViewController : UIViewController {
    
    public let topView = UIView()
    public let bottomView = UIView()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(topView)
        view.addSubview(bottomView)
        
        initialSetup()
        addTopViewConstraints()
        addBottomViewConstraints()
    }
    
    // Mark: Private Interface
    
    fileprivate func initialSetup() {
        topView.backgroundColor = UIColor.white
        bottomView.backgroundColor = UIColor.black
    }
    
    fileprivate func addTopViewConstraints() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstriant = NSLayoutConstraint(item: topView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let leftConstraint = NSLayoutConstraint(item: topView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: topView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        view.addConstraints([topConstriant, bottomConstraint, leftConstraint, rightConstraint])
    }
    
    fileprivate func addBottomViewConstraints() {
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstriant = NSLayoutConstraint(item: bottomView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let leftConstraint = NSLayoutConstraint(item: bottomView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: bottomView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        view.addConstraints([topConstriant, bottomConstraint, leftConstraint, rightConstraint])
    }
}

