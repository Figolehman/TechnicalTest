//
//  MockDataView.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import SwiftUI
import PhotosUI

struct MockTextView: View {
    @StateObject var textVM = TextViewModel()
    
    @State var isTooLong = false
    
    @State var isPresentingCreateSheet = false
    
    @State var itemForUpdate: TextModel?
    @State var inputUpdateText = ""
    
    @State var inputCreateText = ""
    
    var body: some View {
        if textVM.texts.isEmpty && !isTooLong{
            ProgressView()
                .controlSize(.large)
                .onAppear {
                    textVM.fetchTexts()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        isTooLong = true
                    })
                }
        } else {
            
            List {
                ForEach(textVM.texts, id: \.self) { text in
                    Text("\(text.text)")
                        .onTapGesture {
                            itemForUpdate = text
                        }
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        textVM.deleteText(id: textVM.texts[index].id)
                    }
                })
            }
            .navigationBarTitle("Texts")
            .toolbar {
                ToolbarItem {
                    Button("+"){
                        isPresentingCreateSheet = true
                    }
                }
            }
            .sheet(item: $itemForUpdate, content: { item in
                VStack {
                    Text("Change \"\(item.text)\" to")
                    TextField("Insert New Text", text: $inputUpdateText)
                        .multilineTextAlignment(.center)
                    Button("Update Text") {
                        textVM.updateText(text: [ "text":inputUpdateText], id: item.id)
                        itemForUpdate = nil
                        inputUpdateText = ""
                    }
                }
            })
            .sheet(isPresented: $isPresentingCreateSheet, content: {
                VStack {
                    VStack{
                        Text("Text")
                        TextField("Insert Text", text: $inputCreateText)
                            .padding([.leading, .trailing])
                            .multilineTextAlignment(.center)
                    }
                    Button("Create Text") {
                        textVM.createText(text: ["text": inputCreateText])
                        isPresentingCreateSheet = false
                        textVM.fetchTexts()
                        inputCreateText = ""
                    }
                    .padding(.bottom)
                }
            })
        }
    }
}

#Preview {
    MockTextView()
}
