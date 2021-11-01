//
//  RecordButton.swift
//  ButtonRecording
//
//  Created by Truc Pham on 30/10/2021.
//

import Foundation
import UIKit

@objc protocol RecordButtonDelegate {
    @objc optional func recordButton(press button : RecordButton)
    @objc optional func recordButton(longPress button : RecordButton)
    @objc optional func recordButton(_ button : RecordButton, valueChange value : CGFloat)
    @objc optional func recordButton(endPress button : RecordButton)
}

@objc enum RecordButtonState : Int {
    case recording, idle, hidden
}

class RecordButton : UIButton {
    private var progressTimer : Timer!
    private var holdTimer: Timer!
    private var isHolding : Bool = false
    weak var delegate : RecordButtonDelegate?
    var maxDurationSecond = CGFloat(5)
    var stepSecond = CGFloat(0.05)
    var buttonColor: UIColor! = .white {
        didSet {
            circleLayer.backgroundColor = buttonColor.cgColor
            circleBorder.borderColor = buttonColor.cgColor
        }
    }
    var progressFillColor : UIColor = .white
    var progressColor: UIColor = .red {
        didSet {
            gradientMaskLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    
    var closeWhenFinished: Bool = false
    
    var buttonState : RecordButtonState = .idle {
        didSet {
            switch buttonState {
            case .idle:
                self.alpha = 1.0
                currentProgress = 0
                setProgress(0)
                setRecording(false)
            case .recording:
                self.alpha = 1.0
                setRecording(true)
            case .hidden:
                self.alpha = 0
            }
        }
        
    }
    
    fileprivate var circleLayer: CALayer!
    fileprivate var circleBorder: CALayer!
    fileprivate var progressLayer: CAShapeLayer!
    fileprivate var gradientMaskLayer: CAGradientLayer!
    var currentProgress: CGFloat = 0
    
    override  init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareUI()
    }
    
    private func prepareUI(){
        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpOutside)
        self.drawButton()
    }
    
    
    fileprivate func drawButton() {
        
        self.backgroundColor = UIColor.clear
        let layer = self.layer
        circleLayer = CALayer()
        circleLayer.backgroundColor = buttonColor.cgColor
        
        let size: CGFloat = self.frame.size.width / 1.3
        circleLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleLayer.cornerRadius = size / 2
        layer.insertSublayer(circleLayer, at: 0)
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 3
        circleBorder.borderColor = buttonColor.cgColor
        circleBorder.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width - 1.5, height: self.bounds.size.height - 1.5)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)
        
        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi/2)
        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi/2)
        let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        gradientMaskLayer = self.gradientMask()
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 2, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = 3.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        gradientMaskLayer.mask = progressLayer
        layer.addSublayer(gradientMaskLayer)
    }
    
    fileprivate func setRecording(_ recording: Bool) {
        
        let duration: TimeInterval = 0.15
        circleLayer.contentsGravity = CALayerContentsGravity(rawValue: "center")
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1.0 : 0.88
        scale.toValue = recording ? 0.88 : 1
        scale.duration = duration
        scale.fillMode = CAMediaTimingFillMode.forwards
        scale.isRemovedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = CAMediaTimingFillMode.forwards
        color.isRemovedOnCompletion = false
        color.toValue = recording ? progressColor.cgColor : buttonColor.cgColor
        
        let circleAnimations = CAAnimationGroup()
        circleAnimations.isRemovedOnCompletion = false
        circleAnimations.fillMode = CAMediaTimingFillMode.forwards
        circleAnimations.duration = duration
        circleAnimations.animations = [scale, color]
        
        let borderColor: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColor.duration = duration
        borderColor.fillMode = CAMediaTimingFillMode.forwards
        borderColor.isRemovedOnCompletion = false
        borderColor.toValue = recording ? progressFillColor.cgColor : buttonColor
        
        //        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        //        borderScale.fromValue = recording ? 1.0 : 0.88
        //        borderScale.toValue = recording ? 0.88 : 1.0
        //        borderScale.duration = duration
        //        borderScale.fillMode = CAMediaTimingFillMode.forwards
        //        borderScale.isRemovedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.isRemovedOnCompletion = false
        borderAnimations.fillMode = CAMediaTimingFillMode.forwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderColor]
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = recording ? 0.0 : 1.0
        fade.toValue = recording ? 1.0 : 0.0
        fade.duration = duration
        fade.fillMode = CAMediaTimingFillMode.forwards
        fade.isRemovedOnCompletion = false
        
        circleLayer.add(circleAnimations, forKey: "circleAnimations")
        progressLayer.add(fade, forKey: "fade")
        circleBorder.add(borderAnimations, forKey: "borderAnimations")
    }
    
    fileprivate func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
        let topColor = progressColor
        let bottomColor = progressColor
        gradientLayer.colors = [topColor.cgColor as Any, bottomColor.cgColor as Any]
        return gradientLayer
    }
    
    override func layoutSubviews() {
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        super.layoutSubviews()
    }
    
    
    @objc private func didTouchDown(){
        holdTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startRecord), userInfo: nil, repeats: false)
    }
    
    
    @objc private func didTouchUp() {
        self.holdTimer.invalidate()
        if isHolding { endRecord() }
        else { buttonPress() }
       
    }
    
    func buttonPress(){
        self.delegate?.recordButton?(press: self)
    }
    
    @objc private func startRecord(){
        isHolding = true
        self.buttonState = .recording
        self.progressTimer = Timer.scheduledTimer(timeInterval: stepSecond, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        self.delegate?.recordButton?(longPress: self)
    }
    
    private func endRecord(){
        isHolding = false
        self.setProgress(0)
        self.buttonState = .idle
        self.progressTimer.invalidate()
        currentProgress = 0
        self.delegate?.recordButton?(endPress: self)
    }
    
    @objc private func updateProgress() {
        let value = currentProgress + ( stepSecond / maxDurationSecond)
        self.setProgress(value)
        if currentProgress >= 1 {
            if(closeWhenFinished) { stop() }
            else { progressTimer.invalidate() }
        }
    }

    func setProgress(_ newProgress: CGFloat) {
        currentProgress = newProgress
        progressLayer.strokeEnd = newProgress
        self.delegate?.recordButton?(self, valueChange: newProgress)
    }
    
    deinit {
        self.progressTimer?.invalidate()
        self.progressTimer = nil
        self.holdTimer.invalidate()
        self.holdTimer = nil
    }
    
}
