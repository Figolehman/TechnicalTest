//
//  ContentView.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import SwiftUI
import IOSSecuritySuite

struct ContentView: View {
    @State var isJailbroken: Bool = false
    var body: some View {
        NavigationView {
            List {
                NavigationLink("CRUD TEXT API") {
                    MockTextView()
                }
                NavigationLink("CRUD IMAGE API") {
                    MockImageView()
                }
                NavigationLink("QR SCANNER") {
                    QRScannerView()
                }
            }
            .onAppear(perform: {
                detectJailBreak()
            })
        }
        .alert(isPresented: $isJailbroken, content: {
            Alert(title: Text("Your device is jailbroken"))
        })
    }
    
    func detectJailBreak() {
        if IOSSecuritySuite.amIJailbroken() {
            isJailbroken = true

        } else {
            isJailbroken = false
            print("masuk")
        }
    }
}

#Preview {
    ContentView()
}
