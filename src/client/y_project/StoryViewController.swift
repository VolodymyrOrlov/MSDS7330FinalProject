//
//  StoryViewController.swift
//  y_project
//
//  Created by Volodymyr Orlov on 11/28/18.
//  Copyright © 2018 Volodymyr Orlov. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {

    @IBOutlet weak var storyText: UITextView!
    
    var text:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyText.text = text

        // Do any additional setup after loading the view.
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
