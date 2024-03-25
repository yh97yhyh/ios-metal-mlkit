//
//  Utils.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import Foundation
import CoreImage
import CoreMedia
import MetalKit

class Utils {
    func ciimageToCVPixelBuffer(_ image: CIImage) -> CVPixelBuffer? {
        
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                       kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue] as CFDictionary
        let width = Int(image.extent.size.width)
        let height = Int(image.extent.size.height)
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
        
        let context = CIContext()
        context.render(image, to: pixelBuffer!)
        
        return pixelBuffer
    }
    
    func cvpixelBufferToCMSampleBuffer(_ pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer? = nil
        var timimgInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid
        var videoInfo: CMVideoFormatDescription? = nil
 
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil,
                                                     imageBuffer: pixelBuffer,
                                                     formatDescriptionOut: &videoInfo)
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: pixelBuffer,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: videoInfo!,
                                           sampleTiming: &timimgInfo,
                                           sampleBufferOut: &sampleBuffer)
        
        return sampleBuffer
    }
    
    func createTexture(imageBuffer: CVImageBuffer, textureCache: CVMetalTextureCache) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        var imageTexture: CVMetalTexture?
        
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, .bgra8Unorm, width, height, 0, &imageTexture)

        guard let unwrappedImageTexture = imageTexture,
              let texture = CVMetalTextureGetTexture(unwrappedImageTexture),
              result == kCVReturnSuccess
        else {
            print("faield to create MTLTeuxtre from CVImageBuffer")
            return nil
        }
    
        return texture
    }
    
    func correctTransform(_ transform: CGAffineTransform, size: CGSize) -> CGAffineTransform {
        if (transform.b < 0 || transform.c < 0) {
            let transX = (transform.b<0 ? -size.width : 0)
            let transY = (transform.c<0 ? -size.height : 0)
            
            return transform.translatedBy(x: transX, y: transY)
        }
        
        return transform
    }
    
    func resize(imageBuffer: CVImageBuffer, destSize: CGSize)-> CVPixelBuffer? {
            // Lock the image buffer
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            // Get information about the image
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
            let bytesPerRow = CGFloat(CVPixelBufferGetBytesPerRow(imageBuffer))
            let height = CGFloat(CVPixelBufferGetHeight(imageBuffer))
            let width = CGFloat(CVPixelBufferGetWidth(imageBuffer))
            var pixelBuffer: CVPixelBuffer?
            let options = [kCVPixelBufferCGImageCompatibilityKey:true,
                           kCVPixelBufferCGBitmapContextCompatibilityKey:true]
            let topMargin = (height - destSize.height) / CGFloat(2)
            let leftMargin = (width - destSize.width) * CGFloat(2)
            let baseAddressStart = Int(bytesPerRow * topMargin + leftMargin)
            let addressPoint = baseAddress!.assumingMemoryBound(to: UInt8.self)
            let status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, Int(destSize.width), Int(destSize.height), kCVPixelFormatType_32BGRA, &addressPoint[baseAddressStart], Int(bytesPerRow), nil, nil, options as CFDictionary, &pixelBuffer)
            if (status != 0) {
                print(status)
                return nil;
            }
            CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0))
            return pixelBuffer;
    }
    
}

