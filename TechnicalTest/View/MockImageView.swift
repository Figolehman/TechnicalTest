//
//  MockDataView.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import SwiftUI
import PhotosUI

struct MockImageView: View {
    @StateObject var imageVM = ImageViewModel()
    
    @State var isTooLong = false
    
    @State var isPresentingPostSheet = false
    
    @State var itemForUpdate: ImageModel?
    @State var inputUpdateImage: UIImage?
    @State var inputUpdatePhoto: PhotosPickerItem?
    
    @State var inputCreatePhoto: PhotosPickerItem?
    @State var inputCreateImage: UIImage?
    
    var body: some View {
        if imageVM.displays.isEmpty && !isTooLong{
            ProgressView()
                .controlSize(.large)
                .onAppear {
                    imageVM.fetchImages()
                    imageVM.retrieveImage()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                        isTooLong = true
                    })
                }
        } else {
            List {
                ForEach(Array(imageVM.displays.keys), id: \.self) { key in
                    Image(uiImage: imageVM.displays[key]!)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            itemForUpdate = ImageModel(id: "not neccessary", image: "\(key)")
                        }
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        
                        imageVM.deleteImage(id: imageVM.images[index].id, image: imageVM.images[index].image)
                    }
                })
            }
            .navigationTitle("Images")
            .toolbar {
                ToolbarItem {
                    Button("+"){
                        isPresentingPostSheet = true
                    }
                }
            }
            .sheet(item: $itemForUpdate, content: { item in
                VStack {
                    Text("Change image to")

                    PhotosPicker(selection: $inputUpdatePhoto, matching: .images) {
                        if inputUpdateImage == nil {
                            Text("Change Image")
                        } else {
                            Image(uiImage: inputUpdateImage!)
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                    
                    Button("Update Image") {
                        if let image = self.inputUpdateImage{

                            imageVM.uploadImage(image, id: item.image)
                            
                        }
                        itemForUpdate = nil
                        inputUpdatePhoto = nil
                        inputUpdateImage = nil
                    }
                }
            })
            .onChange(of: inputUpdatePhoto, { _,_ in
                Task {
                    if let data = try? await inputUpdatePhoto?.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            self.inputUpdateImage = image
                        }
                    }
                }
            })
            .sheet(isPresented: $isPresentingPostSheet, content: {
                VStack{
                    Text("Image")
                    PhotosPicker(selection: $inputCreatePhoto, matching: .images) {
                        if let image = self.inputCreateImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                        } else {
                            Text("Insert Image")
                        }
                    }
                    .onChange(of: inputCreatePhoto) { _ in
                        Task {
                            if let data = try? await inputCreatePhoto?.loadTransferable(type: Data.self) {
                                if let image = UIImage(data: data) {
                                    self.inputCreateImage = image
                                }
                            }
                        }
                    }
                }
                Button("Create Image") {
                    let path = imageVM.uploadImage(inputCreateImage ?? UIImage())
                    
                    
                    if inputCreateImage != nil {
                        imageVM.createImage(image: ["image" : path])
                        isPresentingPostSheet = false
                    }
                    inputCreatePhoto = nil
                    inputCreateImage = nil
                }
            })
        }
    }
}

#Preview {
    MockImageView()
}
