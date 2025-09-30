//
//  Verify.swift
//  Chattrix
//
//  Created by Nishant on 14/06/25.
//

import SwiftUI
import FirebaseAuth

struct Verification_page : View {
    
    @State var num: String = ""
    @State var country_code: String = ""
    @State var show: Bool = false
    @State private var msg: String = ""
    @State private var alert: Bool = false
    @State var ID: String = ""
    
    // to check no null value is sent
    var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20){
                
                Image("v")
                    .resizable()
                    .frame(width:250 , height: 250)
                    
                
                Text("Verify Your Number")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                HStack {
                    TextField("+1", text: $country_code)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .padding()
                        .background(Color("Color"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    TextField("Number", text: $num)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color("Color"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }.padding(.top,15)
                
                // Otp sending button
                Button{
                    
                    Auth.auth().settings?.isAppVerificationDisabledForTesting = true // remove when using a real number
                    
                    PhoneAuthProvider.provider().verifyPhoneNumber("+" + self.country_code + self.num, uiDelegate: nil) { (ID , err) in
                        if let error = err {
                            self.msg = error.localizedDescription
                            self.alert.toggle()
                            return
                        }
                        
                        if let safeID = ID {
                            self.ID = safeID
                            self.show.toggle()
                        } else {
                            self.msg = "Verification ID is nil"
                            self.alert.toggle()
                        }
                    }

                } label: {
                    
                    Text("Send")
                        .bold()
                        .frame(width: UIScreen.main.bounds.width - 30 , height: 50)
                    
                }
                .foregroundStyle(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .navigationDestination(isPresented: $show) {
                    Otp_page(show: $show , ID: $ID)
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
            .padding()
            .alert(isPresented: $alert){
                Alert(title: Text("Error") , message: Text(self.msg), dismissButton: .default(Text("Ok")))
            }
        }
    }
}

