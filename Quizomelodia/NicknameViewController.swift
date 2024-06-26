//
//  NicknameViewController.swift
//  Quizomelodia
//
//  Created by Szymek on 26/03/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class NicknameViewController: UIViewController {
    
    var nickToPass: String = ""
    var userAction: String = ""

    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        guard var email = nicknameField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty else {
            let alertAccount = UIAlertController(title: "Podaj właściwe dane", message: "Należy podać nazwę użytkownika oraz hasło", preferredStyle: .alert)
            alertAccount.addAction(UIAlertAction(title: "Jeszcze raz", style: .default, handler: nil))
            self.present(alertAccount, animated: true, completion: nil)
            print("Email and password must not be empty.")
            return
        }
        
        nickToPass = email
        
        email += "@quizomelodia.pl"
        
        
    self.signInUser(withEmail: email, password: password)
        
    }
    
    private func signInUser(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as? NSError {
                switch AuthErrorCode(_nsError: error) {
                case AuthErrorCode.userNotFound:
                    print(error)
                        // Prompt user to create an account
                self.promptForUserCreation(withEmail: email, password: password)
                case AuthErrorCode.wrongPassword:
                    self.showLoginErrorAlert()
                default:
                        print(error)// Handle other errors
                    let alert = UIAlertController(title: "Brak połączenia z serwerem", message: "Wystąpił problem połączenia z serwerem. Spróbuj później.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    }
                
                print("Error signing in: \(error.localizedDescription)")
            } else {
                // Successful sign-in
                self.userAction = "signed in"
                self.navigateToNextViewController()
                print("Successfully signed in as \(email).")
            }
        }
    }

    private func promptForUserCreation(withEmail email: String, password: String) {
        let alert = UIAlertController(title: "Utworzyć nowe konto?", message: "Użytkownik o podanym \n pseudonimie nie istnieje.\n Czy chcesz utworzyć nowe konto?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Anuluj", style: .destructive) { _ in
            self.resetFields()
        })
        alert.addAction(UIAlertAction(title: "Utwórz", style: .default) { _ in
            self.createUser(withEmail: email, password: password)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createUser(withEmail email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                if password.count < 6 {
                    
                    let alert = UIAlertController(title: "Nie utworzono konta", message: "Hasło powinno posiadać minimum 6 znaków.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Zmień hasło", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.resetFields()
                    print("Error creating user: \(error.localizedDescription)")
                    
                } else {
                    let alert = UIAlertController(title: "Nie utworzono konta", message: "Nie udało się utworzyć konta. Spróbuj ponownie.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.resetFields()
                    print("Error creating user: \(error.localizedDescription)")
                }
            } else {
                self.userAction = "created"
                self.navigateToNextViewController()
                print("Successfully created \(email) user.")
            }
        }
    }
    
    private func showLoginErrorAlert() {
        let alert = UIAlertController(title: "Błędny pseudonim lub hasło", message: "Nie udało się zalogować. Nieprawidłowy pseudonim lub hasło.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Spróbuj ponownie", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func resetFields() {
        self.nicknameField.text = ""
        self.passwordField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passNickname" {
            if let destinationVC = segue.destination as? GameViewController {
                destinationVC.receivedData = nickToPass
                destinationVC.userAction = userAction
            }
        }
    }
    
    private func navigateToNextViewController() {
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
            nextViewController.receivedData = nickToPass
            nextViewController.userAction = userAction
            nextViewController.modalTransitionStyle = .coverVertical
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: true) {
                
                // Show alert after navigation
                let alertMessage = self.userAction == "created" ? "\n Utworzono nowe konto o nazwie: \n\n \(self.nickToPass)" : "\n Zalogowano pomyślnie użytkownika: \n \n \(self.nickToPass)"
                let alert = UIAlertController(title: "Udało się!", message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                nextViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
