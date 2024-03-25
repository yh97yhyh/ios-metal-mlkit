//
//  PoseDetection.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/14.
//

import Foundation
import MLKit
import CoreImage

class PoseDetection {
    private let utils = Utils()
    
    lazy var poseDetector: PoseDetector = {
        let options = AccuratePoseDetectorOptions()
        
        let poseDetector = PoseDetector.poseDetector(options: options)
        return poseDetector
    }()
    
    private let nums = [21, 15, 17, 19, 15, 13, 11, 12, 24, 23, 11, 12, 14, 16, 20, 18, 16, 22, 16, 14, 12, 24, 26, 28, 30, 32, 28, 26, 24, 23, 25, 27, 29, 31, 27]
    
    func getPose(image: CIImage) -> [SIMD3<Float>] {
        
        var posePoints: [CGFloat] = []
        var metalPosePoints: [SIMD3<Float>] = []
        
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
        
        guard let poses = try? poseDetector.results(in: visionImage) else {
            return []
        }
        
        if poses.isEmpty {
            return []
        }
        
        let pose = poses[0]
        
        for num in nums {
            switch num {
            case 11:
                let leftShoulder = pose.landmark(ofType: .leftShoulder)
                posePoints.append(leftShoulder.position.x)
                posePoints.append(leftShoulder.position.y)
            case 12:
                let rightShoulder = pose.landmark(ofType: .rightShoulder)
                posePoints.append(rightShoulder.position.x)
                posePoints.append(rightShoulder.position.y)
            case 13:
                let leftElbow = pose.landmark(ofType: .leftElbow)
                posePoints.append(leftElbow.position.x)
                posePoints.append(leftElbow.position.y)
            case 14:
                let rightElbow = pose.landmark(ofType: .rightElbow)
                posePoints.append(rightElbow.position.x)
                posePoints.append(rightElbow.position.y)
            case 15:
                let leftWrist = pose.landmark(ofType: .leftWrist)
                posePoints.append(leftWrist.position.x)
                posePoints.append(leftWrist.position.y)
            case 16:
                let rightWrist = pose.landmark(ofType: .rightWrist)
                posePoints.append(rightWrist.position.x)
                posePoints.append(rightWrist.position.y)
            case 17:
                let leftPinky = pose.landmark(ofType: .leftPinkyFinger)
                posePoints.append(leftPinky.position.x)
                posePoints.append(leftPinky.position.y)
            case 18:
                let rightPinky = pose.landmark(ofType: .rightPinkyFinger)
                posePoints.append(rightPinky.position.x)
                posePoints.append(rightPinky.position.y)
            case 19:
                let leftIndex = pose.landmark(ofType: .leftIndexFinger)
                posePoints.append(leftIndex.position.x)
                posePoints.append(leftIndex.position.y)
            case 20:
                let rightIndex = pose.landmark(ofType: .rightIndexFinger)
                posePoints.append(rightIndex.position.x)
                posePoints.append(rightIndex.position.y)
            case 21:
                let leftThumb = pose.landmark(ofType: .leftThumb)
                posePoints.append(leftThumb.position.x)
                posePoints.append(leftThumb.position.y)
            case 22:
                let rightThumb = pose.landmark(ofType: .rightThumb)
                posePoints.append(rightThumb.position.x)
                posePoints.append(rightThumb.position.y)
            case 23:
                let leftHip = pose.landmark(ofType: .leftHip)
                posePoints.append(leftHip.position.x)
                posePoints.append(leftHip.position.y)
            case 24:
                let rightHip = pose.landmark(ofType: .rightHip)
                posePoints.append(rightHip.position.x)
                posePoints.append(rightHip.position.y)
            case 25:
                let leftKnee = pose.landmark(ofType: .leftKnee)
                posePoints.append(leftKnee.position.x)
                posePoints.append(leftKnee.position.y)
            case 26:
                let rightKnee = pose.landmark(ofType: .rightKnee)
                posePoints.append(rightKnee.position.x)
                posePoints.append(rightKnee.position.y)
            case 27:
                let leftAnkle = pose.landmark(ofType: .leftAnkle)
                posePoints.append(leftAnkle.position.x)
                posePoints.append(leftAnkle.position.y)
            case 28:
                let rightAnkle = pose.landmark(ofType: .rightAnkle)
                posePoints.append(rightAnkle.position.x)
                posePoints.append(rightAnkle.position.y)
            case 29:
                let leftHeel = pose.landmark(ofType: .leftHeel)
                posePoints.append(leftHeel.position.x)
                posePoints.append(leftHeel.position.y)
            case 30:
                let rightHeel = pose.landmark(ofType: .rightHeel)
                posePoints.append(rightHeel.position.x)
                posePoints.append(rightHeel.position.y)
            case 31:
                let leftToe = pose.landmark(ofType: .leftToe)
                posePoints.append(leftToe.position.x)
                posePoints.append(leftToe.position.y)
            case 32:
                let rightToe = pose.landmark(ofType: .rightToe)
                posePoints.append(rightToe.position.x)
                posePoints.append(rightToe.position.y)
            default:
                break
            }
        }
        
        for i in stride(from: 0, to: posePoints.count-2, by: 2) {
            let x = (posePoints[i+1] / (inputImage.extent.height)) * 2.0 - 1.0
            let y = -((posePoints[i] / (inputImage.extent.width)) * 2.0 - 1.0)
            
            metalPosePoints.append(SIMD3<Float>(Float(x), Float(y), 0))
        }
        
        return metalPosePoints
    }
}
