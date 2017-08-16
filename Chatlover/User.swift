//
//  User.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 13/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
    var fcmToken: String
    var name: String
    var uid: String
    
    static var currentUser: User?
    
    /// Register function
    ///
    /// - Parameters:
    ///   - withName: String with user name
    ///   - email: String with user email
    ///   - password: String with user password
    ///   - userImage: UIImage object with picture
    ///   - completionHandler: Return User if success, otherwise Error
    class func register(withName: String, email: String, password: String, userImage: UIImage, completionHandler: @escaping (Result<User>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                completionHandler(Result.failure(error!))
                return
            }
            let fcmToken = Messaging.messaging().fcmToken!
            let registerData = ["fcmToken": fcmToken, "name" : withName, "uid": user!.uid]
            Database.database().reference().child("chat_users").child(user!.uid).setValue(registerData, withCompletionBlock: { (error, _) in
                if error == nil {
                    let user = User(fcmToken: fcmToken, name: withName, uid: user!.uid)
                    completionHandler(Result.success(user))
                } else {
                    completionHandler(Result.failure(error!))
                }
            })
        }
    }
    
    /// Get info about particular user
    ///
    /// - Parameters:
    ///   - forUserId: String with id of user
    ///   - completionHandler: Return User if success otherwise Error
    class func info(forUserId: String, completionHandler: @escaping (Result<User>) -> Void) {
        Database.database().reference().child("chat_users").child(forUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! [String : String]
            let currentLoggedData = User(fcmToken: value["fcmToken"]!, name: value["name"]!, uid: forUserId)
            completionHandler(Result.success(currentLoggedData))
        })
    }

    /// Obser registration of users
    ///
    /// - Parameter completionHandler: Return [User] array of registered users if success, otherwise Error
    class func observRegisteredUsers(completionHandler: @escaping (Result<[User]>) -> Void) {
        Database.database().reference().child("chat_users").observe(.value, with: { (snap) in
            if snap.exists() {
                let values = snap.value as! [String: Any]
                let keys = values.map { $0.key }.filter { $0 != currentUser!.uid }
                let users = keys.map { u -> User in
                    let userDict = values[u] as! [String: Any]
                    let userName = userDict["name"] as! String
                    let fcmToken = userDict["fcmToken"] as! String
                    let userUid = u
                    return User(fcmToken: fcmToken, name: userName, uid: userUid)
                }
                completionHandler(Result.success(users))
            }
        })
    }
    
    /// Login function
    ///
    /// - Parameters:
    ///   - email: String with email
    ///   - password: String with password
    ///   - completionHandler: Return User if success otherwise Error
    class func login(email: String, password: String, completionHandler: @escaping (Result<User>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                completionHandler(Result.failure(error!))
                return
            }
            
            Database.database().reference().child("chat_users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let value = snapshot.value as! [String : String]
                    let currentLoggedData = User(fcmToken: value["fcmToken"]!, name: value["name"]!, uid: user!.uid)
                    completionHandler(Result.success(currentLoggedData))
                }
            })
        }
    }
    
    /// Logout function
    ///
    /// - Parameter completionHandler: True if success otherwise false
    class func logout(completionHandler: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completionHandler(true)
        } catch {
            completionHandler(false)
        }
    }
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - fcmToken: String with token for cloud messaging
    ///   - name: String with name of user
    ///   - uid: String with uid of user
    init(fcmToken: String, name: String, uid: String) {
        self.fcmToken = fcmToken
        self.name = name
        self.uid = uid
    }
}
