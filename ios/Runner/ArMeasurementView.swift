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
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return true
    }
    
    func dispose() {
        arView.session.pause()
    }
    
    func addPoint() {
        // Get center of screen
        let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        // Perform hit test
        let hitResults = arView.hitTest(screenCenter, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane, .estimatedVerticalPlane])
        
        guard let hit = hitResults.first else {
            channel.invokeMethod("onError", arguments: "No surface detected. Move device slowly.")
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
        let image = arView.snapshot()
        guard let data = image.pngData() else { return nil }
        return FlutterStandardTypedData(bytes: data)
    }
    
    // MARK: - Private Methods
    
    private func addSphere(at position: SCNVector3) {
        let sphere = SCNSphere(radius: sphereRadius)
        sphere.firstMaterial?.diffuse.contents = UIColor.white
        sphere.firstMaterial?.lightingModel = .constant
        
        let node = SCNNode(geometry: sphere)
        node.position = position
        
        arView.scene.rootNode.addChildNode(node)
        sphereNodes.append(node)
    }
    
    private func addLine(from start: SCNVector3, to end: SCNVector3) {
        let distance = calculateDistance(from: start, to: end)
        
        // Create cylinder for line
        let cylinder = SCNCylinder(radius: lineRadius, height: CGFloat(distance))
        cylinder.firstMaterial?.diffuse.contents = UIColor.white
        cylinder.firstMaterial?.lightingModel = .constant
        
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
        let angle = acos(dot)
        
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
                self.channel.invokeMethod("onPlaneDetected", arguments: true)
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
}
