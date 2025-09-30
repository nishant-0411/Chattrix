//
//  CheckUser.swift
//  Chattrix
//
//  Created by Nishant on 14/06/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

func checkUser(completion: @escaping(Bool,String,String,String)-> Void){
    
    let db = Firestore.firestore()
    
    db.collection("Users").getDocuments { (snap, error) in
        if error != nil{
            print((error?.localizedDescription)!)
            return
        }
        for i in snap!.documents{
            
            if i.documentID == Auth.auth().currentUser!.uid{
                completion(true , i.get("name") as! String , i.documentID , i.get("pic") as! String)
                return
            }
        }
        completion(false , "","","")
    }
}

