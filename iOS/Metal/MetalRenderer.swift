//
//  MetalRenderer.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import Foundation
import MetalKit
import CoreImage

class MetalRenderer: NSObject {
    var texture: MTLTexture?
    var currentTexture: MTLTexture?
    var renderPipelineState: MTLRenderPipelineState?
    var context: CIContext?
    
    let device: MTLDevice?
    let commandQueue: MTLCommandQueue!
    
    var commandBuffer: MTLCommandBuffer?
    var commandEncoder: MTLRenderCommandEncoder?
    
    private var cameraFilter: CameraFilter!
    private var pointDrawingFilter: PointDrawingFilter!
    private var lineDrawingFilter: LineDrawingFilter!
    
    static var points: [SIMD3<Float>] = []
    
    init(device: MTLDevice) {
        self.device = device
        self.context = CIContext(mtlDevice: device)
        commandQueue = device.makeCommandQueue()
        super.init()
        
        cameraFilter = CameraFilter(device: device)
        pointDrawingFilter = PointDrawingFilter(device: device)
        lineDrawingFilter = LineDrawingFilter(device: device)
    }
    
    private func runCameraFilter() {
        guard let cameraFilterRenderPipelineState = cameraFilter.renderPipelineState else {
            print("failed to get grayFilter.renderPipelineState")
            return
        }
  
        commandEncoder?.setRenderPipelineState(cameraFilterRenderPipelineState)
        
        commandEncoder?.setFragmentSamplerState(cameraFilter.samplerState, index: 0)
        commandEncoder?.setVertexBuffer(cameraFilter.vertexBuffer,
                                        offset: 0,
                                        index: 0)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawPrimitives(type: .triangleStrip,
                                       vertexStart: 0,
                                       vertexCount: 4,
                                       instanceCount: 1)
    }
    
    private func runPointDrawingFilter() {
        pointDrawingFilter.initRenderPipelineState()
        
        guard let pointDrawingFilterPipelineState = pointDrawingFilter.renderPipelineState else {
            print("failed to get pointDrawingFilter.renderPipelineState")
            return
        }
        
        guard let indexBuffer = pointDrawingFilter.indexBuffer else {
            print("failed to get pointDrawingFilter.indexBuffer")
            return
        }
  
        commandEncoder?.setRenderPipelineState(pointDrawingFilterPipelineState)
        
        commandEncoder?.setFragmentSamplerState(pointDrawingFilter.samplerState, index: 0)
        commandEncoder?.setVertexBuffer(pointDrawingFilter.vertexBuffer,
                                        offset: 0,
                                        index: 0)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle,
                                              indexCount: indexBuffer.length / MemoryLayout<UInt16>.size,
                                              indexType: .uint16,
                                              indexBuffer: indexBuffer,
                                              indexBufferOffset: 0)
    }
    
    private func runLineDrawingFilter() {
        lineDrawingFilter.initRenderPipelineState()
        
        guard let lineDrawingFilterPipelineState = lineDrawingFilter.renderPipelineState else {
            print("failed to get lineDrawingFilter.renderPipelineState")
            return
        }
  
        commandEncoder?.setRenderPipelineState(lineDrawingFilterPipelineState)
        
        commandEncoder?.setFragmentSamplerState(lineDrawingFilter.samplerState, index: 0)
        commandEncoder?.setVertexBuffer(lineDrawingFilter.vertexBuffer,
                                        offset: 0,
                                        index: 0)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        
        commandEncoder?.drawPrimitives(type: .lineStrip,
                                       vertexStart: 0,
                                       vertexCount: LineDrawingFilter.pointsCount,
                                       instanceCount: 1)
    }
    
    private func runLineDrawingFilterForBox() {
        var boxPoints: [SIMD3<Float>] = []
        
        for i in 0..<MetalRenderer.points.count {
            boxPoints.append(MetalRenderer.points[i])
            
            if i % 10 == 9 {
                LineDrawingFilter.points = boxPoints
                
                lineDrawingFilter.initRenderPipelineState()
                
                guard let lineDrawingFilterPipelineState = lineDrawingFilter.renderPipelineState else {
                    print("failed to get lineDrawingFilter.renderPipelineState")
                    return
                }
          
                commandEncoder?.setRenderPipelineState(lineDrawingFilterPipelineState)
                
                commandEncoder?.setFragmentSamplerState(lineDrawingFilter.samplerState, index: 0)
                commandEncoder?.setVertexBuffer(lineDrawingFilter.vertexBuffer,
                                                offset: 0,
                                                index: 0)
                commandEncoder?.setFragmentTexture(texture, index: 0)
                
                commandEncoder?.drawPrimitives(type: .lineStrip,
                                               vertexStart: 0,
                                               vertexCount: LineDrawingFilter.pointsCount,
                                               instanceCount: 1)
                
                boxPoints = []
            }
        }
    }
}

extension MetalRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("drawable size changed : \(size)")
    }
    
    func draw(in view: MTKView) {
        guard var _ = texture,
              var _ = device
        else {
            // print("failed to get texture, device")
            return
        }
        
        guard let currentRenderPassDescriptor = view.currentRenderPassDescriptor,
              let currentDrawable = view.currentDrawable
        else {
            print("failed to make currentRenderPassDescriptor, currentDrawble")
            return
        }
        
        commandBuffer = commandQueue.makeCommandBuffer()
    
        commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        
        commandEncoder?.pushDebugGroup("RenderFrame")
        
        runCameraFilter()
        
        switch ViewController.vision {
        case .faceDetection:
            if !MetalRenderer.points.isEmpty {
                PointDrawingFilter.points = MetalRenderer.points
                runPointDrawingFilter()
            }
        case .poseDetection:
            if !MetalRenderer.points.isEmpty {
                LineDrawingFilter.points = MetalRenderer.points
                runLineDrawingFilter()
            }
        case .barcodeScanning:
            break
        case .textRecognition:
            if !MetalRenderer.points.isEmpty {
                runLineDrawingFilterForBox()
            }
        case .selfieSegmentation:
            break
        default:
            break
        }
        
        commandEncoder?.endEncoding()
        
        commandEncoder?.popDebugGroup()
        
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
        
    }
    
    
}
