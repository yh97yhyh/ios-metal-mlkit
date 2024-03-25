//
//  FaceStruct.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import Foundation
import MLKit

struct FaceStruct {
    let points: [SIMD3<Float>]
    
    init(visionFace: Face, size: CGSize) {
        var points: [SIMD3<Float>] = []
    
        visionFace.contour(ofType: .face)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .leftEyebrowTop)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .leftEyebrowBottom)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .rightEyebrowTop)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .rightEyebrowBottom)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .leftEye)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .rightEye)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .upperLipTop)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .upperLipBottom)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .lowerLipTop)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .lowerLipBottom)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .noseBridge)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .noseBottom)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .leftCheek)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        visionFace.contour(ofType: .rightCheek)?.points.forEach { point in
            let x = (point.y / (size.height)) * 2.0 - 1.0
            let y = -((point.x / (size.width)) * 2.0 - 1.0)
        
            points.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        self.points = points
    }
}

