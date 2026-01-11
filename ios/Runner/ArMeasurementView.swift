// import Flutter
// import UIKit
// import ARKit
// import SceneKit

// class ArMeasurementView: NSObject, FlutterPlatformView, ARSCNViewDelegate, ARSessionDelegate {
    
//     private var arView: ARSCNView
//     private let channel: FlutterMethodChannel
    
//     // Measurement state
//     private var points: [SCNVector3] = []
//     private var sphereNodes: [SCNNode] = []
//     private var lineNodes: [SCNNode] = []
//     private var planeDetected = false
    
//     // Current plane anchor
//     private var currentPlaneAnchor: ARPlaneAnchor?
    
//     // Feature point tracking for faster detection
//     private var featurePointCount = 0
//     private let minFeaturePointsForDetection = 50
    
//     // Constants
//     private let sphereRadius: CGFloat = 0.008
//     private let lineRadius: CGFloat = 0.002
    
//     static func isARKitSupported() -> Bool {
//         return ARWorldTrackingConfiguration.isSupported
//     }
    
//     init(
//         frame: CGRect,
//         viewIdentifier viewId: Int64,
//         arguments args: Any?,
//         channel: FlutterMethodChannel
//     ) {
//         self.channel = channel
//         self.arView = ARSCNView(frame: frame)
//         super.init()
        
//         arView.delegate = self
//         arView.session.delegate = self
//         arView.autoenablesDefaultLighting = true
//         arView.automaticallyUpdatesLighting = true
        
//         // Enable better rendering
//         arView.antialiasingMode = .multisampling4X
//         arView.preferredFramesPerSecond = 60
        
//         // Show feature points for debugging (helps user aim)
//         // arView.debugOptions = [.showFeaturePoints]
        
//         // Add coaching overlay for better UX (iOS 13+)
//         if #available(iOS 13.0, *) {
//             addCoachingOverlay()
//         }
//     }
    
//     @available(iOS 13.0, *)
//     private func addCoachingOverlay() {
//         let coachingOverlay = ARCoachingOverlayView()
//         coachingOverlay.session = arView.session
//         coachingOverlay.frame = arView.bounds
//         coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//         coachingOverlay.goal = .anyPlane  // Changed: detect any plane faster
//         coachingOverlay.activatesAutomatically = true
//         arView.addSubview(coachingOverlay)
//     }
    
//     func view() -> UIView {
//         return arView
//     }
    
//     func initialize() -> Bool {
//         guard ARWorldTrackingConfiguration.isSupported else {
//             channel.invokeMethod("onError", arguments: "ARKit not supported on this device")
//             return false
//         }
        
//         let configuration = ARWorldTrackingConfiguration()
        
//         // ═══════════════════════════════════════════════════════════════
//         // IMPROVED DETECTION SETTINGS
//         // ═══════════════════════════════════════════════════════════════
        
//         // Detect both horizontal and vertical planes
//         configuration.planeDetection = [.horizontal, .vertical]
        
//         // Better environment understanding
//         configuration.environmentTexturing = .automatic
        
//         // World alignment for stability
//         configuration.worldAlignment = .gravity
        
//         // Enable scene reconstruction for better detection (iOS 13.4+, LiDAR devices)
//         if #available(iOS 13.4, *) {
//             if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
//                 configuration.sceneReconstruction = .mesh
//             }
//         }
        
//         // Enable frame semantics for better understanding (LiDAR devices)
//         if #available(iOS 14.0, *) {
//             if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
//                 configuration.frameSemantics.insert(.sceneDepth)
//             }
//         }
        
//         // Run with options for better tracking
//         arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
//         return true
//     }
    
//     func dispose() {
//         arView.session.pause()
//     }
    
//     func addPoint() {
//         // Get center of screen
//         let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
//         var hitResult: ARHitTestResult?
        
//         // ═══════════════════════════════════════════════════════════════
//         // IMPROVED HIT TEST - Multiple methods for better detection
//         // ═══════════════════════════════════════════════════════════════
        
//         // Method 1: Try raycast (iOS 13+, most accurate)
//         if #available(iOS 13.0, *) {
//             if let query = arView.raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: .any) {
//                 let results = arView.session.raycast(query)
//                 if let result = results.first {
//                     let position = SCNVector3(
//                         result.worldTransform.columns.3.x,
//                         result.worldTransform.columns.3.y,
//                         result.worldTransform.columns.3.z
//                     )
//                     addPointAtPosition(position)
//                     return
//                 }
//             }
//         }
        
