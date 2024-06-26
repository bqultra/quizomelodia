//
//  FinishViewController.swift
//  Quizomelodia
//
//  Created by Szymek on 20/06/2024.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore

class FinishViewController: UIViewController {
    
    var receivedNickname: String?
    var receivedPoints: Int?
    
    @IBOutlet weak var rankButton: UIButton!
    
    let db = Firestore.firestore()
    var players = [Player]()
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLabel.text = receivedNickname
        pointsLabel.text = "\(receivedPoints ?? 0) sekund"
        rankButton.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let nickname = receivedNickname, let score = receivedPoints else {
            print("Error: nickname or score is nil")
            return
        }
        
        addPlayerToFirestore(nickname: nickname, score: score)
    }
    
    
    func addPlayerToFirestore(nickname: String, score: Int) {
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("players").addDocument(data: [
            "nickname": nickname,
            "score": score,
            "time": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    
}


