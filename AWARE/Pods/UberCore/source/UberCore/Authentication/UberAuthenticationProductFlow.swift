//
//  UberAuthenticationProductFlow.swift
//  UberRides
//
//  Copyright © 2018 Uber Technologies, Inc. All rights reserved.
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

import Foundation

@objc public enum UberProductType : Int {
    /// The main Uber app for requesting rides.
    case rides
    /// The UberEats app for food delivery.
    case eats
}

/**
 * Represents an uber product flow to authenticate with (wrapped as an object for Obj-C compatibility)
 */
@objc(UBSDKUberAuthenticationProductFlow) open class UberAuthenticationProductFlow: NSObject {

    @objc public let uberProductType: UberProductType

    @objc public init(_ uberProductType: UberProductType) {
        self.uberProductType = uberProductType
    }
}
