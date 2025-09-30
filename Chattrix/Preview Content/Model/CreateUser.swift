//
//  CreateUser.swift
//  Chattrix
//
//  Created by Nishant on 14/06/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

func createUser(name: String, about: String, completion: @escaping (Bool) -> Void) {
    
    guard let uid = Auth.auth().currentUser?.uid else {
        print("❌ UID is nil – user not signed in")
        completion(false)
        return
    }

    print("✅ Got UID: \(uid)")

    let db = Firestore.firestore()

    db.collection("Users").document(uid).setData(["name": name,"about": about,"uid": uid]) { err in
        if let err = err {
            print("❌ Error saving user data: \(err.localizedDescription)")
            completion(false)
            return
        }

        print("✅ User data saved to Firestore")

        UserDefaults.standard.set(true, forKey: "status")
        UserDefaults.standard.set(name, forKey: "UserName")
        UserDefaults.standard.set(uid, forKey: "UID")
        UserDefaults.standard.set("", forKey: "pic")    //this should be taken care of when Storage is used \(url!)
        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)

        completion(true)
    }
}



//func createUser(name : String, about : String , imageData : Data , completion: @escaping (Bool) -> Void){
//    
//    let db = Firestore.firestore()
//    let storage = Storage.storage().reference()
//    let uid = Auth.auth().currentUser?.uid
//    
//    storage.child("profilepics").child(uid!).putData(imageData , metadata: nil){ ( _ , err) in
//        if err != nil{
//            print((err?.localizedDescription)!)
//            return
//        }
//        
//        storage.child("profilepics").child(uid!).downloadURL{ ( url ,err) in
//            if err != nil{
//                print((err?.localizedDescription)!)
//                return
//            }
//            
//            db.collection("Users").document(uid!).setData(
//            ["name":name,"about":about,"pic":"\(url!)","uid":uid!]){ (err) in
//                if err != nil{
//                    print((err?.localizedDescription)!)
//                    return
//                }
//                
//                completion(true)
//                UserDefaults.standard.set(true, forKey: "status")
//                UserDefaults.standard.set(name, forKey: "UserName")
//                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
//            }
//        }
//    }
//}
//
//
//
