//
//  LineDrawingShader.metal
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/14.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float2 textureCoordinates [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float2 textureCoordinates;
};

vertex VertexOut lineDrawingVertexShader(const VertexIn vertexIn [[ stage_in ]]) {
    
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;
    
    return vertexOut;
}

fragment half4 lineDrawingFragmentShader(VertexOut vertexIn [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]]) {
    return half4(0.0, 1.0, 0.0, 1.0);
}