//         // Method 2: Try existing planes (most accurate for legacy)
//         let existingPlaneResults = arView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
//         if let result = existingPlaneResults.first {
//             hitResult = result
//         }
        
//         // Method 3: Try existing plane without extent
//         if hitResult == nil {
//             let existingPlaneResults2 = arView.hitTest(screenCenter, types: .existingPlane)
//             if let result = existingPlaneResults2.first {
//                 hitResult = result
//             }
//         }
        
//         // Method 4: Try estimated planes
//         if hitResult == nil {
//             let estimatedResults = arView.hitTest(screenCenter, types: [.estimatedHorizontalPlane, .estimatedVerticalPlane])
//             if let result = estimatedResults.first {
//                 hitResult = result
//             }
//         }
        
//         // Method 5: Try feature points (works even without plane detection!)
//         if hitResult == nil {
//             let featureResults = arView.hitTest(screenCenter, types: .featurePoint)
//             if let result = featureResults.first {
//                 hitResult = result
//             }
//         }
        
//         guard let hit = hitResult else {
//             channel.invokeMethod("onHitTestFailed", arguments: "Move slowly and aim at a surface")
//             return
//         }
        
//         let position = SCNVector3(
//             hit.worldTransform.columns.3.x,
//             hit.worldTransform.columns.3.y,
//             hit.worldTransform.columns.3.z
//         )
        
//         addPointAtPosition(position)
//     }
    
//     private func addPointAtPosition(_ position: SCNVector3) {
//         // Add sphere at point
//         addSphere(at: position)
//         points.append(position)
        
//         // Haptic feedback
//         let generator = UIImpactFeedbackGenerator(style: .medium)
//         generator.impactOccurred()
        
//         // Notify Flutter
//         channel.invokeMethod("onPointAdded", arguments: [
//             "x": Double(position.x),
//             "y": Double(position.y),
//             "z": Double(position.z)
//         ])
        
//         channel.invokeMethod("onPointCount", arguments: points.count)
        
//         // Draw line if we have 2+ points
//         if points.count >= 2 {
//             let startPoint = points[points.count - 2]
//             let endPoint = points[points.count - 1]
//             addLine(from: startPoint, to: endPoint)
            
//             let distance = calculateDistance(from: startPoint, to: endPoint)
//             channel.invokeMethod("onDistanceCalculated", arguments: distance)
//         }
//     }
    
//     func undo() {
//         guard !points.isEmpty else { return }
        
//         // Haptic feedback
//         let generator = UIImpactFeedbackGenerator(style: .light)
//         generator.impactOccurred()
        
//         // Remove last point
//         points.removeLast()
        
//         // Remove last sphere
//         if let lastSphere = sphereNodes.popLast() {
//             lastSphere.removeFromParentNode()
//         }
        
//         // Remove last line
//         if let lastLine = lineNodes.popLast() {
//             lastLine.removeFromParentNode()
//         }
        
//         channel.invokeMethod("onPointCount", arguments: points.count)
        
//         // Recalculate distance
//         if points.count >= 2 {
//             let startPoint = points[points.count - 2]
//             let endPoint = points[points.count - 1]
//             let distance = calculateDistance(from: startPoint, to: endPoint)
//             channel.invokeMethod("onDistanceCalculated", arguments: distance)
//         }
//     }
    
//     func clear() {
//         // Haptic feedback
//         let generator = UIImpactFeedbackGenerator(style: .medium)
//         generator.impactOccurred()
        
//         // Remove all spheres
//         for node in sphereNodes {
//             node.removeFromParentNode()
//         }
//         sphereNodes.removeAll()
        
//         // Remove all lines
//         for node in lineNodes {
//             node.removeFromParentNode()
//         }
//         lineNodes.removeAll()
        
//         // Clear points
//         points.removeAll()
        
//         channel.invokeMethod("onPointCount", arguments: 0)
//     }
    
//     func takeSnapshot() -> FlutterStandardTypedData? {
//         let image = arView.snapshot()
//         guard let data = image.pngData() else { return nil }
//         return FlutterStandardTypedData(bytes: data)
//     }
    
//     // MARK: - Private Methods
    
//     private func addSphere(at position: SCNVector3) {
//         let sphere = SCNSphere(radius: sphereRadius)
        
