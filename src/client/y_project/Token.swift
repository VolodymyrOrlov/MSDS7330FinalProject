import Foundation
import SceneKit
import ARKit
import CoreLocation
import AVFoundation

class Token {
    
    var modelNode: SCNNode!
    var pointLocation: CLLocation
    var originalTransform: SCNMatrix4!
    var distance: Float!
    
    init(_ latitude: Double, _ longitude: Double) {
        self.pointLocation = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func updateLocation(_ location : CLLocation, _ modelScene: SCNScene) {
        self.distance = Float(location.distance(from: self.pointLocation))
        
        if self.modelNode == nil {
            let sphere = SCNSphere(radius: 0.3)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "art.scnassets/ball")
            sphere.materials = [material]
            
            self.modelNode = SCNNode(geometry: sphere)
            modelScene.rootNode.addChildNode(self.modelNode)
            let (minBox, maxBox) = self.modelNode.boundingBox
            self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
            self.originalTransform = self.modelNode.transform
            
            positionModel(location)
            
            modelScene.rootNode.addChildNode(self.modelNode)
        } else {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            
            positionModel(location)
            
            SCNTransaction.commit()
        }
        
    }
    
    func detectCollision(_ camera: ARCamera) -> Bool {
        
        let objDistance = simd_distance(self.modelNode.simdTransform.columns.3,
                                        camera.transform.columns.3)
        
        if objDistance < 5 {
            self.modelNode.removeFromParentNode()
            return true
        } else {
            return false
        }
        
    }
    
    private func positionModel(_ location: CLLocation) {
        
        self.modelNode.position = translateNode(location)
        
        self.modelNode.scale = scaleNode(location)
    }
    
    private func scaleNode (_ location: CLLocation) -> SCNVector3 {
        let scale = min( max( Float(1000 / distance), 1.5 ), 3 )
        return SCNVector3(x: scale, y: scale, z: scale)
    }
    
    private func translateNode (_ location: CLLocation) -> SCNVector3 {
        let locationTransform =
            transformMatrix(matrix_identity_float4x4, pointLocation, location)
        return positionFromTransform(locationTransform)
    }
    
    private func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
        return SCNVector3Make(
            transform.columns.3.x, transform.columns.3.y, transform.columns.3.z
        )
    }
    
    private func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ driverLocation: CLLocation) -> simd_float4x4 {
        let bearing = bearingBetweenLocations(pointLocation, driverLocation)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        
        let position = vector_float4(0.0, 0.0, distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
    
    private func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    private func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    private func bearingBetweenLocations(_ originLocation: CLLocation, _ driverLocation: CLLocation) -> Double {
        let lat1 = originLocation.coordinate.latitude.toRadians()
        let lon1 = originLocation.coordinate.longitude.toRadians()
        
        let lat2 = driverLocation.coordinate.latitude.toRadians()
        let lon2 = driverLocation.coordinate.longitude.toRadians()
        
        let longitudeDiff = lon2 - lon1
        
        let y = sin(longitudeDiff) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
        
        return atan2(y, x)
    }
    
}

