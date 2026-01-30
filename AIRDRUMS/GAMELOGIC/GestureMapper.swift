import Foundation
import CoreGraphics
import Combine

protocol GestureMapperDelegate: AnyObject {
    func gestureMapper(_ mapper: GestureMapper, didTriggerDrum drumType: DrumType)
}

class GestureMapper: ObservableObject {
    weak var delegate: GestureMapperDelegate?
    
    @Published var lastHitType: DrumType?
    @Published var hitTimestamp: TimeInterval = 0
    
    // Separate tracking for left and right hands
    private var leftHandPreviousPoint: CGPoint?
    private var leftHandPreviousTimestamp: TimeInterval?
    
    private var rightHandPreviousPoint: CGPoint?
    private var rightHandPreviousTimestamp: TimeInterval?
    
    private var lastHitTimes: [DrumType: TimeInterval] = [:]
    
    private let velocityThreshold: CGFloat = 0.7
    private let cooldownDuration: TimeInterval = 0.1 // Faster for double hits
    
    // Process left hand
    func processLeftHandPosition(indexTip: CGPoint, timestamp: TimeInterval) {
        processHandPosition(
            indexTip: indexTip,
            timestamp: timestamp,
            previousPoint: &leftHandPreviousPoint,
            previousTimestamp: &leftHandPreviousTimestamp,
            isLeftHand: true
        )
    }
    
    // Process right hand
    func processRightHandPosition(indexTip: CGPoint, timestamp: TimeInterval) {
        processHandPosition(
            indexTip: indexTip,
            timestamp: timestamp,
            previousPoint: &rightHandPreviousPoint,
            previousTimestamp: &rightHandPreviousTimestamp,
            isLeftHand: false
        )
    }
    
    private func processHandPosition(
        indexTip: CGPoint,
        timestamp: TimeInterval,
        previousPoint: inout CGPoint?,
        previousTimestamp: inout TimeInterval?,
        isLeftHand: Bool
    ) {
        // Calculate velocity if we have a previous point
        guard let prevPoint = previousPoint,
              let prevTime = previousTimestamp else {
            previousPoint = indexTip
            previousTimestamp = timestamp
            return
        }
        
        let timeDelta = timestamp - prevTime
        guard timeDelta > 0 else { return }
        
        let dx = indexTip.x - prevPoint.x
        let dy = indexTip.y - prevPoint.y
        let distance = sqrt(dx * dx + dy * dy)
        let velocity = distance / CGFloat(timeDelta)
        
        previousPoint = indexTip
        previousTimestamp = timestamp
        
        // Check if velocity exceeds threshold
        guard velocity > velocityThreshold else { return }
        
        // Determine which zone the hand is in
        let drumType = determineDrumZone(point: indexTip, isLeftHand: isLeftHand)
        
        // Check cooldown per drum
        if let lastHit = lastHitTimes[drumType],
           timestamp - lastHit < cooldownDuration {
            return
        }
        
        // Trigger drum hit
        lastHitTimes[drumType] = timestamp
        
        DispatchQueue.main.async {
            self.lastHitType = drumType
            self.hitTimestamp = timestamp
        }
        
        delegate?.gestureMapper(self, didTriggerDrum: drumType)
    }
    
    private func determineDrumZone(point: CGPoint, isLeftHand: Bool) -> DrumType {
        // Vision coordinates: y=0 is bottom, y=1 is top
        // x=0 is left, x=1 is right
        
        // Match the drum positions from OverlayView
        let x = point.x
        let y = point.y
        
        // Define drum zones with clear boundaries
        // Crash: far left, upper area (x: 0-0.25, y: 0.65+)
        if x < 0.25 && y > 0.65 {
            return .crash
        }
        
        // Hi-Hat: right upper area (x: 0.65+, y: 0.6+)
        if x > 0.65 && y > 0.6 {
            return .hihat
        }
        
        // Tom: center upper area (x: 0.35-0.65, y: 0.55+)
        if x >= 0.35 && x <= 0.65 && y > 0.55 {
            return .tom
        }
        
        // Snare: center-right middle (x: 0.5-0.75, y: 0.35-0.65)
        if x >= 0.5 && x <= 0.75 && y >= 0.35 && y <= 0.65 {
            return .snare
        }
        
        // Kick: lower center-left (x: 0.2-0.5, y: 0-0.5)
        if x >= 0.2 && x <= 0.5 && y < 0.5 {
            return .kick
        }
        
        // Default fallback based on position
        if y > 0.6 {
            return isLeftHand ? .crash : .hihat
        } else if y > 0.4 {
            return x < 0.5 ? .tom : .snare
        } else {
            return .kick
        }
    }
    
    func reset() {
        leftHandPreviousPoint = nil
        leftHandPreviousTimestamp = nil
        rightHandPreviousPoint = nil
        rightHandPreviousTimestamp = nil
        lastHitTimes.removeAll()
    }
}
