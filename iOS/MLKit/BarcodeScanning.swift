//
//  BarcodeScanning.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/14.
//

import Foundation
import MLKit
import CoreImage

class BarcodeScanning {
    private let utils = Utils()
    
    lazy var barcodeScanner = BarcodeScanner.barcodeScanner()
    
    func getBarcode(image: CIImage) -> String? {
        var transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi/2))
        transform = transform.scaledBy(x: -1, y: -1)
        let inputImage = image.transformed(by: utils.correctTransform(transform, size: image.extent.size))

        guard let pixelBuffer = utils.ciimageToCVPixelBuffer(inputImage) else {
            print("failed to convert to pixelbuffer")
            return nil
        }
        
        guard let sampleBuffer = utils.cvpixelBufferToCMSampleBuffer(pixelBuffer) else {
            print("failed to convert to samplebuffer")
            return nil
        }

        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = .leftMirrored
        
        guard let barcodes = try? barcodeScanner.results(in: visionImage) else {
            return nil
        }
        
        for barcode in barcodes {
            let valueType = barcode.valueType
            
            if valueType == .URL {
                // let title = barcode.url!.title
                let url = barcode.url!.url
                return url
            }
        }
        
        return nil
    }
    
}
