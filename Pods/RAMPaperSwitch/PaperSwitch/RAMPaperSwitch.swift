//  RAMPaperSwitch.swift
//
// Copyright (c) 26/11/14 Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public class RAMPaperSwitch: UISwitch, CAAnimationDelegate {
    
    @IBInspectable var duration: Double = 0.35
    
    var animationDidStartClosure = {(onAnimation: Bool) -> Void in }
    var animationDidStopClosure = {(onAnimation: Bool, finished: Bool) -> Void in }
    
    private var shape: CAShapeLayer! = CAShapeLayer()
    private var radius: CGFloat = 0.0
    private var oldState = false
  
    private let defaultTintColor = UIColor.greenColor()
  
    override public var on: Bool {
        didSet(oldValue) {
            oldState = on
        }
    }
  
    override public func setOn(on: Bool, animated: Bool) {
        let changed:Bool = on != self.on
        
        super.setOn(on, animated: animated)
        
        if changed {
            if animated {
                switchChanged()
            } else {
                showShapeIfNeed()
            }
        }
    }
    
    
    // MARK: - Initialization

    
    public required init(view: UIView?, color: UIColor?) {
        super.init(frame: CGRectZero)
        onTintColor = color
        self.commonInit(view)
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override public func awakeFromNib() {
        self.commonInit(superview)
        super.awakeFromNib()
    }
    
    
    private func commonInit(parentView: UIView?) {
        let shapeColor: UIColor = onTintColor ?? defaultTintColor
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.whiteColor().CGColor;
        layer.cornerRadius = frame.size.height / 2;
        
        shape.fillColor = shapeColor.CGColor
        shape.masksToBounds = true
        
        parentView?.layer.insertSublayer(shape, atIndex: 0)
        parentView?.layer.masksToBounds = true
        
        showShapeIfNeed()
        
        addTarget(self, action: "switchChanged", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    override public func layoutSubviews() {
        let x:CGFloat = max(frame.midX, superview!.frame.size.width - frame.midX);
        let y:CGFloat = max(frame.midY, superview!.frame.size.height - frame.midY);
        radius = sqrt(x*x + y*y);
        
        shape.frame = CGRectMake(frame.midX - radius,  frame.midY - radius, radius * 2, radius * 2)
        shape.anchorPoint = CGPointMake(0.5, 0.5);
        shape.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, radius * 2, radius * 2)).CGPath
    }
  
    // MARK: - Private
    
    private func showShapeIfNeed() {
        shape.transform = on ? CATransform3DMakeScale(1.0, 1.0, 1.0) : CATransform3DMakeScale(0.0001, 0.0001, 0.0001)
    }

    
    internal func switchChanged() {
        if on == oldState {
            return;
        }
        oldState = on
     
      let shapeColor: UIColor = onTintColor ?? defaultTintColor
      shape.fillColor = shapeColor.CGColor
      
        if on {
            CATransaction.begin()
            
            shape.removeAnimationForKey("scaleDown")
            
            let scaleAnimation:CABasicAnimation  = animateKeyPath("transform",
                fromValue: NSValue(CATransform3D: CATransform3DMakeScale(0.0001, 0.0001, 0.0001)),
                toValue:NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
                timing:kCAMediaTimingFunctionEaseIn);
            
            shape.addAnimation(scaleAnimation, forKey: "scaleUp")
            
            CATransaction.commit();
        }
        else {
            CATransaction.begin()
            shape.removeAnimationForKey("scaleUp")
            
            let scaleAnimation:CABasicAnimation  = animateKeyPath("transform",
                fromValue: NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
                toValue:NSValue(CATransform3D: CATransform3DMakeScale(0.0001, 0.0001, 0.0001)),
                timing:kCAMediaTimingFunctionEaseOut);
                
            shape.addAnimation(scaleAnimation, forKey: "scaleDown")
            
            CATransaction.commit();
        }
    }
    
    
    private func animateKeyPath(keyPath: String, fromValue from: AnyObject, toValue to: AnyObject, timing timingFunction: String) -> CABasicAnimation {
    
        let animation:CABasicAnimation = CABasicAnimation(keyPath: keyPath)
        
        animation.fromValue = from
        animation.toValue = to
        animation.repeatCount = 1
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.duration = duration;
        animation.delegate = self
        
        return animation;
    }
    
    //MARK: - CAAnimation Delegate

    
    public func animationDidStart(anim: CAAnimation){
        animationDidStartClosure(on)
    }
    
    
    public func animationDidStop(anim: CAAnimation, finished flag: Bool){
        animationDidStopClosure(on, flag)
    }
}
