//
//  AccountCreation.swift
//  Chattrix
//
//  Created by Nishant on 14/06/25.
//

import SwiftUI

struct AccountCreation: View {
    
    //@Binding var show: Bool
    @AppStorage("status") var status: Bool = false
    @State var name: String = ""
    @State var about: String = ""
    @State var picker = false
    @State var loading = false
    @State var imageData: Data = .init(count: 0)
    @State var alert = false
    @State private var nameError = ""
    @State private var aboutError = ""
    @State private var imageError = ""

    
        var body: some View {
            
            VStack(alignment:.leading, spacing: 15){
                
                HStack{
                    Spacer()
                    Text("Create An Account")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Button {
                        self.picker.toggle()
                    } label: {
                        if self.imageData.count == 0{
                            Image(systemName: "person.crop.circle.badge.plus")
                                .resizable()
                                .frame(width: 90 , height: 70)
                                .foregroundStyle(.gray)
                        }
                        else{
                            Image(uiImage: UIImage(data: self.imageData)!)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(.vertical,15)
                
                
                TextField("Name", text: $name)
                    .keyboardType(.default)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                if !nameError.isEmpty {
                    Text(nameError)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                TextField("About", text: $about)
                    .keyboardType(.default)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                if !aboutError.isEmpty {
                    Text(aboutError)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if !imageError.isEmpty {
                    Text(imageError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                
                
                if self.loading{
                    HStack{
                        Spacer()
                        
                        Indicator()
                        
                        Spacer()
                    }
                }
                else {
                    Button {
                        if validateInputs() {
                            self.loading = true
                            let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedAbout = self.about.trimmingCharacters(in: .whitespacesAndNewlines)

                            createUser(name: trimmedName, about: trimmedAbout) { success in
                                DispatchQueue.main.async {
                                    self.loading = false
                                    if success {
                                        self.status = true
                                    } else {
                                        self.alert = true
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Create")
                            .bold()
                            .frame(width: UIScreen.main.bounds.width - 30 , height: 50)
                    }
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              about.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              imageData.count == 0)
                    .opacity((name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              about.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              imageData.count == 0) ? 0.6 : 1)
                }
            }
            .padding()
            .sheet(isPresented: $picker){
                ImagePicker(picker: $picker, imageData: self.$imageData)
            }
            .alert(isPresented : self.$alert){
                Alert(title: Text("Message") , message: Text("Please Fill All The Content"), dismissButton: .default(Text("Ok")))
            }
        }
    
    func validateInputs() -> Bool {
        var valid = true
        nameError = ""
        aboutError = ""
        imageError = ""

        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nameError = "Name cannot be empty"
            valid = false
        }

        if about.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            aboutError = "About section cannot be empty"
            valid = false
        }

        if imageData.count == 0 {
            imageError = "Profile picture is required"
            valid = false
        }

        return valid
    }
}
