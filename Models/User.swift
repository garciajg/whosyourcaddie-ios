//
//  User.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 7/23/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class User {
    
    var id : Int = 0
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var state : String = ""
    var address : String = ""
    var city : String = ""
    var phoneNumber : String = ""
    var zipcode : String = ""
    var dateOfBirth : String = ""
    var userType : String = ""
//    var loops : [Any] = []
//    var reviews : [Any] = []

}

class Caddie: User {

    var rating : Int = 0
    var greenSkills : Int = 0
    var caddieId : Int = 0
}

class Golfer:User {
    
}