//         // Better material for visibility
//         let material = SCNMaterial()
//         material.diffuse.contents = UIColor.white
//         material.lightingModel = .constant
//         material.isDoubleSided = true
//         sphere.firstMaterial = material
        
//         let node = SCNNode(geometry: sphere)
//         node.position = position
        
//         arView.scene.rootNode.addChildNode(node)
//         sphereNodes.append(node)
//     }
    
//     private func addLine(from start: SCNVector3, to end: SCNVector3) {
//         let distance = calculateDistance(from: start, to: end)
        
//         // Create cylinder for line
//         let cylinder = SCNCylinder(radius: lineRadius, height: CGFloat(distance))
        
//         // Better material
//         let material = SCNMaterial()
//         material.diffuse.contents = UIColor.white
//         material.lightingModel = .constant
//         material.isDoubleSided = true
//         cylinder.firstMaterial = material
        
//         let node = SCNNode(geometry: cylinder)
        
//         // Position at midpoint
//         node.position = SCNVector3(
//             (start.x + end.x) / 2,
//             (start.y + end.y) / 2,
//             (start.z + end.z) / 2
//         )
        
//         // Rotate to align with line direction
//         let direction = SCNVector3(end.x - start.x, end.y - start.y, end.z - start.z)
//         let up = SCNVector3(0, 1, 0)
        
//         let cross = crossProduct(up, direction)
//         let dot = dotProduct(up, normalize(direction))
//         let angle = acos(min(max(dot, -1), 1)) // Clamp to avoid NaN
        
//         if cross.x != 0 || cross.y != 0 || cross.z != 0 {
//             node.rotation = SCNVector4(cross.x, cross.y, cross.z, angle)
//         }
        
//         arView.scene.rootNode.addChildNode(node)
//         lineNodes.append(node)
//     }
    
//     private func calculateDistance(from start: SCNVector3, to end: SCNVector3) -> Double {
//         let dx = end.x - start.x
//         let dy = end.y - start.y
//         let dz = end.z - start.z
//         return Double(sqrt(dx*dx + dy*dy + dz*dz))
//     }
    
//     private func normalize(_ vector: SCNVector3) -> SCNVector3 {
//         let length = sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
//         guard length > 0 else { return vector }
//         return SCNVector3(vector.x/length, vector.y/length, vector.z/length)
//     }
    
//     private func crossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
//         return SCNVector3(
//             a.y * b.z - a.z * b.y,
//             a.z * b.x - a.x * b.z,
//             a.x * b.y - a.y * b.x
//         )
//     }
    
//     private func dotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
//         return a.x * b.x + a.y * b.y + a.z * b.z
//     }
    
//     // MARK: - ARSCNViewDelegate
    
//     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//         guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
//         currentPlaneAnchor = planeAnchor
        
//         if !planeDetected {
//             planeDetected = true
//             DispatchQueue.main.async {
//                 // Haptic feedback when plane detected
//                 let generator = UINotificationFeedbackGenerator()
//                 generator.notificationOccurred(.success)
                
//                 self.channel.invokeMethod("onPlaneDetected", arguments: true)
//             }
//         }
//     }
    
//     func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//         // Plane updated - tracking is working
//         guard anchor is ARPlaneAnchor else { return }
        
//         if !planeDetected {
//             planeDetected = true
//             DispatchQueue.main.async {
//                 self.channel.invokeMethod("onPlaneDetected", arguments: true)
//             }
//         }
//     }
    
//     // MARK: - ARSessionDelegate
    
//     // Track feature points for faster "ready" state
//     func session(_ session: ARSession, didUpdate frame: ARFrame) {
//         // Count feature points - when enough, surface is trackable
//         if let points = frame.rawFeaturePoints?.points {
//             let count = points.count
            
//             // If we have enough feature points, consider surface detected
//             if count >= minFeaturePointsForDetection && !planeDetected {
//                 planeDetected = true
//                 DispatchQueue.main.async {
//                     let generator = UINotificationFeedbackGenerator()
//                     generator.notificationOccurred(.success)
                    
//                     self.channel.invokeMethod("onPlaneDetected", arguments: true)
//                 }
//             }
//         }
//     }
    
//     func session(_ session: ARSession, didFailWithError error: Error) {
//         DispatchQueue.main.async {
//             self.channel.invokeMethod("onError", arguments: error.localizedDescription)
//         }
//     }
    
//     func sessionWasInterrupted(_ session: ARSession) {
//         DispatchQueue.main.async {
//             self.channel.invokeMethod("onError", arguments: "AR session interrupted")
//         }
//     }
    
