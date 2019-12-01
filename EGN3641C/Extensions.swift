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
extension UIFont {
    static let avinerMedium = UIFont(name: "Avenir-Medium", size: 22)!
}
extension UIColor {
    static let grayBG = UIColor(red: 66/255, green: 66/255, blue: 80/255, alpha: 1)
    static let darkGrayBG = UIColor(red: 66/255, green: 66/255, blue: 80/255, alpha: 1)
    static let greenAccent = UIColor(red: 55/255, green: 239/255, blue: 186/255, alpha: 1)
}

