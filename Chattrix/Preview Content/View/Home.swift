//
//  Home.swift
//  Chattrix
//
//  Created by Nishant on 14/06/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

struct Home_page: View {

    @EnvironmentObject var datas: MainObservable
    @State private var myuid: String? = nil
    @State var show = false
    @State var chat = false
    @State var uid = ""
    @State var name = ""
    @State var pic = ""

    init() {
        let savedUID = UserDefaults.standard.string(forKey: "UserName")
        _myuid = State(initialValue: savedUID)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.96, blue: 0.93).ignoresSafeArea() // background color same as chat view

                VStack {
                    if self.datas.recents.isEmpty {
                        if self.datas.norecents {
                            Text("No Chat History")
                                .foregroundStyle(Color.black.opacity(0.5))
                        } else {
                            Indicator()
                        }
                    } else {
                        RecentListView(datas: datas, name: $name, pic: $pic, uid: $uid, show: $show, chat: $chat)
                    }
                }
            }
            .navigationDestination(isPresented: $chat) {
                ChatView(name: name, pic: pic, uid: uid, chat: $chat)
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color(red: 0.98, green: 0.96, blue: 0.93), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        UserDefaults.standard.set("", forKey: "UserName")
                        UserDefaults.standard.set("", forKey: "UID")
                        UserDefaults.standard.set("", forKey: "pic")

                        try? Auth.auth().signOut()
                        UserDefaults.standard.set(false, forKey: "status")

                        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                    }) {
                        Text("Sign Out")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.show.toggle()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(red: 0.93, green: 0.65, blue: 0.47)) // dark peach
                    }
                }
            }
            .sheet(isPresented: $show) {
                newChatView(name: $name, uid: $uid, pic: $pic, show: $show, chat: $chat)
            }
        }
    }
}

struct RecentListView: View {
    var datas: MainObservable
    @Binding var name: String
    @Binding var pic: String
    @Binding var uid: String
    @Binding var show: Bool
    @Binding var chat: Bool

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(datas.recents.sorted(by: {$0.stamp > $1.stamp})) { i in
                    Button {
                        self.name = i.name
                        self.pic = i.pic
                        self.uid = i.id

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.chat = true
                        }
                        
                    } label: {
                        RecentCellView(url: i.pic, name: i.name, lastmsg: i.lastmsg, time: i.time , date: i.date)
                    }
                }
            }
            .padding()
        }
    }
}


struct RecentCellView : View {
    
    var url : String
    var name : String
    var lastmsg : String
    var time : String
    var date : String
    
    var body: some View {
        HStack{
            
            if let validURL = URL(string: url) {
                AnimatedImage(url: validURL)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .foregroundColor(.gray)
            }

            
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text(name).foregroundStyle(.black)
                        Text(lastmsg).foregroundStyle(.gray)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 6){
                        Text(date).foregroundStyle(.gray)
                        Text(time).foregroundStyle(.gray)
                    }
                }
                Divider()
            }
        }
    }
}



//New User Chat Formation


struct newChatView : View {
    
    @ObservedObject var datas = getAllUsers()
    @Binding var name : String
    @Binding var uid : String
    @Binding var pic : String
    @Binding var show : Bool
    @Binding var chat : Bool
    
    var body: some View {
        VStack(alignment : .leading){
            
            if self.datas.users.count == 0{
                Indicator()
            }
            else{
                Text("Chat With").font(.title).foregroundStyle(Color.black.opacity(0.5))
                
                ScrollView(.vertical, content: {
                    
                    VStack(spacing: 12){
                        ForEach(datas.users){ i in
                            
                            Button {
                                self.name = i.name
                                self.pic = i.pic
                                self.uid = i.id
                                self.show.toggle()
                                self.chat.toggle()
                                
                            } label: {
                                UserCellView(url: i.pic, name: i.name, about: i.about)
                            }
                        }
                    }
                })
            }
        }
        .padding()
    }
}

//Assigning Value of All Users to the Databases

class getAllUsers : ObservableObject{
    
    @Published var users = [User]()
    
    init(){
        
        let db = Firestore.firestore()

        db.collection("Users").getDocuments{ (snap, err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            guard let documents = snap?.documentChanges else { return }
                
            if let currentUserID = UserDefaults.standard.string(forKey: "UserName") {
                for i in documents {
                    let id = i.document.documentID
                    let name = i.document.get("name") as? String ?? "Unknown"
                    let pic = i.document.get("pic") as? String ?? ""
                    let about = i.document.get("about") as? String ?? ""
                        
                    if id != currentUserID {
                        self.users.append(User(id: id, name: name, pic: pic, about: about))
                    }
                }
            }
        }
    }
}

struct User : Identifiable{
    var id : String
    var name : String
    var pic : String
    var about : String
}

struct UserCellView : View {
    
    var url : String
    var name : String
    var about : String
   
    var body: some View {
        HStack{
            
            if let validURL = URL(string: url) {
                AnimatedImage(url: validURL)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .foregroundColor(.gray)
            }

            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text(name).foregroundStyle(.black)
                        Text(about).foregroundStyle(.gray)
                    }
                    Spacer()
                }
                Divider()
            }
        }
    }
}

struct ChatView: View {
    
    var name: String
    var pic: String
    var uid: String
    @Binding var chat: Bool
    
    @State private var msgs = [Msg]()
    @State private var txt = ""
    @State private var nomsg = false
    
