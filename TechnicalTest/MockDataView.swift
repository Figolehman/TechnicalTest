//
//  MockDataView.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import SwiftUI
import PhotosUI

struct MockDataView: View {
    @StateObject var postVM = PostViewModel()
    @State var isPresentingPostSheet = false
    
    @State var caption = ""
    
    @State var photos: PhotosPickerItem?
    @State var image: UIImage?
    
    var body: some View {
        List {
            ForEach(postVM.posts, id: \.self) { post in
                VStack{
                    Text(post.caption).font(.caption)
                }
            }
        }
        .navigationTitle("Posts")
        .onAppear {
            postVM.fetchPosts()
        }
        .toolbar {
            ToolbarItem {
                Button("+"){
                    isPresentingPostSheet = true
                }
            }
        }
        .sheet(isPresented: $isPresentingPostSheet, content: {
            VStack {
                VStack{
                    Text("Caption")
                    TextField("Insert Caption", text: $caption)
                        .padding([.leading, .trailing, .bottom])
                        .multilineTextAlignment(.center)
                }
                VStack{
                    Text("Image")
                    PhotosPicker(selection: $photos) {
                        if let image = self.image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                        } else {
                            Text("Insert Image")
                        }
                    }
                    .onChange(of: photos) { _ in
                        Task {
                            if let data = try? await photos?.loadTransferable(type: Data.self) {
                                if let image = UIImage(data: data) {
                                    self.image = image
                                }
                            }
                        }
                    }
                }
                Button("Create") {
                    if let image {
                        
                        postVM.createPost(post: ["caption" : "\(caption)", "image" : "" ])
                        postVM.fetchPosts()
                        isPresentingPostSheet = false
                    }
                }
            }
        })
    }
}

#Preview {
    MockDataView()
}
