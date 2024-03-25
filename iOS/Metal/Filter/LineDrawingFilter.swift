//
//  LineDrawingFilter.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/14.
//

import Foundation
import MetalKit

class LineDrawingFilter: NSObject {
    let device: MTLDevice?
    var renderPipelineState: MTLRenderPipelineState?
    var samplerState: MTLSamplerState?
    
    var vertexBuffer: MTLBuffer?
    static var points: [SIMD3<Float>] = []
    static var pointsCount = 0
    var verticesTemplate: [Vertex] = [
        Vertex(position: SIMD3<Float>(-1, -1, 0),
               texture: SIMD2<Float>(0, 0)),

        Vertex(position: SIMD3<Float>(1, -1, 0),
               texture: SIMD2<Float>(1, 0)),

        Vertex(position: SIMD3<Float>(-1, 1, 0),
               texture: SIMD2<Float>(0, 1)),

        Vertex(position: SIMD3<Float>(1, 1, 0),
               texture: SIMD2<Float>(1, 1))
    ]
    
    init(device: MTLDevice) {
        self.device = device
        super.init()
        
        // initRenderPipelineState()
    }
    
    func initRenderPipelineState() {
        guard let device = device,
              let library = device.makeDefaultLibrary()
        else {
            print("failed to init library")
            return
        }
        
        var vertices: [Vertex] = []
        
        LineDrawingFilter.pointsCount = LineDrawingFilter.points.count
        
        for i in 0 ..< LineDrawingFilter.pointsCount {
            let t = verticesTemplate[i % 4].texture
            vertices.append(Vertex(position: LineDrawingFilter.points[i], texture: t))
        }
    
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Vertex>.stride,
                                         options: [])
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "lineDrawingVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "lineDrawingFragmentShader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error : \(error.localizedDescription)")
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
    }
}
