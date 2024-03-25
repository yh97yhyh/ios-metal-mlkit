//
//  MetalCamera.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import Foundation
import AVFoundation
import MetalKit

class MetalCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Camera
    
    let deviceQueue = DispatchQueue(label: "deviceQueue")
    let renderQueue = DispatchQueue(label: "renderQueue")
    
    let renderSemaphore = DispatchSemaphore(value: 1)
    
    typealias imageClosure = (_ image: CIImage) -> ()
    var imageClosure: imageClosure?
    
    let cameraSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    var cameraDeviceInput: AVCaptureDeviceInput?
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    private var _position: AVCaptureDevice.Position = .back
    var position: AVCaptureDevice.Position {
        get {
            return _position
        }
        set {
            let device = findBestDevice(newValue)
            
            cameraDevice = device
            _position = newValue
            
            if let cameraDevice = cameraDevice {
                cameraDeviceInput = try? AVCaptureDeviceInput(device: cameraDevice)
            }
        }
    }
    
    init(position: AVCaptureDevice.Position = .back, rendering imageClosure: imageClosure? = nil) {
        super.init()
        
        self.position = position
        self.imageClosure = imageClosure
        initTextureCache()
    }
    
    func findBestDevice(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: position).devices.first
    }
    
    func setVideoPreset() {
        cameraSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
    }
    
    func executeCameraSessionConfig(doConfig: @escaping ()->()) {
        deviceQueue.async { [weak self] in
            guard let `self` = self else {return}
            
            self.cameraSession.beginConfiguration()
            doConfig()
            self.cameraSession.commitConfiguration()
        }
    }
    
    func addInputOutput() {
        executeCameraSessionConfig { [weak self] in
            guard let `self` = self else {return}
            
            if let cameraDeviceInput = self.cameraDeviceInput {
                if self.cameraSession.canAddInput(cameraDeviceInput) {
                    self.cameraSession.addInput(cameraDeviceInput)
                }
            }
            
            if self.cameraSession.canAddOutput(self.videoDataOutput) {
                self.cameraSession.addOutput(self.videoDataOutput)
            }
        }
    }
    
    func removeInputOutput() {
        executeCameraSessionConfig { [weak self] in
            guard let `self` = self else {return}
            
            for input in self.cameraSession.inputs {
                self.cameraSession.removeInput(input)
            }
            
            for output in self.cameraSession.outputs {
                self.cameraSession.removeOutput(output)
            }
        }
    }
    
    func addRenderOutput() {
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA
        ]
        videoDataOutput.setSampleBufferDelegate(self, queue: renderQueue)
    }
    
    func start() {
        deviceQueue.async { [weak self] in
            guard let `self` = self else {return}
            guard !self.cameraSession.isRunning else {return}
            self.cameraSession.startRunning()
        }
    }
    
    func stop() {
        deviceQueue.async { [weak self] in
            guard let `self` = self else {return}
            guard self.cameraSession.isRunning else {return}
            self.cameraSession.stopRunning()
        }
    }
    
    // MARK: - Metal
    
    private let utils = Utils()
    
    var metalDevice = MTLCreateSystemDefaultDevice()
    var textureCache: CVMetalTextureCache?
    
    func initTextureCache() {
        guard let metalDevice = metalDevice,
              CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &textureCache) == kCVReturnSuccess
        else {
            print("failed to create TextureCache")
            return
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard renderSemaphore.wait(timeout: DispatchTime.now()) == .success else {return}
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("failed to create ImageBuffer from CMSampleBuffer")
            return
        }

        var image = CIImage(cvPixelBuffer: imageBuffer)
        var transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi/2))
        
        if position == .front {
            transform = transform.scaledBy(x: -1, y: -1)
        } else {
            transform = transform.scaledBy(x: -1, y: 1)
        }

        image = image.transformed(by: utils.correctTransform(transform, size: image.extent.size))
    
        self.imageClosure?(image)
        
        self.renderSemaphore.signal()
    }
    
    
}
