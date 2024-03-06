//
//  CameraViewController.swift
//  CamraFrameWork
//
//  Created by norelhoda on 05/03/2024.
//

import UIKit
import AVFoundation


class CameraViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate, MyDataSendingDelegateProtocol{
    
    //MARK: - Proporties
    let captureSession = AVCaptureSession()
    var previewLayer : CALayer!
    var captureDevice: AVCaptureDevice!
    var takePhoto = false
    var takenImageData : UIImage?
    var  vc : CameraFrameWork?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }
    
    //MARK: - Helper Function
    func prepareCamera() {
        //prepare camera session etc: maxsize, resolution & capture the avaliable devices
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        if availableDevices.count != 0 {
            captureDevice = availableDevices.first
            beginSession()
        }
    }
    
    func beginSession() {
        //checking if have access to open camera untill then it returns black stream
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device:captureDevice)
            captureSession.addInput(captureDeviceInput)
        }catch{
            print(error.localizedDescription)
        }
        
        //take previewlayer and add it to the view
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        if previewLayer != nil{
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
            
            //now telling our reciever that we want to get data from camera
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
            
            //now we are setting video for the output
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String):NSNumber(value: kCVPixelFormatType_32BGRA)]
            //just in case some types video frames is late we will discard them
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label:"takenPhoto")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    @IBAction func takePhoto(sender:Any) {
        takePhoto = true
        let frameworkBundle = Bundle(identifier: "Valify.CamraFrameWork")
        let storyboard = UIStoryboard(name: "Camera", bundle: frameworkBundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    //this function will run while camera is open it will get stream of camera data but we will listen only when user press  button
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            // as we will take only one photo
            takePhoto = false
            if let image = getImageFromSampleBuffer(buffer:sampleBuffer) {
                let frameworkBundle = Bundle(identifier: "Valify.CamraFrameWork")
                let storyboard = UIStoryboard(name: "Camera", bundle: frameworkBundle)
                let vc = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
                vc.takenPhoto = image
                vc.delegate = self
                self.stopCaptureSession()
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: {
                    })
                }
            }
        }
    }
    
    func sendDataToFirstViewController(myData: UIImage) {
        self.takenImageData = myData
        self.saveImage(image:myData)
        self.dismiss(animated: true)
    }
    
    func saveImage(image :UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: "KEY")
    }
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            //context for render image
            let context = CIContext()
            // dimenssions for image
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs{
                self.captureSession.removeInput(input)
            }
        }
    }
}

