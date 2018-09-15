//
//  Review.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 8/15/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import Foundation

class Review {//:Equatable, Hashable {
    
    var createdOn : String = ""
    var comment : String = ""
    var rating : Double = 0.0
    var greenSkills : Double = 0.0
    var golfer : Golfer? = nil
    var caddie : Caddie? = nil
    var id : Int = 0
    var createdBy : String = ""
    
//    var hashValue: Int {
//        get {
//            return id.hashValue
//        }
//    }
}

//func ==(lhs: Review, rhs: Review) -> Bool {
//    return lhs.id == rhs.id
//}
