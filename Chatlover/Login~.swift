//
//  Login.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 17/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

class Login {
    
    /// Login function
    ///
    /// - Parameters:
    ///   - email: String with email
    ///   - password: String with password
    ///   - completionHandler: Return User if success otherwise Error
    class func login(email: String, password: String, completionHandler: @escaping (Result<ChatUser>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                completionHandler(Result.failure(error!))
                return
            }
            ChatUser.getChatUser(withId: user!.uid, completionHandler: completionHandler)
        }
    }
    
    /// Register function
    ///
    /// - Parameters:
    ///   - withName: String with user name
    ///   - email: String with user email
    ///   - password: String with user password
    ///   - userImage: UIImage object with picture
    ///   - completionHandler: Return User if success, otherwise Error
    class func register(withName: String, email: String, password: String, userImage: UIImage, completionHandler: @escaping (Result<ChatUser>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                completionHandler(Result.failure(error!))
                return
            }
            
            let request = user!.createProfileChangeRequest()
            request.displayName = withName
            request.commitChanges(completion: { (error) in
                if let error = error {
                    completionHandler(Result.failure(error))
                } else {
                    ChatUser.createChatUser(completionHandler: completionHandler)
                }
            })
        }
    }
}
