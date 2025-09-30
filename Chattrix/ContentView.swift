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

struct ContentView: View {
    
    @AppStorage("status") var status: Bool = false
    
    var body: some View {
        VStack {
                if status {
                    NavigationView{
                        Home_page().environmentObject(MainObservable())
                    }
                } else {
                    NavigationView {
                        AccountCreation()
                    }
                }
        }
        .onAppear {
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { _ in
                status = UserDefaults.standard.bool(forKey: "status")
                self.status = status
            }

            if Auth.auth().currentUser == nil {
                Auth.auth().signInAnonymously { result, error in
                    if let error = error {
                        print("❌ Anonymous login failed: \(error.localizedDescription)")
                    } else {
                        print("✅ Logged in anonymously. UID: \(result?.user.uid ?? "nil")")
                    }
                }
            } else {
                print("✅ Already signed in. UID: \(Auth.auth().currentUser?.uid ?? "nil")")
            }
        }
    }
}

#Preview {
    //ContentView()
    Verification_page()
}

class MainObservable: ObservableObject {

    @Published var recents = [Recent]()
    @Published var norecents = false
    @Published var myUID: String?

    init() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("Anonymous sign-in failed: \(error.localizedDescription)")
                    return
                }

                guard let user = result?.user else {
                    print("No user returned after anonymous sign-in.")
                    return
                }

                UserDefaults.standard.set(user.uid, forKey: "UID")
                UserDefaults.standard.set(user.uid, forKey: "userID")

                self.myUID = user.uid
                print("Signed in anonymously with UID: \(user.uid)")
                self.loadRecents(for: user.uid)
            }
        } else if let uid = Auth.auth().currentUser?.uid {
            UserDefaults.standard.set(uid, forKey: "UID")
            UserDefaults.standard.set(uid, forKey: "userID")
            self.myUID = uid
            self.loadRecents(for: uid)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecents), name: .refreshRecents, object: nil)
    }

    private func loadRecents(for uid: String) {
        let db = Firestore.firestore()

        db.collection("Users").document(uid).collection("recents")
            .order(by: "date", descending: true)
            .addSnapshotListener { (snap, err) in

            if let err = err {
                print("Error loading recents: \(err.localizedDescription)")
                self.norecents = true
                return
            }

            guard let documents = snap?.documentChanges else {
                self.norecents = true
                return
            }

            self.norecents = documents.isEmpty

            for i in documents {
                if i.type == .added {
                    let id = i.document.documentID
                    let name = i.document.get("name") as? String ?? "Unknown"
                    let pic = i.document.get("pic") as? String ?? ""
                    let lastmsg = i.document.get("lastmsg") as? String ?? ""
                    let stamp = i.document.get("date") as? Timestamp ?? Timestamp()

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy"
                    let date = dateFormatter.string(from: stamp.dateValue())

                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "hh:mm a"
                    let time = timeFormatter.string(from: stamp.dateValue())

                    self.recents.append(
                        Recent(id: id,
                               name: name,
                               pic: pic,
                               lastmsg: lastmsg,
                               time: time,
                               date: date,
                               stamp: stamp.dateValue())
                    )
                }

                if i.type == .modified {
                    let id = i.document.documentID
                    let lastmsg = i.document.get("lastmsg") as? String ?? ""
                    let stamp = i.document.get("date") as? Timestamp ?? Timestamp()

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy"
                    let date = dateFormatter.string(from: stamp.dateValue())

                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "hh:mm a"
                    let time = timeFormatter.string(from: stamp.dateValue())

                    for j in 0..<self.recents.count {
                        if self.recents[j].id == id {
                            self.recents[j].lastmsg = lastmsg
                            self.recents[j].time = time
                            self.recents[j].date = date
                            self.recents[j].stamp = stamp.dateValue()
                        }
                    }
                }
            }
        }
    }

    @objc func reloadRecents() {
        print("🔄 Refreshing recents...")
        if let uid = Auth.auth().currentUser?.uid {
            self.recents.removeAll()
            self.loadRecents(for: uid)
        }
    }
}

struct Recent: Identifiable {
    var id: String
    var name: String
    var pic: String
    var lastmsg: String
    var time: String
    var date: String
    var stamp: Date
}

extension Notification.Name {
    static let refreshRecents = Notification.Name("refreshRecents")
}
