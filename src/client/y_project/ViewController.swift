import UIKit
import SceneKit
import ARKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var audioPlayer = AVAudioPlayer()
    
    var tokens = [Token]()
    
    var score: Int = 0 {
        didSet {
            updateStatusText()
        }
    }

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusTextView: UITextView!
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            updateLocation(location.coordinate.latitude, location.coordinate.longitude)
        }
    }
    
    func playSound() {
        do {
            if let fileURL = Bundle.main.path(forResource: "catch", ofType: "wav") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        self.audioPlayer.play()
    }
    
    func updateLocation(_ latitude : Double, _ longitude : Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        tokens = tokens.filter{
            $0.updateLocation(location, sceneView.scene)
           
            if($0.detectCollision(currentFrame.camera)){
                score += 1
                playSound()
                return false
            } else{
                return true
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        tokens.append(Token(37.309260, -121.976377))
        tokens.append(Token(37.309146, -121.975958))
        
        updateStatusText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    private func updateStatusText() {
        statusTextView.text = "\(String(format: "%d", score)) items collected\n"
    }
    
}
