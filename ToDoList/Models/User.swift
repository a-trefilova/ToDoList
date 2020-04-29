//
//  User.swift
//  ToDoList
//
//  Created by Константин Сабицкий on 29.04.2020.
//  Copyright © 2020 Константин Сабицкий. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
