//
//  OtpPage.swift
//  Chattrix
//
//  Created by Nishant on 14/06/25.
//

import SwiftUI
import FirebaseAuth

struct Otp_page : View {
    
    @State var code : String = ""
    @Binding var show : Bool
    @Binding var ID: String
    @State var msg: String = ""
    @State var alert: Bool = false
    @State var navToHome: Bool = false
    @State var loading = false
    @State var creation = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading){
            
            GeometryReader{_ in
                
                VStack(spacing: 20){
                    Spacer()
                    Image("otp")
                        .resizable()
                        .frame(width:350 , height: 220)
                    
                    Text("Verification Code")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    
                    TextField("Enter Code", text: $code)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color("Color"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top , 15)
                    
                    
                    if self.loading{
                        HStack{
                            Spacer()
                            
                            Indicator()
                            
                            Spacer()
                        }
                    }
                    else{
                        
                        // Verification button: if yes than go to home page else back to verfication page
                        
                        Button {
                            
                            self.loading.toggle()
                            
                            let credential = PhoneAuthProvider.provider().credential(
                                withVerificationID: self.ID,
                                verificationCode: self.code
                            )

                            Auth.auth().signIn(with: credential) { result, error in
                                if let error = error {
                                    self.msg = error.localizedDescription
                                    self.alert.toggle()
                                    self.loading.toggle()
                                    return
                                }
                                
                                checkUser { exists, user , uid , pic in
                                    if exists {
                                        
                                        UserDefaults.standard.set(true, forKey: "status")
                                        UserDefaults.standard.set(user, forKey: "UserName")
                                        UserDefaults.standard.set(uid, forKey: "UID")
                                        UserDefaults.standard.set(pic, forKey: "pic")
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                                    }
                                    else{
                                        self.loading.toggle()
                                        self.creation.toggle()
                                    }
                                }
                                
                                

                            }

                            
                        } label: {
                            Text("Verify")
                                .bold()
                                .frame(width: UIScreen.main.bounds.width - 30 , height: 50)
                        }
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                    }
                    
                    Spacer()
                }
            }
            
            Button(action: {
                self.show.toggle()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title)
            }
            .foregroundStyle(.blue)
            
        }
        .padding()
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $alert){
            Alert(title: Text("Error") , message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
        .sheet(isPresented: self.$creation, content: {
//            AccountCreation(show : self.$creation)
            AccountCreation()
        })
    }
}
