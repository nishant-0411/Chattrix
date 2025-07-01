//
//  VerificationView.swift
//  Chattrix
//
//  Created by Nishant on 10/06/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import AuthenticationServices
import WidgetKit
import StoreKit
import ActivityKit
import Testing
import FirebaseFirestore
import FirebaseStorage

struct VerificationView: View {
    
    @State var status = UserDefaults.standard.bool(forKey: "status")
    
    var body: some View {
        
        VStack{
            
//            if status{
//                Home_page()
//            }
//            else{
//                NavigationView {
//                    Verification_page()
//                }
//            }
//            
            AccountCreation(show: $status)
            
        }.onAppear{
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { _ in
                status = UserDefaults.standard.bool(forKey: "status")
               
                self.status = status
            }
        }
    }
}

#Preview {
    VerificationView()
}







