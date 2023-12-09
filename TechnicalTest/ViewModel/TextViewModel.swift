//
//  PostViewModel.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

class TextViewModel: ObservableObject {
    @Published var texts: [TextModel] = []
    

    func fetchTexts() {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/texts") else {
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
                let result = try JSONDecoder().decode([TextModel].self, from: data)
                DispatchQueue.main.async {
                    self.texts = result
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func createText(text: [String: Any]) {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/texts") else {
            print("invalid url")
            return
        }
        
        let dataPost = try! JSONSerialization.data(withJSONObject: text)
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
                let result = try JSONDecoder().decode(TextModel.self, from: data)
                
                DispatchQueue.main.async {
                    print(result)
                    self.fetchTexts()
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func updateText(text: [String: Any], id: String) {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/texts/" + id) else {
            print("invalid url")
            return
        }
        
        let dataPost = try! JSONSerialization.data(withJSONObject: text)
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
                let result = try JSONDecoder().decode(TextModel.self, from: data)
                
                DispatchQueue.main.async {
                    print(result)
                    self.fetchTexts()
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func deleteText(id: String) {
        guard let url = URL(string: "https://657394fdf941bda3f2aeff3f.mockapi.io/texts/" + id) else {
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
                let result = try JSONDecoder().decode(TextModel.self, from: data)
                
                DispatchQueue.main.async {
                    print(result)
                    self.fetchTexts()
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
}
