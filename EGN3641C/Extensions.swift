//
//  Extensions.swift
//  EGN3641C
//
//  Created by Brandon Baker on 10/4/19.
//  Copyright © 2019 Brandon Baker. All rights reserved.
//

import UIKit
import Firebase


let db = Firestore.firestore()
let storage = Storage.storage()
let defaults = UserDefaults.standard
let primaryHex : UInt = 0x008577
extension UIFont {
    static let avinerMedium = UIFont(name: "Avenir-Medium", size: 22)!
}
extension UIColor {
    //    static let grayBG = UIColor(red: 66/255, green: 66/255, blue: 80/255, alpha: 1)
    static let darkText = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
    static let darkPromptText = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
    static let grayBG = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
    static let darkGrayBG = UIColor(red: 66/255, green: 66/255, blue: 80/255, alpha: 1)
    static let greenAccent = UIColor(red: 55/255, green: 239/255, blue: 186/255, alpha: 1)
    static let primary = UIColor(red: 0/255, green: 133/255, blue: 119/255, alpha: 1)
    static let accent = UIColor(red: 216/255, green: 27/255, blue: 96/255, alpha: 1)
}

extension NSMutableAttributedString {
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Avenir-Medium", size: 22)!, NSAttributedString.Key.foregroundColor : UIColor.darkText]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
        append(normal)
        return self
    }
    
    @discardableResult func gray(_ text: String, size : CGFloat = 19) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Avenir-Medium", size: size)!, NSAttributedString.Key.foregroundColor : UIColor.gray ]
        let grayString = NSMutableAttributedString(string:text, attributes: attrs)
        append(grayString)
        return self
    }
}
