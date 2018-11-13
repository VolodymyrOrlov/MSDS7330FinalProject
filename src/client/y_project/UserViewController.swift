//
//  UserViewController.swift
//  y_project
//
//  Created by Volodymyr Orlov on 11/12/18.
//  Copyright © 2018 Volodymyr Orlov. All rights reserved.
//

import UIKit
import RealmSwift

class UserViewController: UIViewController {
    
    @IBOutlet weak var playerName: UITextField!
    
    let realm: Realm = try! Realm()
    let server = Server(baseURL: "http://192.168.1.68:5000/api/v1")
    
    private var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        
        user = User.getOrCreate(id: deviceID, realm: realm)
        playerName.text = user.name
    }
    
    @IBAction func playerNameEditEnd(_ sender: Any) {
        let userName = playerName.text ?? ""
        
        guard let u = user else {
            return
        }
        
        try! realm.write {
            u.name = userName
        }
        
        server.updateUser(u)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
