import UIKit
import SceneKit
import ARKit
import CoreLocation
import AVFoundation
import RealmSwift

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var audioPlayer = AVAudioPlayer()
    
    var tokens = [Token]()
    
    let realm: Realm = try! Realm()
    
    let server = Server()
    
    var score: (Int, Int, Int) = (0, 0, 0) {
        didSet {
            updateStatusText()
        }
    }
    
    var lastLocation: CLLocation!
    
    var userID: String = UIDevice.current.identifierForVendor!.uuidString

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
    
    func updateTokensList(_ tokens: [Token]){
        for token in self.tokens {
            token.deleteToken()
        }
        
        self.tokens.removeAll()
        
        for token in tokens {
            self.tokens.append(token)
        }
        
    }
    
    func updateLocation(_ latitude : Double, _ longitude : Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let llocation = lastLocation.or {
            lastLocation = location
            return location
        }

        print(location.distance(from: llocation))
        if(location.distance(from: llocation) > 30){
            server.getTokens(userID){ tokens in
                self.updateTokensList(tokens)
            }
           lastLocation = location
        }
        
        server.reportLocation(userID, location)
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        tokens = tokens.filter{
            $0.updateLocation(location, sceneView.scene)
           
            if($0.detectCollision(currentFrame.camera)){
                server.reportCollision(userID, $0) { culture, politics, technology, story in
                   self.score = (culture, politics, technology)
                   self.displayStorySegment(story)
                }
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
        
        server.syncUser(userID) { userID, name in
            
            DispatchQueue.main.async {
            
                let user = User.getOrCreate(id: userID, realm: self.realm)
                
                try! self.realm.write {
                    user.name = name
                }
            }
            
        }
        
        server.getTokens(userID){ tokens in
            self.updateTokensList(tokens)
        }
        
        server.getScore(userID){ culture, politics, technology in
            self.score = (culture, politics, technology)
        }
        
        updateStatusText()                
        
    }
    
    func displayStorySegment(_ text: String) {
        if(!text.isEmpty){
            DispatchQueue.main.async {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Story") as! StoryViewController
                newViewController.text = text
                self.present(newViewController, animated: true, completion: nil)
            }
        }
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
        DispatchQueue.main.async {
            self.statusTextView.text = "culture: \(self.score.0), politics: \(self.score.1), technology: \(self.score.2)\n"
        }
    }
    
}
