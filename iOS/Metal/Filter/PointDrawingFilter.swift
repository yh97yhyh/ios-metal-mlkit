//
//  PointDrawingFilter.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import Foundation
import MetalKit

class PointDrawingFilter: NSObject {
    let device: MTLDevice?
    var renderPipelineState: MTLRenderPipelineState?
    var samplerState: MTLSamplerState?
    
    var indexBuffer: MTLBuffer?
    let indicesTemplate: [UInt16] = [0, 1, 3, 3, 0, 2]
    
    var vertexBuffer: MTLBuffer?
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
    
    static var points: [SIMD3<Float>] = []
    let pointSize = 5.0
    
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
            return }
        
        var indices : [UInt16] = []
        var vertices : [Vertex] = []

        let pointsCount = PointDrawingFilter.points.count
        let pointSize = CGSize(width: self.pointSize / 1080, height: self.pointSize / 1920)

        for i in 0 ..< pointsCount {
            indices.append(contentsOf: indicesTemplate.map { s in
                return UInt16((4 * i)) + s
            })

            for j in 0 ..< 4 {
                let x = PointDrawingFilter.points[i][0] + verticesTemplate[j].position[0] * Float(pointSize.width)
                let y = PointDrawingFilter.points[i][1] + verticesTemplate[j].position[1] * Float(pointSize.height)
                let p = SIMD3<Float>(x, y, 0)
                let t = verticesTemplate[j].texture
                vertices.append(Vertex(position: p, texture: t))
            }
        }
        
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size,
                                        options: [])

        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Vertex>.stride,
                                         options: [])
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "pointDrawingVertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "pointDrawingFragmentShader")
        
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
