//
//  Thoughts.swift
//  Thoughts
//
//  Created by Jeremy Jung on 1/7/20.
//  Copyright © 2020 Jeremy Jung. All rights reserved.
//

import Foundation
import Firebase

class Thoughts {
    var content: String = ""
    var numLikes = 0
    var numDislikes = 0
    var replies: [String] = []
    var username: String = "anonymous"
    var userID: String = ""
    var imageURL: String = ""
    let ref: DatabaseReference
    
    init(content: String, userID: String, username: String) {
        self.content = content
        self.userID = userID
        self.username = username
        ref = Database.database().reference().child("thoughts").childByAutoId()
    }
    
    init(snapshot: DataSnapshot)
    {
        ref = snapshot.ref
        if let value = snapshot.value as? [String : Any] {
            content = value["content"] as! String
            numLikes = value["numLikes"] as! Int
            numDislikes = value["numDislikes"] as! Int
            userID = value["userID"] as! String
            username = value["username"] as! String
        }
    }
    
    func save() {
        ref.setValue(createDict())
    }
    
    func createDict() -> [String: Any] {
        if let userid = Auth.auth().currentUser?.uid {
            userID = userid
        }
        return [
            "content": content,
            "numLikes": numLikes,
            "numDislikes": numDislikes,
            "userID": userID,
            "username": username
        ]
    }
    
    func like() {
        numLikes += 1
        ref.child("numLikes").setValue(numLikes)
    }
    
    func dislike() {
        numDislikes += 1
        ref.child("numDislikes").setValue(numDislikes)
    }
    
    func undoLike() {
        numLikes = numLikes - 1
        ref.child("numLikes").setValue(numLikes)
    }
    
    func undoDislike() {
        numDislikes = numDislikes - 1
        ref.child("numDislikes").setValue(numDislikes)
    }
}
