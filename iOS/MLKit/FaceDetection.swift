//
//  FaceDetection.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import Foundation
import MLKit
import CoreImage

class FaceDetection {
    private let utils = Utils()
    
    lazy var faceDetector: FaceDetector = {
        let options = FaceDetectorOptions()
        options.contourMode = .all
        
        let faceDetector = FaceDetector.faceDetector(options: options)
        return faceDetector
    }()
    
    func getFace(image: CIImage) -> [FaceStruct] {
        
        var transform = CGAffineTransform(rotationAngle: (CGFloat)(Double.pi/2))
        transform = transform.scaledBy(x: -1, y: -1)
        let inputImage = image.transformed(by: utils.correctTransform(transform, size: image.extent.size))

        guard let pixelBuffer = utils.ciimageToCVPixelBuffer(inputImage) else {
            print("failed to convert to pixelbuffer")
            return []
        }
        
        guard let sampleBuffer = utils.cvpixelBufferToCMSampleBuffer(pixelBuffer) else {
            print("failed to convert to samplebuffer")
            return []
        }

        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = .leftMirrored
        
        
        let faces = try? faceDetector.results(in: visionImage).map { face in
            return FaceStruct(visionFace: face, size: CGSize(width: inputImage.extent.width, height: inputImage.extent.height))
        }
        
        return faces ?? []

    }
}
