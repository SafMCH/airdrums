import Vision
import CoreGraphics

protocol HandPoseProcessorDelegate: AnyObject {
    func handPoseProcessor(_ processor: HandPoseProcessor,
                          didDetectLeftHand indexTip: CGPoint, wrist: CGPoint)
    func handPoseProcessor(_ processor: HandPoseProcessor,
                          didDetectRightHand indexTip: CGPoint, wrist: CGPoint)
}

class HandPoseProcessor {
    weak var delegate: HandPoseProcessorDelegate?
    
    private let handPoseRequest: VNDetectHumanHandPoseRequest
    
    init() {
        handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2
    }
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
            
            guard let observations = handPoseRequest.results, !observations.isEmpty else { return }
            
            // Process each detected hand (up to 2)
            var leftHand: (indexTip: CGPoint, wrist: CGPoint)?
            var rightHand: (indexTip: CGPoint, wrist: CGPoint)?
            
            for observation in observations {
                // Get index finger tip and wrist
                guard let indexTip = try? observation.recognizedPoint(.indexTip),
                      let wrist = try? observation.recognizedPoint(.wrist),
                      indexTip.confidence > 0.3,
                      wrist.confidence > 0.3 else {
                    continue
                }
                
                // Vision coordinates are normalized [0,1] with origin at bottom-left
                let indexTipPoint = CGPoint(x: indexTip.location.x, y: indexTip.location.y)
                let wristPoint = CGPoint(x: wrist.location.x, y: wrist.location.y)
                
                // Determine which hand based on chirality or screen position
                let isLeftHand: Bool
                
                // Use chirality if available, otherwise use screen position
                let chirality = observation.chirality
                if chirality == .left {
                    isLeftHand = true
                } else if chirality == .right {
                    isLeftHand = false
                } else {
                    // Fallback: assume left side of screen = left hand
                    isLeftHand = indexTipPoint.x < 0.5
                }
                
                // Store hand data
                if isLeftHand {
                    leftHand = (indexTipPoint, wristPoint)
                } else {
                    rightHand = (indexTipPoint, wristPoint)
                }
            }
            
            // Notify delegate for each detected hand
            if let left = leftHand {
                delegate?.handPoseProcessor(self, didDetectLeftHand: left.indexTip, wrist: left.wrist)
            }
            
            if let right = rightHand {
                delegate?.handPoseProcessor(self, didDetectRightHand: right.indexTip, wrist: right.wrist)
            }
            
        } catch {
            // Silently fail on processing errors
        }
    }
}