//     func sessionInterruptionEnded(_ session: ARSession) {
//         // Reset tracking when session resumes
//         if let configuration = session.configuration {
//             session.run(configuration, options: [.resetTracking])
//         }
//     }
// }

import Flutter
import UIKit
import ARKit
import SceneKit

class ArMeasurementView: NSObject, FlutterPlatformView, ARSCNViewDelegate, ARSessionDelegate {
    
    private var arView: ARSCNView
    private let channel: FlutterMethodChannel
    
    // Measurement state
    private var points: [SCNVector3] = []
    private var sphereNodes: [SCNNode] = []
    private var lineNodes: [SCNNode] = []
    private var planeDetected = false
    
    // Feature point tracking for faster detection
    private let minFeaturePointsForDetection = 30
    
    // Constants
    private let sphereRadius: CGFloat = 0.008
    private let lineRadius: CGFloat = 0.002
    
    static func isARKitSupported() -> Bool {
        return ARWorldTrackingConfiguration.isSupported
    }
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        channel: FlutterMethodChannel
    ) {
        self.channel = channel
        self.arView = ARSCNView(frame: frame)
        super.init()
        
        arView.delegate = self
        arView.session.delegate = self
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Better rendering quality
        // ═══════════════════════════════════════════════════════════════
        arView.antialiasingMode = .multisampling4X
        arView.preferredFramesPerSecond = 60
    }
    
    func view() -> UIView {
        return arView
    }
    
    func initialize() -> Bool {
        guard ARWorldTrackingConfiguration.isSupported else {
            channel.invokeMethod("onError", arguments: "ARKit not supported on this device")
            return false
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        configuration.worldAlignment = .gravity
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return true
    }
    
    func dispose() {
        arView.session.pause()
    }
    
    func addPoint() {
        // Get center of screen
        let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Multiple hit test methods for better detection
        // ═══════════════════════════════════════════════════════════════
        var hitResult: ARHitTestResult?
        
        // Method 1: Existing plane (most accurate)
        let existingPlaneResults = arView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        if let result = existingPlaneResults.first {
            hitResult = result
        }
        
        // Method 2: Estimated planes
        if hitResult == nil {
            let estimatedResults = arView.hitTest(screenCenter, types: [.estimatedHorizontalPlane, .estimatedVerticalPlane])
            if let result = estimatedResults.first {
                hitResult = result
            }
        }
        
        // Method 3: Feature points (works even without full plane detection!)
        if hitResult == nil {
            let featureResults = arView.hitTest(screenCenter, types: .featurePoint)
            if let result = featureResults.first {
                hitResult = result
            }
        }
        
        guard let hit = hitResult else {
            // ═══════════════════════════════════════════════════════════════
            // IMPROVED: Better error feedback with vibration
            // ═══════════════════════════════════════════════════════════════
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            channel.invokeMethod("onHitTestFailed", arguments: "Aim at a flat surface")
            return
        }
        
        let position = SCNVector3(
            hit.worldTransform.columns.3.x,
            hit.worldTransform.columns.3.y,
            hit.worldTransform.columns.3.z
        )
        
        // Add sphere at point
        addSphere(at: position)
        points.append(position)
        
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Haptic feedback when point added
        // ═══════════════════════════════════════════════════════════════
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Notify Flutter
        channel.invokeMethod("onPointAdded", arguments: [
            "x": Double(position.x),
            "y": Double(position.y),
            "z": Double(position.z)
        ])
        
        channel.invokeMethod("onPointCount", arguments: points.count)
        
        // Draw line if we have 2+ points
        if points.count >= 2 {
            let startPoint = points[points.count - 2]
            let endPoint = points[points.count - 1]
            addLine(from: startPoint, to: endPoint)
            
            let distance = calculateDistance(from: startPoint, to: endPoint)
            channel.invokeMethod("onDistanceCalculated", arguments: distance)
        }
    }
    
    func undo() {
        guard !points.isEmpty else { return }
        
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Haptic feedback on undo
        // ═══════════════════════════════════════════════════════════════
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Remove last point
        points.removeLast()
        
        // Remove last sphere
        if let lastSphere = sphereNodes.popLast() {
            lastSphere.removeFromParentNode()
        }
        
        // Remove last line
        if let lastLine = lineNodes.popLast() {
            lastLine.removeFromParentNode()
        }
        
        channel.invokeMethod("onPointCount", arguments: points.count)
        
        // Recalculate distance
        if points.count >= 2 {
            let startPoint = points[points.count - 2]
            let endPoint = points[points.count - 1]
            let distance = calculateDistance(from: startPoint, to: endPoint)
            channel.invokeMethod("onDistanceCalculated", arguments: distance)
        }
    }
    
    func clear() {
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Haptic feedback on clear
        // ═══════════════════════════════════════════════════════════════
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Remove all spheres
        for node in sphereNodes {
            node.removeFromParentNode()
        }
        sphereNodes.removeAll()
        
        // Remove all lines
        for node in lineNodes {
            node.removeFromParentNode()
        }
        lineNodes.removeAll()
        
        // Clear points
        points.removeAll()
        
        channel.invokeMethod("onPointCount", arguments: 0)
    }
    
    func takeSnapshot() -> FlutterStandardTypedData? {
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Haptic feedback on screenshot
        // ═══════════════════════════════════════════════════════════════
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let image = arView.snapshot()
        guard let data = image.pngData() else { return nil }
        return FlutterStandardTypedData(bytes: data)
    }
    
    // MARK: - Private Methods
    
    private func addSphere(at position: SCNVector3) {
        let sphere = SCNSphere(radius: sphereRadius)
        
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Better material for visibility
        // ═══════════════════════════════════════════════════════════════
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.lightingModel = .constant
        material.isDoubleSided = true
        sphere.firstMaterial = material
        
        let node = SCNNode(geometry: sphere)
        node.position = position
        
        arView.scene.rootNode.addChildNode(node)
        sphereNodes.append(node)
    }
    
    private func addLine(from start: SCNVector3, to end: SCNVector3) {
        let distance = calculateDistance(from: start, to: end)
        
        // Create cylinder for line
        let cylinder = SCNCylinder(radius: lineRadius, height: CGFloat(distance))
        
        // ═══════════════════════════════════════════════════════════════
        // IMPROVED: Better material
        // ═══════════════════════════════════════════════════════════════
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.lightingModel = .constant
        material.isDoubleSided = true
        cylinder.firstMaterial = material
        
        let node = SCNNode(geometry: cylinder)
        
        // Position at midpoint
        node.position = SCNVector3(
            (start.x + end.x) / 2,
            (start.y + end.y) / 2,
            (start.z + end.z) / 2
        )
        
        // Rotate to align with line direction
        let direction = SCNVector3(end.x - start.x, end.y - start.y, end.z - start.z)
        let up = SCNVector3(0, 1, 0)
        
        let cross = crossProduct(up, direction)
        let dot = dotProduct(up, normalize(direction))
        let angle = acos(min(max(dot, -1), 1)) // Clamp to avoid NaN
        
        if cross.x != 0 || cross.y != 0 || cross.z != 0 {
            node.rotation = SCNVector4(cross.x, cross.y, cross.z, angle)
        }
        
        arView.scene.rootNode.addChildNode(node)
        lineNodes.append(node)
    }
    
    private func calculateDistance(from start: SCNVector3, to end: SCNVector3) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z
        return Double(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    private func normalize(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
        guard length > 0 else { return vector }
        return SCNVector3(vector.x/length, vector.y/length, vector.z/length)
    }
    
    private func crossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        )
    }
    
    private func dotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        return a.x * b.x + a.y * b.y + a.z * b.z
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        if !planeDetected {
            planeDetected = true
            DispatchQueue.main.async {
                // ═══════════════════════════════════════════════════════════════
                // IMPROVED: Haptic feedback when surface detected
                // ═══════════════════════════════════════════════════════════════
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                self.channel.invokeMethod("onPlaneDetected", arguments: true)
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // IMPROVED: Faster detection using feature points
    // ═══════════════════════════════════════════════════════════════
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Count feature points for faster "ready" state
        if let points = frame.rawFeaturePoints?.points {
            let count = points.count
            
            // If we have enough feature points, surface is trackable
            if count >= minFeaturePointsForDetection && !planeDetected {
                planeDetected = true
                DispatchQueue.main.async {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    self.channel.invokeMethod("onPlaneDetected", arguments: true)
                }
            }
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.channel.invokeMethod("onError", arguments: error.localizedDescription)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.channel.invokeMethod("onError", arguments: "AR session interrupted")
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking when session resumes
        if let configuration = session.configuration {
            session.run(configuration, options: [.resetTracking])
        }
    }
}