//
//  ImagePicker.swift
//  Chattrix
//
//  Created by Nishant on 14/06/25.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var picker : Bool
    @Binding var imageData : Data
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        ImagePicker.Coordinator(parent1: self)
    }
    
    func makeUIViewController(context: Context) -> some UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent : ImagePicker
        
        init(parent1 : ImagePicker) {
            parent = parent1
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.picker.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as! UIImage
            
            let data = image.jpegData(compressionQuality: 0.45)
            
            self.parent.imageData = data!
            
            self.parent.picker.toggle()
        }
    }
}

