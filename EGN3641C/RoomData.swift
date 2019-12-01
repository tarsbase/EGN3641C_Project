//
//  RoomData.swift
//  EGN3641C
//
//  Created by Brandon Baker on 11/30/19.
//  Copyright © 2019 Brandon Baker. All rights reserved.
//

import UIKit

class RoomData: NSObject {
    
    var uniqueName : String!
    var creator : String!
    var password : String?
    var `private` : Bool! = true
    
    public init(dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "uniqueName" : uniqueName = (value as! String)
            case "creator" : creator = (value as! String)
            case "password" : password = (value as? String)
            default: break
            }
        }
    }
    
    public static func createRoomDict(roomName: String, creator: String, password : String?) -> [String : Any] {
        var dict : [String:Any] = [:]
        dict["name"] = roomName
        dict["creator"] = creator
        dict["password"] = password
        dict["private"] = false
        return dict
    }
}
