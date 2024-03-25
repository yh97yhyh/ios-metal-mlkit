//
//  Vision.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import Foundation

enum Vision: String, CaseIterable {
    case faceDetection = "Face Detection"
    case poseDetection = "Pose Detection"
    case barcodeScanning = "Barcode Scanning"
    case textRecognition = "Text Recognition"
    case selfieSegmentation = "Selfie Segmentation"
}
