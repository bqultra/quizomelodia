//
//  GameViewController.swift
//  Quizomelodia
//
//  Created by Szymek on 19/06/2024.
//

import UIKit
import AVFoundation
import FirebaseCore
import FirebaseAuth

class GameViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var receivedData: String?
    var userAction: String?
    
    var nicknameToPass: String = ""
    var pointsToPass: Int = 0
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var progressBar: UIStackView!
    
    var correctSoundPlayer: AVAudioPlayer?
        var wrongSoundPlayer: AVAudioPlayer?
        var gameOverSoundPlayer: AVAudioPlayer?
        var gameWinSoundPlayer: AVAudioPlayer?
        
        var timer: Timer?
        var player: AVAudioPlayer?
        var currentSongIndex = 0
        var correctAnswers = 0
        var points = 0
        var selectedTime = 0
        
        let songs = [
            //Dżem - Wehikuł czasu
            ("Piosenka nr 1", ["Dżem - Wehikuł czasu", "Happysad - Zanim pójdę", "Lady Pank - Na co komu dziś", "Enej - skrzydlate ręce"], 0),
            ("Piosenka nr 2", ["Kombi - Black and White", "Elektryczne gitary - Dzieci wybiegły", "Lombard - Przeżyj to sam", "Edyta Górniak - To nie ja"], 1),
            ("Piosenka nr 3", ["Budka Suflera - Jolka, Jolka pamiętasz", "Piersi - Bałkanica", "Bolter - Daj mi tę noc", "Czerwone Gitary - Nie spoczniemy"], 1),
            ("Piosenka nr 4", ["Ira - Nadzieja", "Marek Grechuta - Niepewność", "Lady Pank - Mniej niż zero", "Krzysztof Krawczyk - Bo jesteś ty"], 2),
            ("Piosenka nr 5", ["Perfect - Nie płacz Ewka", "Budka suflera - Takie tango", "Lady Pank - Fabryka małp", "T.Love - Warszawa"], 0),
            ("Piosenka nr 6", ["Dżem - List do M", "Papa Dance - Naj Story", "Edyta Bartosiewicz - Sen", "Jeden Osiem L - Jak zapomnieć"], 3),
            ("Piosenka nr 7", ["Lombard - Szklana pogoda", "Varius Manx - Orła cień", "Stachursky - Typ niepokorny", "Wilki - Baśka"], 3),
        ]
        
    override func viewDidLoad() {
            super.viewDidLoad()
        
            resultLabel.text = receivedData
            nicknameToPass = receivedData ?? "User"
            setupQuiz()
            loadSoundPlayers()
            answerButtons.forEach { $0.isHidden = true }
            logoImageView.isHidden = false
            timeTextField.delegate = self
            playButton.isEnabled = false
            updateProgress()
            
        }
    
    func updateProgress() {
        // Clear existing views in the stack view
        for subview in progressBar.arrangedSubviews {
            progressBar.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        // Add emojis based on correct answers only
        for index in 0..<7 {
            let emojiLabel = UILabel()
            emojiLabel.textAlignment = .center
            if index < correctAnswers {
                emojiLabel.text = "✅" // Display tick emoji for correct answers
            } else {
                emojiLabel.text = "⏺" // Display nothing for incorrect answers initially
            }
            progressBar.addArrangedSubview(emojiLabel)
        }
    }
        
        // Example function to handle user's answer (correct or incorrect)
        func handleAnswer(isCorrect: Bool) {
            // Update the progress bar
            updateProgress()
        }
        
        // Example function to reset the progress bar
        func resetProgress() {
            correctAnswers = 0
            updateProgress()
        }
    
    // UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Enable the button when the text field begins typing
        playButton.isEnabled = true
        return true
    }
        
        func loadSoundPlayers() {
            if let correctSoundPath = Bundle.main.path(forResource: "correct", ofType: "mp3"),
               let wrongSoundPath = Bundle.main.path(forResource: "wrong", ofType: "mp3"),
               let gameOverSoundPath = Bundle.main.path(forResource: "gameover", ofType: "mp3"),
               let gameWinSoundPath = Bundle.main.path(forResource: "win", ofType: "mp3") {
                do {
                    correctSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: correctSoundPath))
                    wrongSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: wrongSoundPath))
                    gameOverSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: gameOverSoundPath))
                    gameWinSoundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: gameWinSoundPath))
                } catch {
                    print("Error loading sound files")
                }
            }
        }
        
        func setupQuiz() {
            if currentSongIndex < songs.count {
                let song = songs[currentSongIndex]
                songLabel.text = song.0
                for (index, button) in answerButtons.enumerated() {
                    button.setTitle(song.1[index], for: .normal)
                    button.tag = index
                    button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
                }
                timeTextField.isEnabled = true
                pointsLabel.text = "Punkty: \(points)"
                
                // Hide answer buttons and show logo initially for each song
                answerButtons.forEach { $0.isHidden = true }
                logoImageView.isHidden = false
            } else {
                endQuiz()
            }
        }
        
        @objc func answerTapped(_ sender: UIButton) {
            player?.stop()
            timeTextField.text = ""
            let correctAnswerIndex = songs[currentSongIndex].2
            
            answerButtons.forEach { $0.isEnabled = false }
            
            if sender.tag == correctAnswerIndex {
                sender.backgroundColor = .green
                sender.setTitleColor(.black, for: .normal)
                correctAnswers += 1
                handleAnswer(isCorrect: true)
                points += selectedTime
                correctSoundPlayer?.play()
            } else {
                sender.backgroundColor = .red
                sender.setTitleColor(.black, for: .normal)
                wrongSoundPlayer?.play()
                handleAnswer(isCorrect: false)
                if let correctButton = answerButtons.first(where: { $0.tag == correctAnswerIndex }) {
                    correctButton.backgroundColor = .green
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Reset button colors
                self.answerButtons.forEach {
                    $0.backgroundColor = .systemBackground
                    $0.setTitleColor(.label, for: .normal)
                }
                
                if sender.tag == correctAnswerIndex {
                    self.currentSongIndex += 1
                    self.setupQuiz()
                } else {
                    self.endQuiz(withFailure: true)
                }
                
                // Re-enable buttons
                self.answerButtons.forEach { $0.isEnabled = true }
            }
        }
        
        @IBAction func startQuizTapped(_ sender: UIButton) {
            guard let timeText = timeTextField.text, let time = Int(timeText) else { return }
            selectedTime = time
            startSong()
        }
        
        @IBAction func playTapped(_ sender: UIButton) {
            player?.play()
            playButton.isEnabled = false
            timeTextField.isEnabled = false
        }
        
        func startSong() {
            guard currentSongIndex < songs.count else { return }
            let song = songs[currentSongIndex].0
            if let url = Bundle.main.url(forResource: song, withExtension: "mp3") {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.play()
                    timer = Timer.scheduledTimer(timeInterval: TimeInterval(selectedTime), target: self, selector: #selector(songTimeUp), userInfo: nil, repeats: false)
                } catch {
                    print("Error playing song")
                }
            }
        }
        
        @objc func songTimeUp() {
            player?.stop()
            timer?.invalidate()
            
            // Show answer buttons after the song stops playing
            answerButtons.forEach { $0.isHidden = false }
            logoImageView.isHidden = true
        }
        
        func endQuiz(withFailure failure: Bool = false) {
            timer?.invalidate()
            player?.stop()
            playButton.isEnabled = false
            resetProgress()
            if failure {
                gameOverSoundPlayer?.play()
                navigateToGameOverViewController()
            } else {
                gameWinSoundPlayer?.play()
                pointsToPass = points
                performSegue(withIdentifier: "passFinalResult", sender: self)
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "passFinalResult" {
                if let destinationVC = segue.destination as? FinishViewController {
                    destinationVC.receivedNickname = nicknameToPass
                    destinationVC.receivedPoints = pointsToPass
                }
            }
        }
        
        private func navigateToNextViewController() {
            guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "FinishViewController") else { return }
            nextViewController.modalTransitionStyle = .coverVertical
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: true, completion: nil)
        }
        
        private func navigateToGameOverViewController() {
            guard let gameOverViewController = storyboard?.instantiateViewController(withIdentifier: "GameOverViewController") else { return }
            gameOverViewController.modalTransitionStyle = .coverVertical
            gameOverViewController.modalPresentationStyle = .fullScreen
            present(gameOverViewController, animated: true, completion: nil)
        }
    }
