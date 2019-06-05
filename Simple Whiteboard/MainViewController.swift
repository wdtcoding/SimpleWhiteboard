//
//  MainViewController.swift
//  Simple Whiteboard
//
//  Created by CARSON LI on 2019-05-02.
//  Copyright © 2019 WDT Coding. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var drawImageView: UIImageView!
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    
    @IBOutlet weak var greenColorButton: UIButton!
    @IBOutlet weak var blackColorButton: UIButton!
    @IBOutlet weak var blueColorButton: UIButton!
    @IBOutlet weak var eraserColorButton: UIButton!
    
    @IBOutlet weak var brushWidthLabel: UILabel!
    
    var mouseSwiped : Bool = false
    var lastPoint : CGPoint!
    
    var brushWidth : Int = 1
    var eraserBrushWidth : Int = 20
    
    var redValue : CGFloat = 0
    var blueValue : CGFloat = 0
    var greenValue : CGFloat = 0
    
    var maxBrushValue : Int = 10
    var minBrushValue : Int = 1
    var activeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activeButton = self.blackColorButton
        self.brushWidth = UserDefaults.standard.integer(forKey: "defaultWidth")
        if (self.brushWidth == 0 ){
            self.brushWidth = 1
        }
        
        self.updateWidthInfo()
        self.updateColorsAndButtons(redValue: 0.0, greenValue: 0.0, blueValue: 0.0)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.mouseSwiped = false
        if let touchPoint = touches.first {
            self.lastPoint = touchPoint.location(in: self.drawImageView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.mouseSwiped = true
        guard let touchPoint = touches.first else {
            print("Unable to obtain touch point, error")
            return
        }
        
        let currentPoint = touchPoint.location(in: self.drawImageView)
        self.updateDrawImageView(currentPoint: currentPoint)
        self.lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.mouseSwiped == false){
            self.updateDrawImageView(currentPoint: nil)
        }
    }
    
    private func updateDrawImageView (currentPoint: CGPoint?)
    {
        UIGraphicsBeginImageContextWithOptions(self.drawImageView.frame.size, false, 0.0)
        //UIGraphicsBeginImageContext(self.drawImageView.frame.size)
        self.drawImageView.image?.draw(in: CGRect.init(x: 0, y: 0, width: self.drawImageView.frame.size.width, height: self.drawImageView.frame.size.height))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(CGLineCap.round)
            context.setAllowsAntialiasing(true)
            context.setLineWidth(CGFloat(integerLiteral: self.activeButton == self.eraserColorButton ? self.eraserBrushWidth : self.brushWidth))
            context.setStrokeColor(red: self.redValue, green: self.greenValue, blue: self.blueValue, alpha: 1.0)
            context.setBlendMode(CGBlendMode.normal)
            
            context.beginPath()
            context.move(to: CGPoint(x: self.lastPoint.x, y: self.lastPoint.y))
            
            if let newPoint = currentPoint {
                context.addLine(to: CGPoint(x: newPoint.x, y: newPoint.y))
            }
            else{
                context.addLine(to: CGPoint(x: self.lastPoint.x, y: self.lastPoint.y))
            }
            
            context.strokePath()
            context.flush()
        }
        
        self.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    @IBAction func subtractButtonPressed(_ sender: Any) {
        if self.brushWidth != self.minBrushValue {
            self.brushWidth -= 1
            self.updateWidthInfo()
        }
    }

    @IBAction func increaseButtonPressed(_ sender: Any) {
        if self.brushWidth != self.maxBrushValue {
            self.brushWidth += 1
            self.updateWidthInfo()
        }
    }
    
    private func updateWidthInfo() {
        self.brushWidthLabel.text = String(format: "%d",self.brushWidth)
        UserDefaults.standard.set(self.brushWidth, forKey: "defaultWidth")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func blackColorPressed(_ sender: Any) {
        self.activeButton = self.blackColorButton
        self.updateColorsAndButtons(redValue: 0.0, greenValue: 0.0, blueValue: 0.0)
    }
    
    @IBAction func greenColorPressed(_ sender: Any) {
        self.activeButton = self.greenColorButton
        self.updateColorsAndButtons(redValue: 35.0/255.0, greenValue: 165.0/255.0, blueValue: 80.0/255.0)
    }
    
    @IBAction func blueColorPressed(_ sender: Any) {
        self.activeButton = self.blueColorButton
        self.updateColorsAndButtons(redValue: 0.0/255.0, greenValue: 122.0/255.0, blueValue: 255.0/255.0)
    }
    
    @IBAction func eraserButtonPressed(_ sender: Any) {
        self.activeButton = self.eraserColorButton
        self.updateColorsAndButtons(redValue: 1, greenValue: 1, blueValue: 1)
    }
    
    private func updateColorsAndButtons(redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat){
        self.redValue = redValue
        self.greenValue = greenValue
        self.blueValue = blueValue
        let buttons = [self.blackColorButton, self.blueColorButton, self.greenColorButton]
        for button in buttons {
            button?.layer.borderWidth = self.activeButton == button ? 3.0 : 0.0
            button?.layer.borderColor = UIColor.orange.cgColor
            button?.layer.cornerRadius = 2.5
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        let dialog = UIAlertController(title: "Confirm", message: "Clear the screen?", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.drawImageView.image = nil
        })
        let noButton = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in}
    
        dialog.addAction(yesButton)
        dialog.addAction(noButton)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let image = self.drawImageView.image{
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else{
            self.presentSingleOptionDialog(title: "Hey!", message: "Draw something first ;)", actionMessage: "OK")
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.presentSingleOptionDialog(title: "Error", message: error.localizedDescription, actionMessage: "OK")
        } else {
            self.presentSingleOptionDialog(title: "Saved", message: "You did it!", actionMessage: "OK")
        }
    }
    
    private func presentSingleOptionDialog(title:String!, message: String!, actionMessage: String!) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionMessage, style: .default))
        present(ac, animated: true)
    }
}
