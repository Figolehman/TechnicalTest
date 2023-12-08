//
//  ImageViewModel.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 09/12/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

class ImageViewModel: ObservableObject {
    @Published var images: [ImageModel] = []
    
    @Published var displays: [UIImage] = []
    
    func fetchImages() {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/images") else {
            print("invalid url")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let data else { return }
            
            do {
                let result = try JSONDecoder().decode([ImageModel].self, from: data)
                DispatchQueue.main.async {
                    self.images = result
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func createImage(image: [String: Any]) {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/images") else {
            print("invalid url")
            return
        }
        
        let dataPost = try! JSONSerialization.data(withJSONObject: image)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = dataPost
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, res, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let data else { return }
            
            do {
                let result = try JSONDecoder().decode(ImageModel.self, from: data)
                
                DispatchQueue.main.async {
                    print(result)
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func uploadImage(_ image: UIImage) -> String {
        
        let storageRef = Storage.storage().reference()
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        let id = UUID()
        
        let path = "images/\(id.uuidString).jpg"
        
        guard let imageData else { return "" }
        
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                let db = Firestore.firestore()
                
                db.collection("images").document().setData(["url": "\(path)"]) { error in
                    if error == nil {
                        self.retrieveImage()
                    }
                }
            }
        }
        
        return path
    }
    
    func retrieveImage() {
        let db = Firestore.firestore()
        
        db.collection("images").getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                
                var paths: [String] = []
                
                for doc in snapshot!.documents {
                    paths.append(doc["url"] as! String)
                }
                
                self.displays.removeAll()
                for path in paths {
                    let storageRef = Storage.storage().reference()
                    
                    let fileRef = storageRef.child(path)
                    
                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if error == nil && data != nil {
                            
                            if let image = UIImage(data: data!){
                                DispatchQueue.main.async {
                                    self.displays.append(image)
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
    }
}
