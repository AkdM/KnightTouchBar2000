//
//  ToucharBarController.swift
//  KnightTouchBar2000
//
//  Created by Anthony Da Mota on 08/11/2016.
//  Copyright © 2016 Anthony Da Mota. All rights reserved.
//

import Cocoa

fileprivate extension NSTouchBarCustomizationIdentifier {
    
    static let knightTouchBar = NSTouchBarCustomizationIdentifier("com.AnthonyDaMota.KnightTouchBar2000")
}

fileprivate extension NSTouchBarItemIdentifier {
    static let knightRider = NSTouchBarItemIdentifier("knightRider")
}

@available(OSX 10.12.1, *)
class TouchBarController: NSWindowController, NSTouchBarDelegate, CAAnimationDelegate {
    
    let theKnightView = NSView()

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier.knightTouchBar
        touchBar.defaultItemIdentifiers = [.knightRider]
        touchBar.customizationAllowedItemIdentifiers = [.knightRider]
        
        return touchBar
        
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        
        let wholeTouchBar = NSCustomTouchBarItem(identifier: identifier)
        
        switch identifier {
        case NSTouchBarItemIdentifier.knightRider:

            self.theKnightView.wantsLayer = true
            let theLEDs = CAShapeLayer()
            
            var between: Double = 12.5
            for item in 0...86 {
                let aLEDLeft = createLED(x: between+(2.5*Double(item)), y: 7.5, width: 12.5, height: 15, xRadius: 2.0, yRadius: 2.0)
                let aLEDRight = createLED(x: between+(2.5*Double(item)), y: 7.5, width: 12.5, height: 15, xRadius: 2.0, yRadius: 2.0)
                theLEDs.addSublayer(aLEDLeft)
                theLEDs.addSublayer(aLEDRight)
                
                let theLEDAnimLeft = createAnim(
                    duration: 2,
                    delay: CACurrentMediaTime() + 0.023255814*Double(item),
                    values: [0, 1, 0.00001, 0.0002, 0],
                    keyTimes: [0, 0.125, 0.25, 0.375, 1],
                    reverses: false)

                aLEDLeft.add(theLEDAnimLeft, forKey: "opacity")
                
                let theLEDAnimRight = createAnim(
                    duration: 2,
                    delay: 1+(CACurrentMediaTime() + 0.023255814*Double(43-item)),
                    values: [0, 1, 0.00001, 0.0002, 0],
                    keyTimes: [0, 0.125, 0.25, 0.375, 1],
                    reverses: false)

                aLEDRight.add(theLEDAnimRight, forKey: "opacity")
                
                between += 12.5
            }
            
            theKnightView.layer?.addSublayer(theLEDs)
            wholeTouchBar.view = theKnightView
            
            return wholeTouchBar
        default:
            return nil
        }
    }
    
    func createLED(x: Double, y: Double, width: Double, height: Double, xRadius: CGFloat, yRadius: CGFloat) -> CAShapeLayer {
        let aLED = CAShapeLayer()
        // LED shape
        let aLEDRect = CGRect(x: x, y: y, width: width, height: height)
        aLED.path = NSBezierPath(roundedRect: aLEDRect, xRadius: xRadius, yRadius: yRadius).cgPath
        aLED.opacity = 0
        aLED.fillColor = NSColor.red.cgColor
        
        // LED color glow
        aLED.shadowColor = NSColor.red.cgColor
        aLED.shadowOffset = CGSize.zero
        aLED.shadowRadius = 6.0
        aLED.shadowOpacity = 1.0
        
        return aLED
    }
    
    func createAnim(duration: CFTimeInterval, delay: CFTimeInterval, values: [NSNumber], keyTimes: [NSNumber], reverses: Bool) -> CAKeyframeAnimation {
        let theLEDAnim = CAKeyframeAnimation(keyPath: "opacity")
        theLEDAnim.duration = duration
        theLEDAnim.beginTime = delay
        theLEDAnim.values = values
        theLEDAnim.keyTimes = keyTimes
        theLEDAnim.autoreverses = reverses
        theLEDAnim.repeatCount = .infinity
        theLEDAnim.delegate = self
        
        return theLEDAnim
    }
}

// Apple puts that code in the docs instead of just adding a CGPath accessor to NSBezierPath
// From: http://stackoverflow.com/questions/1815568/how-can-i-convert-nsbezierpath-to-cgpath/39385101#39385101
extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement:
                path.move(to: points[0])
            case .lineToBezierPathElement:
                path.addLine(to: points[0])
            case .curveToBezierPathElement:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement:
                path.closeSubpath()
            }
        }
        
        return path
    }
}
