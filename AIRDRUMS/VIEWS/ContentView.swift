import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var audioManager = AudioEngineManager()
    @StateObject private var gestureMapper = GestureMapper()
    
    private let handPoseProcessor = HandPoseProcessor()

    // Hold strong references because the upstream delegate properties are `weak`
    @State private var cameraDelegate: CameraDelegate?
    @State private var handPoseDelegate: HandPoseDelegate?
    @State private var gestureDelegate: GestureDelegate?
    
    init() {
        // Setup delegates after state objects are initialized
    }
    
    var body: some View {
        ZStack {
            CameraView(captureSession: cameraManager.getCaptureSession())
                .edgesIgnoringSafeArea(Edge.Set.all)
            
            OverlayView(
                lastHitType: gestureMapper.lastHitType,
                hitTimestamp: gestureMapper.hitTimestamp
            )
            .edgesIgnoringSafeArea(Edge.Set.all)
        }
        .onAppear {
            setupDelegates()
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
    
    private func setupDelegates() {
        if cameraDelegate == nil {
            cameraDelegate = CameraDelegate(handPoseProcessor: handPoseProcessor)
            handPoseDelegate = HandPoseDelegate(gestureMapper: gestureMapper)
            gestureDelegate = GestureDelegate(audioManager: audioManager)
        }
        cameraManager.delegate = cameraDelegate
        handPoseProcessor.delegate = handPoseDelegate
        gestureMapper.delegate = gestureDelegate
    }
}

// Delegate adapters to bridge between managers

class CameraDelegate: CameraManagerDelegate {
    let handPoseProcessor: HandPoseProcessor
    
    init(handPoseProcessor: HandPoseProcessor) {
        self.handPoseProcessor = handPoseProcessor
    }
    
    func cameraManager(_ manager: CameraManager, didOutput pixelBuffer: CVPixelBuffer) {
        handPoseProcessor.processFrame(pixelBuffer)
    }
}

class HandPoseDelegate: HandPoseProcessorDelegate {
    let gestureMapper: GestureMapper
    
    init(gestureMapper: GestureMapper) {
        self.gestureMapper = gestureMapper
    }
    
    // Updated for two-hand support
    func handPoseProcessor(_ processor: HandPoseProcessor,
                          didDetectLeftHand indexTip: CGPoint, wrist: CGPoint) {
        let timestamp = Date().timeIntervalSince1970
        gestureMapper.processLeftHandPosition(indexTip: indexTip, timestamp: timestamp)
    }
    
    func handPoseProcessor(_ processor: HandPoseProcessor,
                          didDetectRightHand indexTip: CGPoint, wrist: CGPoint) {
        let timestamp = Date().timeIntervalSince1970
        gestureMapper.processRightHandPosition(indexTip: indexTip, timestamp: timestamp)
    }
}

class GestureDelegate: GestureMapperDelegate {
    let audioManager: AudioEngineManager
    
    init(audioManager: AudioEngineManager) {
        self.audioManager = audioManager
    }
    
    func gestureMapper(_ mapper: GestureMapper, didTriggerDrum drumType: DrumType) {
        audioManager.playSound(drumType)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
