//
//  MockDataView.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import SwiftUI
import PhotosUI

struct MockDataView: View {
    @StateObject var textVM = TextViewModel()
    @StateObject var imageVM = ImageViewModel()
    
    @State var isTooLong = false
    
    @State var isPresentingPostSheet = false
    
    @State var text = ""
    
    @State var photos: PhotosPickerItem?
    @State var image: UIImage?
    
    var body: some View {
        if textVM.texts.isEmpty && imageVM.displays.isEmpty && !isTooLong{
            ProgressView()
                .controlSize(.large)
                .onAppear {
                    textVM.fetchTexts()
                    imageVM.retrieveImage()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        isTooLong = true
                    })
                }
        } else {
            
            List {
                ForEach(textVM.texts, id: \.self) { text in
                    Text("\(text.text)")
                }
            }
            List {
                ForEach(imageVM.displays, id: \.self) { display in
                    Image(uiImage: display)
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            .navigationTitle("Posts")
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
                        Text("Text")
                        TextField("Insert Text", text: $text)
                            .padding([.leading, .trailing])
                            .multilineTextAlignment(.center)
                    }
                    Button("Create Text") {
                        textVM.createText(text: ["text": text])
                        isPresentingPostSheet = false
                        reloadData()
                    }
                    .padding(.bottom)
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
                    Button("Create Image") {
                        let path = imageVM.uploadImage(image ?? UIImage())
                        
                        
                        if image != nil {
                            imageVM.createImage(image: ["image" : path])
                            isPresentingPostSheet = false
                        }
                    }
                }
            })
        }
    }
    
    func reloadData(){
        textVM.fetchTexts()
        imageVM.retrieveImage()
    }
}

#Preview {
    MockDataView()
}
