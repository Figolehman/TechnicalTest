//
//  QRScannerView.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import SwiftUI
import CodeScanner

struct QRScannerView: View {
    @State var isScanning: Bool = false
    @State var scannedCode: String = ""
    
    var scannerSheet: some View {
        CodeScannerView(codeTypes: [.qr]) { result in
            if case let .success(code) = result {
                self.scannedCode = code.string
                self.isScanning = false
                let url = URL(string: self.scannedCode)!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(scannedCode)
            
            Button("Scan QR Code") {
                self.isScanning = true
            }
            .sheet(isPresented: $isScanning) {
                self.scannerSheet
            }
        }
    }
}

#Preview {
    QRScannerView()
}
