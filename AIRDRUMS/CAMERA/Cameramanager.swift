import Combine
import AVFoundation
import CoreImage

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput pixelBuffer: CVPixelBuffer)
}

class CameraManager: NSObject, ObservableObject {
    @MainActor weak var delegate: CameraManagerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.airdrums.camera")
    private var isConfigured = false
    private var pendingStart = false
    
    @MainActor @Published var isRunning = false
    private let frameCounterQueue = DispatchQueue(label: "com.airdrums.camera.frameCounter")
    private var frameCounter: Int = 0
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .vga640x480
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: camera),
                  self.captureSession.canAddInput(input) else {
                return
            }
            
            self.captureSession.addInput(input)
            
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }
            
            self.captureSession.commitConfiguration()
            self.isConfigured = true

            if self.pendingStart {
                self.pendingStart = false
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                    Task { @MainActor in
                        self.isRunning = true
                    }
                }
            }
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard self.isConfigured else {
                self.pendingStart = true
                return
            }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                Task { @MainActor in
                    self.isRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                Task { @MainActor in
                    self.isRunning = false
                }
            }
        }
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
}

nonisolated extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        var shouldProcess = false
        frameCounterQueue.sync {
            frameCounter += 1
            shouldProcess = (frameCounter % 2 == 0)
        }
        guard shouldProcess else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Create a nonisolated(unsafe) shadow to avoid capturing a non-Sendable type in a @Sendable closure
        nonisolated(unsafe) let pixelBufferShadow = pixelBuffer

        // Hop to the main actor to access the main-actor isolated delegate
        Task { @MainActor in
            delegate?.cameraManager(self, didOutput: pixelBufferShadow)
        }
    }
}
