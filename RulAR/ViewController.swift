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
import ChameleonFramework
import SCNLine

class ViewController: UIViewController, ARSCNViewDelegate {

    var dotNodes = [SCNNode]()
    var lineNodes = [SCNNode]()
    var textNodes = [SCNNode]()
    
    var currentRandomColor: UIColor?
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        // sceneView.debugOptions = .showFeaturePoints
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
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
        currentRandomColor = RandomFlatColorWithShade(.light)
        dotGeometry.firstMaterial?.diffuse.contents = currentRandomColor
        
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
            
            let startPosition = nodes[nodes.count-2].position
            let endPosition = nodes[nodes.count-1].position
            
            let distance = sqrt(
                pow(endPosition.x - startPosition.x, 2) +
                pow(endPosition.y - startPosition.y, 2) +
                pow(endPosition.z - startPosition.z, 2)
            )
   
            printText(text: "\(Int(distance*100)) cm", atPosition: endPosition)
            
            drawLine(from: startPosition, to: endPosition)
        }
    }
    
    private func printText(text: String, atPosition position: SCNVector3) {
    
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = currentRandomColor
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        textNodes.append(textNode)
    }
    
    private func drawLine(from startPoint: SCNVector3, to endPoint: SCNVector3) {
        
        let lineGeometry = SCNGeometry.line(points: [startPoint, endPoint], radius: 0.0025).0
        lineGeometry.firstMaterial?.diffuse.contents = currentRandomColor
        
        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = SCNVector3Zero
        
        sceneView.scene.rootNode.addChildNode(lineNode)
        lineNodes.append(lineNode)
    }
    
    @IBAction func eraseScene(_ sender: UIBarButtonItem) {
        
        textNodes.removeAll { $0.removeFromParentNode(); return true }
        lineNodes.removeAll { $0.removeFromParentNode(); return true }
        dotNodes.removeAll { $0.removeFromParentNode(); return true }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}
