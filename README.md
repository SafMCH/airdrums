# AirDrums 🥁

**Gesture-based virtual drums using webcam hand tracking**

AirDrums is a macOS SwiftUI application that turns hand movements captured by the webcam into real-time drum sounds. It uses computer vision to track hand positions and map gestures to virtual drum elements inside an invisible interaction space.

This project explores **gesture-based interaction**, **real-time audio feedback**, and **spatial computing-inspired interfaces**.

---

## Concept & Motivation

The idea came from a personal habit:
I originally wanted to play the drums, but every time I listened to music with drums, I instinctively started playing the rhythm in the air. AirDrums turns that unconscious gesture into an actual interactive instrument.

---

## Features

* Webcam-based hand tracking
* Gesture-to-sound mapping
* Velocity-based hit intensity
* Real-time audio playback
* SwiftUI-based interface
---

## Tech Stack

* **Language:** Swift
* **UI Framework:** SwiftUI
* **Computer Vision:** Apple Vision framework
* **Audio:** AVFoundation
* **Platform:** macOS

---

##Project Structure

AIRDRUMS
├── AUDIO
│   └── AudioEngineManager
│       Manages audio engine, drum samples, and sound playback
│
├── CAMERA
│   └── CameraManager
│       Handles webcam capture and frame delivery
│
├── GAMELOGIC
│   └── GestureMapper
│       Maps hand positions and movement data to drum zones
│
├── MODELS
│   ├── AIRDRUMSApp
│   └── DrumstickView
│       App entry point and core data models
│
├── VIEWS
│   ├── CameraView
│   ├── ContentView
│   └── OverlayView
│       SwiftUI interface and visual overlays
│
├── VISION
│   └── HandPoseProcessor
│       Processes hand pose detection using Vision
│
└── Assets


---

## How It Works (High Level)

1. The webcam captures live video frames
2. Vision detects hand pose landmarks
3. Hand position and velocity are extracted
4. Gestures are mapped to virtual drum zones
5. Audio engine triggers corresponding drum sounds in real time

---

## Current Status

* Core interaction pipeline implemented
* Basic drum mapping functional
* Project is **experimental and evolving**

This is an **early-stage personal project**, focused on learning and prototyping rather than production polish.

---

## Future Improvements

* Smoother gesture recognition and latency reduction
* Additional drum kits and sound variations
* Visual feedback for hit zones
* Improved UX/UI and interaction fluidity
* Potential expansion to iOS and visionOS

---

## Notes

This project is part of my learning journey in Swift, SwiftUI, and interaction design.
