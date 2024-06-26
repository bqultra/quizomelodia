//
//  ViewController.swift
//  Quizomelodia
//
//  Created by Szymek on 25/03/2024.
//

import UIKit

class ViewController: UIViewController {


    @IBAction func newGameBtn(_ sender: UIButton) {
        
        let passNickname = NicknameViewController()
        self.navigationController?.pushViewController(passNickname, animated: true)
    }
    
    @IBAction func rankBtn(_ sender: UIButton) {
        
        let getScores = ResultsViewController()
        self.navigationController?.pushViewController(getScores, animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

