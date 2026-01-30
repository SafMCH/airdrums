# AirDrums

## Description
AirDrums transforms any device with a camera into an interactive virtual drum kit using **hand gesture recognition**. 
Users can play drums in the air with natural hand movements, making music creation **accessible, portable, and engaging** without physical instruments.

> The project originated from the creator’s personal experience of playing drums in the air while listening to music.
The motivation is to bridge the gap between natural hand movements and virtual musical instruments,
leveraging computer vision for real-time gesture detection.

---

## Features
- Detects hand movements in real-time using the device camera  
- Maps hand positions to virtual drum zones  
- Triggers authentic drum sounds based on velocity and position  
- VisionOS-inspired 3D gesture-to-drum mapping  

---

## Core Concept
AirDrums is a **gesture-based musical instrument app** that uses computer vision to detect hand movements and trigger drum sounds.  
- Creates an invisible 3D space where hand positions map to different drums  
- Movement velocity determines hit intensity  

---

## Platform Strategy

### Current Phase (MVP)
- **macOS**: primary development and testing platform  
- Camera-based hand tracking via **Vision framework**  
- Desktop-optimized UI  

### Future Phases
- **iOS/iPadOS**: mobile version with front-facing camera  
- **visionOS**: native spatial computing experience  
- **watchOS**: rhythm companion/metronome  

---
## Installation
Clone the repository:  
Open AIRDRUMS.xcodeproj in Xcode
Build and run on macOS (or supported device)
Grant camera permissions for hand tracking

## Usage:
---

Move your hands in front of the camera to trigger drum sounds
Explore different gestures to play different drum types

PS:
AirDrums is still a work in progress. Future improvements will focus on:
Enhancing the UI and UX for a smoother, more immersive experience
Adding more drums, sounds, and animations
Optimizing gesture detection for fluid, responsive interaction
