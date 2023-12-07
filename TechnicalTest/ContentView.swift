//
//  ContentView.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("CRUD API") {
                    
                }
                NavigationLink("QR SCANNER") {
                    QRScannerView()
                }
                NavigationLink("JAILBREAK DETECTOR") {
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
