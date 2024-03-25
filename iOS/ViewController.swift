//
//  ViewController.swift
//  iOS
//
//  Created by MZ01-KYONGH on 2022/02/09.
//

import UIKit
import MetalKit
import CoreImage
import Photos
import SafariServices

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate  {

    private let utils = Utils()

    @IBOutlet weak var cameraView: MTKView!
    
    var device: MTLDevice!
    var renderer: MetalRenderer?
    
    var position: AVCaptureDevice.Position = .back
    
    lazy var camera = {
       return createCamera()
    }()
    
    private let faceDetection = FaceDetection()
    // static var faces: [FaceStruct] = []
    
    private let poseDetection = PoseDetection()
    
    private let barcodeScanning = BarcodeScanning()
    private var barcodeURL: String?
    @IBOutlet weak var urlLabel: UILabel!
    
    private let textReocgnition = TextRecognition()
    private var texts: [String] = []
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    static var vision: Vision!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initCamera()
        initTapURLLabel()
        
        ViewController.vision = .faceDetection
        
        assert(device != nil, "Failed creating a default system Metal device. Please, make sure Metal is available on your hardware.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        camera = createCamera()
        initCamera()
        camera.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        camera.stop()
        camera.removeInputOutput()
    }
    
    func createCamera() -> MetalCamera {
        return MetalCamera(position: position) { [weak self] (image) in
            guard let `self` = self else {return}
            
            let pixelBuffer = self.utils.ciimageToCVPixelBuffer(image)
            
            guard let pixelBuffer = pixelBuffer else {
                print("failed to create CVPixelBuffer from CIImage")
                return
            }
            guard let texture = self.utils.createTexture(imageBuffer: pixelBuffer,
                                                         textureCache: self.camera.textureCache!) else {
                return
            }
            
            switch ViewController.vision {
            case .faceDetection:
                let faces = self.faceDetection.getFace(image: image)
                if faces.isEmpty {
                    MetalRenderer.points = [SIMD3<Float>(1.5, 1.5, 0)]
                } else {
                    for face in faces {
                        MetalRenderer.points = face.points
                    }
                }            
            case .poseDetection:
                let posePoints = self.poseDetection.getPose(image: image)
                if posePoints.isEmpty {
                    MetalRenderer.points = [SIMD3<Float>(1.5, 1.5, 0)]
                } else {
                    MetalRenderer.points = posePoints
                }
                break
            case .barcodeScanning:
                self.barcodeURL = self.barcodeScanning.getBarcode(image: image)
                DispatchQueue.main.async {
                    if let barcodeURL = self.barcodeURL {
                        self.setURLLabel()
                    } else {
                        self.urlLabel.isHidden = true
                    }
                }
            case .textRecognition:
                let result = self.textReocgnition.getKoreanText(image: image)
                DispatchQueue.main.async {
                    if let result = result {
                        MetalRenderer.points = result.points
                        self.texts = result.boxTexts
                        self.setTextLabel()
                    } else {
                        self.textLabel.isHidden = true
                    }
                }

            case .selfieSegmentation:
                break
            default:
                break                
            }
            
            self.renderer?.texture = texture
            
            DispatchQueue.main.async {
                self.cameraView.setNeedsDisplay()
            }
        }
    }
    
    private func setURLLabel() {
        self.urlLabel.text = self.barcodeURL
        self.urlLabel.isHidden = false
    }
    
    private func setTextLabel() {
        let text = texts.joined(separator: "\n")
        self.textLabel.numberOfLines = 0
        self.textLabel.text = text
        self.textLabel.isHidden = false
    }
    
    func initView() {
        cameraView.device = MTLCreateSystemDefaultDevice()
        device = cameraView.device

        renderer = MetalRenderer(device: device)
        cameraView.framebufferOnly = false
        cameraView.autoResizeDrawable = false
        cameraView.drawableSize = CGSize(width: 1080, height: 1920)
        cameraView.delegate = renderer
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func initCamera() {
        camera.addRenderOutput()
        camera.addInputOutput()
        camera.setVideoPreset()
    }
    
    func initTapURLLabel() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tapURLLabel(_ :)))
        urlLabel.addGestureRecognizer(tapGesture)
        urlLabel.isUserInteractionEnabled = true
    }
    
    @objc private func tapURLLabel(_ sender: UILabel) {
        guard let barcodeURL = barcodeURL else {
            return
        }

        let url = NSURL(string: barcodeURL)
        let safariView: SFSafariViewController = SFSafariViewController(url: url! as URL)
        self.present(safariView, animated: true, completion: nil)
    }

    @IBAction func switchPosition(_ sender: UIButton) {
        camera.stop()
        camera.removeInputOutput()
        
        position = (position == .back) ? .front : .back
        
        camera = createCamera()
        initCamera()
        camera.start()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Vision.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Vision.allCases[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ViewController.vision = Vision.allCases[row]
    }

}

