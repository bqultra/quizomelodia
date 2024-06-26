//
//  GameOverViewController.swift
//  Quizomelodia
//
//  Created by Szymek on 20/06/2024.
//

import UIKit
import Foundation

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var rankButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rankButton.layer.cornerRadius = 5
    }
}
