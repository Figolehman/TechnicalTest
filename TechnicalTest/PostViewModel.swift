//
//  PostViewModel.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    
    //MARK: - retrieve data
    func fetchPosts() {
        guard let url = URL(string: "https://6572d11d192318b7db411001.mockapi.io/posts") else {
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
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let result = try decoder.decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self.posts = result
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
    
    func createPost(post: [String: Any]) {
        guard let url = URL(string: "https://6572d11d192318b7db411001.mockapi.io/posts") else {
            print("invalid url")
            return
        }
        
        let dataPost = try! JSONSerialization.data(withJSONObject: post)
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
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                
                let result = try decoder.decode(Post.self, from: data)
                
                
                DispatchQueue.main.async {
                    print(result)
                }
            } catch let jsonError {
                print(jsonError.localizedDescription)
            }
        }.resume()
    }
}
