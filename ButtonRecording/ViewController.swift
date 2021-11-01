//
//  ViewController.swift
//  ButtonRecording
//
//  Created by Truc Pham on 30/10/2021.
//

import UIKit

class ViewController: UIViewController {
    let recordButton = RecordButton(frame: CGRect(x: 0,y: 0,width: 70,height: 70))
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // set up recorder button
        self.view.backgroundColor = .black
        recordButton.center = self.view.center
        recordButton.progressColor = .red
        recordButton.closeWhenFinished = true
        recordButton.progressFillColor = .darkGray
        recordButton.maxDurationSecond = 30
        recordButton.delegate = self
        recordButton.center.x = self.view.center.x
        view.addSubview(recordButton)
    }
    
}
extension ViewController : RecordButtonDelegate {
    func recordButton(press button: RecordButton) {
        print("Press")
    }
    func recordButton(endPress button: RecordButton) {
        print("endPress")
    }
    func recordButton(longPress button: RecordButton) {
        print("longPress")
    }
    func recordButton(_ button: RecordButton, valueChange value: CGFloat) {
        print(value)
    }
}
