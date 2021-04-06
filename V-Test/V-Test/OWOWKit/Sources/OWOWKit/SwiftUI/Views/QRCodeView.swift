//
//  QRCodeView.swift
//  Duco
//
//  Created by Robbert Brandsma on 21/11/2019.
//  Copyright © 2019 OWOW. All rights reserved.
//

import SwiftUI

/// A view that renders a QR code.
@available(iOS 13, *)
public struct QRCode: View {
    @ObservedObject private var viewModel: QRCodeViewModel
    
    public init(_ text: String) {
        self.viewModel = .init(text: text)
    }
    
    public var body: some View {
        Group {
            if viewModel.error {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                viewModel.image?
                    .resizable(resizingMode: .stretch)
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

@available(iOS 13, *)
struct QRCode_Previews: PreviewProvider {
    static var previews: some View {
        QRCode("https://www.owow.io")
            .previewLayout(.sizeThatFits)
    }
}

@available(iOS 13, *)
fileprivate class QRCodeViewModel: ObservableObject {
    
    let ciContext = CIContext()

    @Published var image: Image?
    @Published var error = false
    
    init(text: String) {
        makeQRCode(text: text)
    }
    
    func makeQRCode(text: String) {
        error = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            let data = Data(text.utf8)
            
            guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
                DispatchQueue.main.async {
                    self.error = true
                }
                return
            }
            
            filter.setValue(data, forKey: "inputMessage")
            guard let ciImage = filter.outputImage else {
                DispatchQueue.main.async {
                    self.error = true
                }
                return
            }
            
            guard let cgImage = self.ciContext.createCGImage(ciImage, from: ciImage.extent) else {
                DispatchQueue.main.async {
                    self.error = true
                }
                return
            }
            
            DispatchQueue.main.async {
                self.image = Image(uiImage: UIImage(cgImage: cgImage))
            }
        }
    }
    
}
