# 💬 Chattrix – A Real-Time SwiftUI Chat App  
Built with 💙 SwiftUI + Firebase • Designed for smooth messaging

Welcome to **Chattrix**, a sleek and modern iOS chat application made with SwiftUI and Firebase. From user onboarding to real-time messaging, Chattrix is built to demonstrate production-grade app architecture and clean, modular Swift code.

---

## ✨ Features

✅ Phone / Anonymous Sign-In via Firebase  
✅ Create Username, About Info, and Optional Profile Image  
✅ Realtime Messaging (via Firestore Subcollections)  
✅ Recent Chats Management  
✅ Profile Picture Handling (using `SDWebImageSwiftUI`)  
✅ Realtime UI Updates using `@Published` & `@State`  
✅ Smooth Navigation with SwiftUI `NavigationStack`  
✅ Modular Architecture (View / ViewModel / Model)

---

## 🛠️ Tech Stack

| Technology             | Purpose                                 |
|------------------------|-----------------------------------------|
| SwiftUI                | Frontend UI design                      |
| Firebase Auth          | User sign-in (anonymous)                |
| Firebase Firestore     | Realtime database for messages & users |
| Firebase Storage       | Store profile pictures                  |
| SDWebImageSwiftUI      | Asynchronous image loading              |
| Combine                | Data binding and reactivity             |

---

## 📂 Project Structure
```
Chattrix/
├── ChattrixApp.swift # App entry point
├── ContentView.swift # Initial routing view
├── GoogleService-Info.plist # Firebase config (ignored from Git)
├── Info.plist
│
├── Model/
│ ├── CreateUser.swift # Firestore user creation logic
│ └── CheckUser.swift # Firestore user check logic
│
├── View/
│ ├── AccountCreation.swift # New user profile setup
│ ├── Home.swift # Main chat UI
│ ├── Verify.swift # Auth verification screen
│ ├── OtpPage.swift # Optional OTP screen
│ ├── ImagePicker.swift # For uploading profile pictures
│ ├── Indicator.swift # Reusable loading indicator
│
├── Assets/ # App assets (images, colors)
└── .gitignore # Hides private files like plist
```


---

## 👨‍💻 About the Developer

**Nishant**  
📍 India | 🎓 CSE @ IIIT Bhopal  
🚀 Learning Swift, Flutter, Firebase, App Dev  
💡 Interested in CP, UI/UX, Software Dev, AIML

---

## 🤝 Contributing

Feel free to fork this repo and contribute!  
If you find a bug or have a feature request, open an issue or a pull request 🚀

---

## 🙏 Credits & Learning Sources

This project was built while learning SwiftUI and Firebase, inspired by various tutorials online.
While the UI and logic were customized, some parts were adapted and extended from these sources for educational purposes.

> Thanks for checking out **Chattrix** 💬✨
