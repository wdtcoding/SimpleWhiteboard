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
    var eraserEnabled : Bool = false
    var lastPoint : CGPoint!
    
    var brushWidth : Int = 1
    var eraserBrushWidth : Int = 20
    var redValue : CGFloat = 0
    var blueValue : CGFloat = 0
    var greenValue : CGFloat = 0
    
    var maxBrushValue : Int = 10
    var minBrushValue : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        UIGraphicsBeginImageContext(self.drawImageView.frame.size)
        self.drawImageView.image?.draw(in: CGRect.init(x: 0, y: 0, width: self.drawImageView.frame.size.width, height: self.drawImageView.frame.size.height))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(CGLineCap.round)
            context.setLineWidth(CGFloat(integerLiteral: self.eraserEnabled ? self.eraserBrushWidth : self.brushWidth))
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
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        self.drawImageView.image = nil
    }
    
    @IBAction func subtractButtonPressed(_ sender: Any) {
        if self.brushWidth != self.minBrushValue {
            self.brushWidth -= 1
            self.brushWidthLabel.text = String(format: "%d",self.brushWidth)
        }
    }

    @IBAction func increaseButtonPressed(_ sender: Any) {
        if self.brushWidth != self.maxBrushValue {
            self.brushWidth += 1
            self.brushWidthLabel.text = String(format: "%d",self.brushWidth)
        }
    }
    
    @IBAction func blackColorPressed(_ sender: Any) {
        self.eraserEnabled = false
        self.redValue = 0.0
        self.greenValue = 0.0
        self.blueValue = 0.0
    }
    
    @IBAction func greenColorPressed(_ sender: Any) {
        self.eraserEnabled = false
        self.redValue = 35.0 / 255.0
        self.greenValue = 165.0 / 255.0
        self.blueValue = 80.0 / 255.0
    }
    
    @IBAction func blueColorPressed(_ sender: Any) {
        self.eraserEnabled = false
        self.redValue = 0.0 / 255.0
        self.greenValue = 122.0 / 255.0
        self.blueValue = 255.0 / 255.0
    }
    
    @IBAction func eraserButtonPressed(_ sender: Any) {
        self.eraserEnabled = true
        self.redValue = 1
        self.greenValue = 1
        self.blueValue = 1
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let image = self.drawImageView.image{
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else{
            let ac = UIAlertController(title: "Hey!", message: "Draw something first ;)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved", message: "You did it!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