    var body: some View {
        NavigationView {
            VStack {
                if msgs.isEmpty {
                    if self.nomsg {
                        Spacer()
                        Text("Start New Chat")
                            .foregroundStyle(Color.black.opacity(0.5))
                            .padding(.top)
                        Spacer()
                    } else {
                        Spacer()
                        Indicator()
                        Spacer()
                    }
                } else {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            VStack(spacing: 8) {
                                let currentUID = Auth.auth().currentUser?.uid ?? ""
                                
                                ForEach(self.msgs) { i in
                                    HStack {
                                        if i.user == currentUID {
                                            Spacer()
                                            Text(i.msg)
                                                .padding()
                                                .background(Color("me"))
                                                .clipShape(ChatBubble(mymsg: true))
                                                .foregroundStyle(.black)
                                        } else {
                                            Text(i.msg)
                                                .padding()
                                                .background(Color("them"))
                                                .clipShape(ChatBubble(mymsg: false))
                                                .foregroundStyle(.black)
                                            Spacer()
                                        }
                                    }
                                    .id(i.id)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .onChange(of: msgs.count) { _, _ in
                            if let last = msgs.last {
                                withAnimation {
                                    scrollProxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 12) {
                    TextField("Message", text: self.$txt)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.vertical, 10)

                    Button(action: {
                        guard !txt.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        sendMsg(user: name, uid: uid, pic: pic, date: Date(), msg: txt)
                        txt = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(red: 0.93, green: 0.65, blue: 0.47)) // dark peach
                    }
                    .background(Color(red: 0.2, green: 0.15, blue: 0.1))
                    .clipShape(Circle())
                    .disabled(txt.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(txt.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.98, green: 0.96, blue: 0.93))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)

                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            self.getMsgs()
        }
    }
    
    func getMsgs() {
        let db = Firestore.firestore()

        guard let myuid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        let chatID = [myuid, uid].sorted().joined(separator: "_")

        db.collection("msgs")
            .document(chatID)
            .collection("messages")
            .order(by: "date", descending: false)
            .addSnapshotListener { (snap, err) in

                if let err = err {
                    print("❌ Error getting messages: \(err.localizedDescription)")
                    self.nomsg = true
                    return
                }

                if let snap = snap {
                    self.nomsg = snap.isEmpty
                } else {
                    self.nomsg = true
                }

                guard let documentChanges = snap?.documentChanges else { return }

                for i in documentChanges where i.type == .added {
                    let id = i.document.documentID
                    let msg = i.document.get("msg") as? String ?? ""
                    let user = i.document.get("user") as? String ?? ""
                    self.msgs.append(Msg(id: id, msg: msg, user: user))
                    
                    print("Fetched \(self.msgs.count) messages")
                }
            }
    }
}

struct Msg : Identifiable{
    var id : String
    var msg : String
    var user : String
}

struct ChatBubble : Shape{
    
    var mymsg : Bool
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight,
            mymsg ? .bottomLeft:.bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        
        return Path(path.cgPath)
    }
}

func sendMsg(user: String, uid: String, pic: String, date: Date, msg: String) {
    let db = Firestore.firestore()

    guard let myuid = Auth.auth().currentUser?.uid else {
        print("Current user not logged in.")
        return
    }

    db.collection("Users").document(uid).collection("recents").document(myuid).getDocument { (snap, err) in
        
        if let error = err {
            print("Error: \(error.localizedDescription)")
            setRecents(user: user, uid: uid, pic: pic, msg: msg, date: date)
            return
        }

        guard let snap = snap else {
            print("Document snapshot is nil")
            return
        }

        if !snap.exists {
            setRecents(user: user, uid: uid, pic: pic, msg: msg, date: date)
        } else {
            updateRecents(uid: uid, lastmsg: msg, date: date)
        }
    }
    
    updateDB(uid: uid, msg: msg, date: date)
    
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: NSNotification.Name("RefreshRecents"), object: nil)
    }
}

func setRecents(user: String, uid: String, pic: String, msg: String, date: Date) {
    let db = Firestore.firestore()

    guard let myuid = Auth.auth().currentUser?.uid,
          let myname = UserDefaults.standard.string(forKey: "UserName"),
          let mypic = UserDefaults.standard.string(forKey: "pic") else {
        print("❌ Missing UID, name, or pic from UserDefaults")
        return
    }

    let timestamp = Timestamp(date: date)

    db.collection("Users").document(uid).collection("recents").document(myuid).setData([
        "name": myname,
        "pic": mypic,
        "lastmsg": msg,
        "date": timestamp
    ], merge: true) { err in
        if let err = err {
            print("❌ Error setting recipient recent: \(err.localizedDescription)")
        }
    }

    db.collection("Users").document(myuid).collection("recents").document(uid).setData([
        "name": user,
        "pic": pic,
        "lastmsg": msg,
        "date": timestamp
    ], merge: true) { err in
        if let err = err {
            print("❌ Error setting sender recent: \(err.localizedDescription)")
        }
    }
}

func updateRecents(uid: String, lastmsg: String, date: Date) {
    let db = Firestore.firestore()

    guard let myuid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        return
    }

    let timestamp = Timestamp(date: date)

    // ✅ Update recipient's recent — use setData with merge to always write
    db.collection("Users").document(uid).collection("recents").document(myuid).setData([
        "lastmsg": lastmsg,
        "date": timestamp
    ], merge: true)
    
    // ✅ Update sender's recent
    db.collection("Users").document(myuid).collection("recents").document(uid).setData([
        "lastmsg": lastmsg,
        "date": timestamp
    ], merge: true)
}

func updateDB(uid: String, msg: String, date: Date) {
    let db = Firestore.firestore()
    
    guard let myuid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        return
    }

    let chatID = [myuid, uid].sorted().joined(separator: "_")

    db.collection("msgs").document(chatID).collection("messages").addDocument(data: [
        "msg": msg,
        "user": myuid,
        "date": date
    ]) { err in
        if let err = err {
            print("Error writing message: \(err.localizedDescription)")
        } else {
            print("✅ Message sent successfully.")
        }
    }
}
