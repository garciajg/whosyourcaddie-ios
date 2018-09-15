//
//  Loop.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/15/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class Loop{//}:Equatable, Hashable {
    var startTime : String = ""
    var loopDate : String = ""
    var golfer : Golfer? = nil
    var course : Course? = nil
    var caddie : Caddie? = nil
    var id : Int = 0
    var cancelled : Bool = false
    var accepted : Bool = false
    var isWalking : Bool = true
    var numberOfHoles : String = ""
    
//    var hashValue: Int {
//        get {
//            return id.hashValue
//        }
//    }
}

//func ==(lhs: Loop, rhs: Loop) -> Bool {
//    return lhs.id == rhs.id
//}
