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
    
    @Published var displays: [String : UIImage] = [:]
    
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
    
    func createImage(image: [String: String]) {
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
    
    func uploadImage(_ image: UIImage, id: String = "") -> String {
        
        let storageRef = Storage.storage().reference()
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        var id2: String = ""
        
        if id.isEmpty {
            id2 = "images/" + UUID().uuidString + ".jpg"
        }
        
        let path = "\(id.isEmpty ? id2 : id)"
        
        guard let imageData else { return "" }
        
        let fileRef = storageRef.child(path)
        
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                if id.isEmpty {
                    let db = Firestore.firestore()
                    
                    let index = path.index(after: path.firstIndex(of: "/")!)
                    
                    let docName = path.suffix(from: index)
                    
                    
                    db.collection("images").document("\(docName)").setData(["url": "\(path)"]) { error in
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                        self.fetchImages()
                        self.retrieveImage()
                    }
                } else {
                    self.fetchImages()
                    self.retrieveImage()
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
                    
                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error1 in
                        if error1 == nil && data != nil {
                            
                            if let image = UIImage(data: data!){
                                DispatchQueue.main.async {
                                    self.displays[path] = image
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    func updateImage(image: [String: String], id: String) {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/images") else {
            print("invalid url")
            return
        }
        
        let dataPost = try! JSONSerialization.data(withJSONObject: image)
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
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
    
    func deleteImage(id: String, image: String) {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/images/" + id) else {
            print("invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
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
        
        let storageRef = Storage.storage().reference()
        
        let fileRef = storageRef.child(image)
        
        fileRef.delete { error in
            if error == nil {
                let db = Firestore.firestore()
                
                let index = image.index(after: image.firstIndex(of: "/")!)
                
                let docName = image.suffix(from: index)
                
                db.collection("images").document("\(docName)").delete { error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        self.retrieveImage()
                    }
                }
            }
        }
    }
}
