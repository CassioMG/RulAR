//
//  ViewController.swift
//  RulAR
//
//  Created by Cássio Marcos Goulart on 03/07/19.
//  Copyright © 2019 CMG Solutions. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var dotNodes = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.debugOptions = .showFeaturePoints
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchPoint = touches.first?.location(in: sceneView) {
            
            if let hitResult = sceneView.hitTest(touchPoint, types: .featurePoint).first {
                addDot(at: hitResult)
            }
        }
    }
    
    
    private func addDot(at hitResult: ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)
        dotGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        calculateDistance(dotNodes)
    }
    
    
    private func calculateDistance(_ nodes: [SCNNode]) {
        
        if nodes.count >= 2 {
            
            let startPosition = nodes.first!.position
            let endPosition = nodes.last!.position
            
            let distance = sqrt(
                pow(endPosition.x - startPosition.x, 2) +
                pow(endPosition.y - startPosition.y, 2) +
                pow(endPosition.z - startPosition.z, 2)
            )
   
            printText(text: "\(Int(distance*100)) cm", atPosition: endPosition)
            
            drawLine(from: startPosition, to: endPosition)
            
            dotNodes.removeFirst()
        }
    }
    
    private func printText(text: String, atPosition position: SCNVector3) {
    
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    
    private func drawLine(from startPosition: SCNVector3, to endPosition: SCNVector3) {
        
        let lineGeometry = SCNGeometry.line(from: startPosition, to: endPosition)
        
        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = SCNVector3Zero
        
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension SCNGeometry {
    
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
    
}
