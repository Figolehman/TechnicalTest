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
                NavigationLink("CRUD API") {
                    MockDataView()
                }
                NavigationLink("QR SCANNER") {
                    QRScannerView()
                }
                Button("ANTI-JAILBREAK"){
                    if IOSSecuritySuite.amIJailbroken() {
                        isJailbroken = true

                    } else {
                        isJailbroken = false
                        print("masuk")
                    }
                }
            }
        }
        .alert(isPresented: $isJailbroken, content: {
            Alert(title: Text("Your device is jailbroken"))
        })
    }
}

#Preview {
    ContentView()
}
