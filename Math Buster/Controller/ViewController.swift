//
//  ViewController.swift
//  Math Buster
//
//  Created by АБЗАЛ АБЗАЛ on 31.10.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resultField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var  dataModel: ViewControllerDataModel = ViewControllerDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateProblem()
        scheduleTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        
        dataModel.navigationBarPreviousTintColor = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.tintColor = dataModel.navigationBarPreviousTintColor
    }
    
    func setupUI() {
        timerContainerView.layer.cornerRadius = 5
        resultField.keyboardType = .decimalPad
    }

    func generateProblem() {
        let selectedIndex: Int = segmentedControl.selectedSegmentIndex
        let range = dataModel.ranges[selectedIndex]
        let firstDigit = Int.random(in: range)
        let arithmeticOperator:String = ["+", "-", "x", "/"].randomElement()!
        
        var startInt: Int = range.lowerBound
        var endInt: Int = range.upperBound
        
        if arithmeticOperator == "/" && startInt == 0 {
            startInt = 1
        } else if arithmeticOperator == "-" {
            endInt = firstDigit
        }
        let secondDigit = Int.random(in: startInt...endInt)
        
        problemLabel.text = "\(firstDigit) \(arithmeticOperator) \(secondDigit) ="
        
        switch arithmeticOperator {
        case "+":
            dataModel.result = Double(firstDigit + secondDigit)
        case "-":
            dataModel.result = Double(firstDigit - secondDigit)
        case "x":
            dataModel.result = Double(firstDigit * secondDigit)
        case "/":
            dataModel.result = Double(firstDigit) / Double(secondDigit)
        default:
            dataModel.result = nil
        }
        
    }
    
    func scheduleTimer() {
        dataModel.countDown = 30
        dataModel.timer?.invalidate()
        dataModel.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimerUI() {
        dataModel.countDown -= 1
        
        let seconds: String = String(format: "%02d", dataModel.countDown)
        
        timerLabel.text = "00 : \(seconds)"
        progressView.progress = Float(30 - dataModel.countDown) / 30
        
        if dataModel.countDown <= 0 {
            finishGame()

        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        guard let text = resultField.text else {
            return
        }
        guard !text.isEmpty else {
            return
        }
        guard let newResult = Double(text) else {
            return
        }
        
        if newResult == dataModel.result {
            print("Correct answer")
            let selectedIndex = segmentedControl.selectedSegmentIndex
            dataModel.score += dataModel.scoreAmount[selectedIndex]
            scoreLabel.text = "Score: \(dataModel.score)"
        } else {
            print("Incorrect answer")
        }
        
        generateProblem()
        resultField.text = nil
    }
    
    @IBAction func restartPressed(_ sender: Any) {
        restart()
    }
    
    func restart() {
        dataModel.score = 0
        scoreLabel.text = "Score: 0"
        
        generateProblem()
        
        scheduleTimer()
        
        resultField.isEnabled = true
        submitButton.isEnabled = true
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        restart()
    }
    
    func finishGame() {
        dataModel.timer?.invalidate()
        resultField.isEnabled = false
        submitButton.isEnabled = false
        
        askForName()
    }
    
    func askForName() {
        let alertController = UIAlertController(title: "Game is Over!", message: "Save your score: \(dataModel.score)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first else {
                print("Textfield is absent")
                return
            }
            guard let text = textField.text, !text.isEmpty else {
                print("Text is nil or empty")
                return
            }
            print("Name: \(text)")
            self.saveUserScoreAsStruct(name: text)
        }
        alertController.addAction(saveAction)
        
        let canselAction = UIAlertAction(title: "Cansel", style: .cancel)
        alertController.addAction(canselAction)
        
        present(alertController, animated: true)
    }
    
    func saveUserScoreAsStruct(name: String) {
        let userScore : UserScore = UserScore(name: name, score: dataModel.score)
        
        var level: Level?
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            level = .easy
        case 1:
            level = .medium
        case 2:
            level = .hard
        default:
            ()
        }
        
        guard let level = level else {
            print("Level is nil")
            return
        }
        
        let userScoreArray: [UserScore] = ViewController.getAllUserScores(level: level) + [userScore]
        
        do {
            
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userScoreArray)
            let userDefaults  = UserDefaults.standard
            userDefaults.set(encodedData, forKey: level.key())
            
        } catch {
            print("Couldn`t encode given [Userscore] into data with error: \(error.localizedDescription)")
        }
    }
    
    static func getAllUserScores(level: Level) -> [UserScore] {
        var result: [UserScore] = []
        
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: level.key())
            as? Data {
            do {
                
                let decoder = JSONDecoder()
                result = try decoder.decode([UserScore].self, from: data)
                
            } catch {
                print("Couldn`t decode given data to [Userscore] with error: \(error.localizedDescription)")
            
            }
        }
        
        
        return result
    }
    
    func saveUserScore(name: String) {
        let userScore: [String: Any] = ["name": name, "score": dataModel.score]
        let userScoreArray: [[String: Any]] = getUserScoreArray() + [userScore]
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(userScoreArray, forKey: ViewControllerDataModel.userScoreArray)
    }
    
    func getUserScoreArray() -> [[String: Any]] {
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: ViewControllerDataModel.userScoreArray) as? [[String: Any]]
        return array ?? []
    }
}

struct ViewControllerDataModel {
    var timer: Timer?
    var countDown:Int = 30
    var result: Double?
    var score:Int = 0
    let ranges = [0...9, 10...99, 100...999]
    var scoreAmount = [1, 2, 3]
    
    var navigationBarPreviousTintColor: UIColor?
    
    static let userScoreArray: String = "userScore"
}

struct UserScore: Codable {
    let name: String
    let score: Int
}

enum Level {
    case easy
    case medium
    case hard
    
    func key() -> String {
        switch self {
        case .easy:
            return "easyUserScore"
        case .medium:
            return "mediumUserScore"
        case .hard:
            return "hardUserScore"
        }
    }
}
