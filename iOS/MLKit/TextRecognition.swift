//
//  TextRecognition.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/14.
//

import Foundation
import MLKit
import CoreImage

class TextRecognition {
    private let utils = Utils()
    
    lazy var koreanTextRecognizer: TextRecognizer = {
        let options = KoreanTextRecognizerOptions()

        let koreanTextRecognizer = TextRecognizer.textRecognizer(options: options)
        return koreanTextRecognizer
    }()
    
    func getKoreanText(image: CIImage) -> TextStruct? {
        
        var boxTexts: [String] = []
        var boxPoints: [CGFloat] = []
        var metalBoxPoints: [SIMD3<Float>] = []
        
        var transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi/2))
        transform = transform.scaledBy(x: 1, y: -1)
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
        
        guard let resultText = try? koreanTextRecognizer.results(in: visionImage) else {
            return nil
        }
        
        for block in resultText.blocks {
            for line in block.lines {
                let lineText = line.text
                let lineFrame = line.frame
                
                boxPoints.append(lineFrame.minX)
                boxPoints.append(lineFrame.minY)
                boxPoints.append(lineFrame.maxX)
                boxPoints.append(lineFrame.minY)
                boxPoints.append(lineFrame.maxX)
                boxPoints.append(lineFrame.maxY)
                boxPoints.append(lineFrame.minX)
                boxPoints.append(lineFrame.maxY)
                boxPoints.append(lineFrame.minX)
                boxPoints.append(lineFrame.minY)
                
                boxTexts.append(lineText)
            }
        }
        
        for i in stride(from: 0, to: boxPoints.count-2, by: 2) {
            let x = -((boxPoints[i+1] / (inputImage.extent.height)) * 2.0 - 1.0)
            let y = -((boxPoints[i] / (inputImage.extent.width)) * 2.0 - 1.0)
            
            metalBoxPoints.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        
        let textStruct = TextStruct(points: metalBoxPoints, boxTexts: boxTexts)
        
        return textStruct
    }
}
