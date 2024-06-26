//
//  RankViewController.swift
//  Quizomelodia
//
//  Created by Szymek on 20/06/2024.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore

class RankViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mainBackButton: UIButton!
    
    let db = Firestore.firestore()
    var players = [Player]()
    
    let goldColor = UIColor(#colorLiteral(red: 1, green: 0.7891149618, blue: 0.01550776908, alpha: 1)) // Define your custom gold color
    let silverColor = UIColor(#colorLiteral(red: 0.8066730497, green: 0.8014142348, blue: 0.8117261614, alpha: 1)) // Define your custom silver color
    let bronzeColor = UIColor(#colorLiteral(red: 0.8750885555, green: 0.4132495221, blue: 0, alpha: 1)) // Define your custom bronze color
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainBackButton.layer.cornerRadius = 5
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register cell classes if necessary
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Call function to fetch data from Firestore
        fetchPlayersFromFirestore()
    }
    
    func fetchPlayersFromFirestore() {
        db.collection("players")
            .order(by: "score", descending: false) // Order by score in descending order
            .order(by: "time", descending: true)
            .whereField("score", isGreaterThan: 0) // Filter by score (example filter)
            .limit(to: 10)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.players.removeAll() // Clear the existing data
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let nickname = data["nickname"] as? String,
                       let score = data["score"] as? Int {
                        print(nickname)
                        print(score)
                        let player = Player(nickname: nickname, score: score)
                        self.players.append(player)
                        print(self.players)
                    }
                }
                // Reload UITableView once data is fetched
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let player = players[indexPath.row]
        let rank = indexPath.row + 1
        cell.textLabel?.text = "\(rank). \(player.nickname) - \(player.score) sekund"
        cell.textLabel?.textAlignment = NSTextAlignment.center
        
        // Set background color based on rank
        switch rank {
        case 1:
            cell.backgroundColor = goldColor
        case 2:
            cell.backgroundColor = silverColor
        case 3:
            cell.backgroundColor = bronzeColor
        default:
            cell.backgroundColor = UIColor.clear // Reset to default if not top 3 ranks
        }
        
        return cell
    }
}
