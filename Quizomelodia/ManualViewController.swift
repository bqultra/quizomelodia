//
//  ManualViewController.swift
//  Quizomelodia
//
//  Created by Szymek on 26/06/2024.
//

import Foundation
import UIKit

class ManualViewController: UIViewController {
    
    @IBOutlet weak var manualText: UILabel!
    
    @IBAction func backToGameButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manualText.text = "1️⃣ Gracz wpisuje, ile sekund utwór będzie odtwarzany, po czym klika przycisk Odtwórz. \n\n" + "2️⃣ Po odtworzeniu utworu wyświetlą się 4 odpowiedzi, z których jedna jest poprawna. \n\n" + "3️⃣ Jeśli odpowiedź była poprawna, gracz otrzymuje punkty równoważne wybranym sekundom i kontynuuje rozgrywkę aż do odgadnięcia 7 utworów. \n\n" + "4️⃣ W przypadku błędnej odpowiedzi, gra kończy się, a wynik nie jest zapisywany do rankingu. \n\n" + "5️⃣ Najwyższe miejsce zajmie gracz, który turniej ukończył w jak najkrótszym czasie (zdobył najmniej punktów)."
    }
    
    
}
