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
    
    var timer: Timer?
    var countDown:Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateProblem()
        scheduleTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupUI() {
        timerContainerView.layer.cornerRadius = 5
        
    }

    func generateProblem() {
        let firstDigit = Int.random(in: 0...9)
        let secondDigit = Int.random(in: 0...9)
        let arithmeticOperator:String = ["+", "-", "x", "/"].randomElement()!
        
        problemLabel.text = "\(firstDigit) \(arithmeticOperator) \(secondDigit) ="
    }
    
    func scheduleTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimerUI() {
        countDown -= 1
        
        timerLabel.text = "00 : \(countDown)"
        progressView.progress = Float(30 - countDown) / 30
        
        if countDown <= 0 {
            timer?.invalidate()
        }
    }
}

