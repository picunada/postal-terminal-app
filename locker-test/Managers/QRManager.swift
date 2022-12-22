//
//  QRManager.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/22/22.
//

import Foundation
import SwiftUI

struct QRCodeDataSet {
    let logo: UIImage?
    let url: String
    let backgroundColor: CIColor
    let color: CIColor
    let size: CGSize
    
    init(logo: UIImage? = nil, url: String) {
        self.logo = logo
        self.url = url
        self.backgroundColor = CIColor(red: 1,green: 1,blue: 1)
        self.color = CIColor(color: .black)
        self.size = CGSize(width: 300, height: 300)
    }

    init(logo: UIImage? = nil, url: String, backgroundColor: CIColor, color: CIColor, size: CGSize) {
        self.logo = logo
        self.url = url
        self.backgroundColor = backgroundColor
        self.color = color
        self.size = size
    }
    
    func getQRImage() -> UIImage? {
            
        guard var image  = createCIImage() else { return nil}
        
        
        ///scale to width:height
        let scaleW = self.size.width/image.extent.size.width
        let scaleH = self.size.height/image.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleW, y: scaleH)
        image = image.transformed(by: transform)
        
        /// add logo
        if let logo = logo, let newImage =  addLogo(image: image, logo: logo) {
           image = newImage
        }
        
        
        /// update color
        if let colorImgae = updateColor(image: image) {
            image = colorImgae
        }
        
        return UIImage(ciImage: image)
        
    }
        
    private func updateColor(image: CIImage) -> CIImage? {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        colorFilter.setValue(image, forKey: kCIInputImageKey)
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        return colorFilter.outputImage
    }
    
    private func addLogo(image: CIImage, logo: UIImage) -> CIImage? {
        
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        guard let logo = logo.cgImage else {
            return image
        }
        
        let ciLogo = CIImage(cgImage: logo)

        
        let centerTransform = CGAffineTransform(translationX: image.extent.midX - (ciLogo.extent.size.width / 2), y: image.extent.midY - (ciLogo.extent.size.height / 2))
        
        combinedFilter.setValue(ciLogo.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(image, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage
    }
    
    private func createCIImage() -> CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(url.data(using: String.Encoding.ascii), forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        //https://www.qrcode.com/en/about/error_correction.html
        return filter.outputImage
    }
}
