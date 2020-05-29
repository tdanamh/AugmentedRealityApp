//
//  ViewController.swift
//  ARFirstTutorial
//
//  Created by Dana Tudor on 29/05/2020.
//  Copyright © 2020 Dana Tudor. All rights reserved.
//

import UIKit
import ARKit

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    // Tracks the orientation and the position of the device. Detect real surfaces visible through the camera
    private let configuration = ARWorldTrackingConfiguration()
    
    private var node: SCNNode!
    
    private var lastRotation: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = true
        // Allow to see how ARKit detects a surface
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        addTapGesture()
        addPinchGesture()
        addRotationGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let colors = [
                    UIColor.green,  // front
                    UIColor.red,    // right
                    UIColor.blue,   // back
                    UIColor.yellow, // left
                    UIColor.purple, // top
                    UIColor.gray    // bottom
                    ]
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        box.materials = sideMaterials
        
        self.node = SCNNode()
        self.node.geometry = box
        self.node.position = SCNVector3(x, y, z)
        
        sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTap(_ gesture: UIPanGestureRecognizer) {
        let tapLocation = gesture.location(in: self.sceneView)
        let results = self.sceneView.hitTest(tapLocation, types: .featurePoint)

        guard let result = results.first else {
            return
        }
     
        let translation = result.worldTransform.translation
 
        guard let node = self.node else {
            self.addBox(x: translation.x, y: translation.y, z: translation.z)
            return
        }
        
        node.position = SCNVector3Make(translation.x, translation.y, translation.z)
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    private func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        self.sceneView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
       switch gesture.state {
        
       case .began:
           gesture.scale = CGFloat(node.scale.x)

       case .changed:
           var newScale: SCNVector3
           
           if gesture.scale < 0.5 {
               newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
           } else if gesture.scale > 3 {
               newScale = SCNVector3(3, 3, 3)
           } else {
               newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
           }
           node.scale = newScale
        
       default:
           break
       }
   }
     
    private func addRotationGesture() {
       let panGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
       self.sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
            
        case .changed:
           self.node.eulerAngles.y = self.lastRotation + Float(gesture.rotation)
            
        case .ended:
           self.lastRotation += Float(gesture.rotation)
            
        default:
           break
        }
    }
    
}

