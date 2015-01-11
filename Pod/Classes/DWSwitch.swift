import UIKit
import QuartzCore

@objc class DWSwitch: UIControl {
    
    var on: Bool {
        get {
            return switchValue
        }
        set {
            switchValue = newValue
            self.setOn(newValue, animated: false)
        }
    }
    
    var activeColor: UIColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1) {
        willSet {
            if self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }
    
    var inactiveColor: UIColor = UIColor.clearColor() {
        willSet {
            if !self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }
    
    var onTintColor: UIColor = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1) {
        willSet {
            if self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
                backgroundView.layer.borderColor = newValue.CGColor
            }
        }
    }
    
    var borderColor: UIColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1) {
        willSet {
            if !self.on {
                backgroundView.layer.borderColor = newValue.CGColor
            }
        }
    }
    
    var thumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            if !userDidSpecifyOnThumbTintColor {
                onThumbTintColor = newValue
            }
            if (!userDidSpecifyOnThumbTintColor || !self.on) && !self.tracking {
                thumbView.backgroundColor = newValue
            }
        }
    }
    
    var onThumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            userDidSpecifyOnThumbTintColor = true
            if self.on && !self.tracking {
                thumbView.backgroundColor = newValue
            }
        }
    }
    
    var shadowColor: UIColor = UIColor.grayColor() {
        willSet {
            thumbView.layer.shadowColor = newValue.CGColor
        }
    }
    
    var isRounded: Bool = true {
        willSet {
            if newValue {
                backgroundView.layer.cornerRadius = self.frame.size.height * 0.5
                thumbView.layer.cornerRadius = (self.frame.size.height * 0.5) - 1
            }
            else {
                backgroundView.layer.cornerRadius = 2
                thumbView.layer.cornerRadius = 2
            }
            
            thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).CGPath
        }
    }
    
    var thumbImage: UIImage! {
        willSet {
            thumbImageView.image = newValue
        }
    }
    
    var onImage: UIImage! {
        willSet {
            onImageView.image = newValue
        }
    }
    
    var offImage: UIImage! {
        willSet {
            offImageView.image = newValue
        }
    }
    
    // private
    var backgroundView: UIView!
    var thumbView: UIView!
    var onImageView: UIImageView!
    var offImageView: UIImageView!
    var thumbImageView: UIImageView!
    var currentVisualValue: Bool = false
    var startTrackingValue: Bool = false
    var didChangeWhileTracking: Bool = false
    var isAnimating: Bool = false
    var userDidSpecifyOnThumbTintColor: Bool = false
    var switchValue: Bool = false
    
    /*
    *   Initialization
    */
    override init() {
        super.init(frame: CGRectMake(0, 0, 50, 30))
        
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        let initialFrame = CGRectIsEmpty(frame) ? CGRectMake(0, 0, 50, 30) : frame
        super.init(frame: initialFrame)
        
        self.setup()
    }
    
    
    func setup() {
        
        // background
        self.backgroundView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        backgroundView.backgroundColor = UIColor.clearColor()
        backgroundView.layer.cornerRadius = self.frame.size.height * 0.5
        backgroundView.layer.borderColor = self.borderColor.CGColor
        backgroundView.layer.borderWidth = 1.0
        backgroundView.userInteractionEnabled = false
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        // on/off images
        self.onImageView = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        onImageView.alpha = 1.0
        onImageView.contentMode = UIViewContentMode.Center
        backgroundView.addSubview(onImageView)
        
        self.offImageView = UIImageView(frame: CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        offImageView.alpha = 1.0
        offImageView.contentMode = UIViewContentMode.Center
        backgroundView.addSubview(offImageView)
        
        // thumb
        self.thumbView = UIView(frame: CGRectMake(1, 1, self.frame.size.height - 2, self.frame.size.height - 2))
        thumbView.backgroundColor = self.thumbTintColor
        thumbView.layer.cornerRadius = (self.frame.size.height * 0.5) - 1
        thumbView.layer.shadowColor = self.shadowColor.CGColor
        thumbView.layer.shadowRadius = 2.0
        thumbView.layer.shadowOpacity = 0.5
        thumbView.layer.shadowOffset = CGSizeMake(0, 3)
        thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).CGPath
        thumbView.layer.masksToBounds = false
        thumbView.userInteractionEnabled = false
        self.addSubview(thumbView)
        
        // thumb image
        self.thumbImageView = UIImageView(frame: CGRectMake(0, 0, thumbView.frame.size.width, thumbView.frame.size.height))
        thumbImageView.contentMode = UIViewContentMode.Center
        thumbImageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        thumbView.addSubview(thumbImageView)
        
        self.on = false
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        startTrackingValue = self.on
        didChangeWhileTracking = false
        
        let activeKnobWidth = self.bounds.size.height - 2 + 5
        isAnimating = true
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
            if self.on {
                self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                self.backgroundView.backgroundColor = self.onTintColor
                self.thumbView.backgroundColor = self.onThumbTintColor
            }
            else {
                self.thumbView.frame = CGRectMake(self.thumbView.frame.origin.x, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                self.backgroundView.backgroundColor = self.activeColor
                self.thumbView.backgroundColor = self.thumbTintColor
            }
            }, completion: { finished in
                self.isAnimating = false
        })
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        // Get touch location
        let lastPoint = touch.locationInView(self)
        
        // update the switch to the correct visuals depending on if
        // they moved their touch to the right or left side of the switch
        if lastPoint.x > self.bounds.size.width * 0.5 {
            self.showOn(true)
            if !startTrackingValue {
                didChangeWhileTracking = true
            }
        }
        else {
            self.showOff(true)
            if startTrackingValue {
                didChangeWhileTracking = true
            }
        }
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        super.endTrackingWithTouch(touch, withEvent: event)
        
        let previousValue = self.on
        
        if didChangeWhileTracking {
            self.setOn(currentVisualValue, animated: true)
        }
        else {
            self.setOn(!self.on, animated: true)
        }
        
        if previousValue != self.on {
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        
        // just animate back to the original value
        if self.on {
            self.showOn(true)
        }
        else {
            self.showOff(true)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isAnimating {
            let frame = self.frame
            
            // background
            backgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
            backgroundView.layer.cornerRadius = self.isRounded ? frame.size.height * 0.5 : 2
            
            // images
            onImageView.frame = CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)
            offImageView.frame = CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)
            
            // thumb
            let normalKnobWidth = frame.size.height - 2
            if self.on {
                thumbView.frame = CGRectMake(frame.size.width - (normalKnobWidth + 1), 1, frame.size.height - 2, normalKnobWidth)
            }
            else {
                thumbView.frame = CGRectMake(1, 1, normalKnobWidth, normalKnobWidth)
            }
            
            thumbView.layer.cornerRadius = self.isRounded ? (frame.size.height * 0.5) - 1 : 2
        }
    }
    
    func setOn(isOn: Bool, animated: Bool) {
        switchValue = isOn
        
        if on {
            self.showOn(animated)
        }
        else {
            self.showOff(animated)
        }
    }
    
    func isOn() -> Bool {
        return self.on
    }
    
    func showOn(animated: Bool) {
        let normalKnobWidth = self.bounds.size.height - 2
        let activeKnobWidth = normalKnobWidth + 5
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
                if self.tracking {
                    self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                }
                else {
                    self.thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height)
                }
                
                self.backgroundView.backgroundColor = self.onTintColor
                self.backgroundView.layer.borderColor = self.onTintColor.CGColor
                self.thumbView.backgroundColor = self.onThumbTintColor
                self.onImageView.alpha = 1.0
                self.playBounceAnimation(self.onImageView)
                self.offImageView.alpha = 0
                }, completion: { finished in
                    
                    self.isAnimating = false
            })
        }
        else {
            if self.tracking {
                thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), thumbView.frame.origin.y, activeKnobWidth, thumbView.frame.size.height)
            }
            else {
                thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), thumbView.frame.origin.y, normalKnobWidth, thumbView.frame.size.height)
            }
            
            backgroundView.backgroundColor = self.onTintColor
            backgroundView.layer.borderColor = self.onTintColor.CGColor
            thumbView.backgroundColor = self.onThumbTintColor
            onImageView.alpha = 1.0
            
            offImageView.alpha = 0
        }
        
        currentVisualValue = true
    }
    
    func showOff(animated: Bool) {
        let normalKnobWidth = self.bounds.size.height - 2
        let activeKnobWidth = normalKnobWidth + 5
        
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
                if self.tracking {
                    self.thumbView.frame = CGRectMake(1, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
                    self.backgroundView.backgroundColor = self.activeColor
                }
                else {
                    self.thumbView.frame = CGRectMake(1, self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
                    self.backgroundView.backgroundColor = self.inactiveColor
                }
                
                self.backgroundView.layer.borderColor = self.borderColor.CGColor
                self.thumbView.backgroundColor = self.thumbTintColor
                self.onImageView.alpha = 0
                self.offImageView.alpha = 1.0
                self.playRoatationAnimation(self.offImageView)
                
                }, completion: { finished in
                    self.isAnimating = false
            })
        }
        else {
            if (self.tracking) {
                thumbView.frame = CGRectMake(1, thumbView.frame.origin.y, activeKnobWidth, thumbView.frame.size.height)
                backgroundView.backgroundColor = self.activeColor
            }
            else {
                thumbView.frame = CGRectMake(1, thumbView.frame.origin.y, normalKnobWidth, thumbView.frame.size.height)
                backgroundView.backgroundColor = self.inactiveColor
            }
            backgroundView.layer.borderColor = self.borderColor.CGColor
            thumbView.backgroundColor = self.thumbTintColor
            onImageView.alpha = 0
            offImageView.alpha = 1.0
        }
        
        currentVisualValue = false
    }
    
    func playBounceAnimation(icon : UIImageView) {
        
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = NSTimeInterval(1)
        bounceAnimation.calculationMode = kCAAnimationCubic
        
        icon.layer.addAnimation(bounceAnimation, forKey: "bounceAnimation")
        
        let renderImage = icon.image?.imageWithRenderingMode(.AlwaysTemplate)
        icon.image = renderImage
        icon.tintColor = UIColor.whiteColor()
    }
    
    func playRoatationAnimation(icon : UIImageView) {

        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        
        var toValue = CGFloat(M_PI * 2.0)
        toValue = toValue * -1.0
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = NSTimeInterval(0.5)
        
        icon.layer.addAnimation(rotateAnimation, forKey: "rotation360")
        
        let renderImage = icon.image?.imageWithRenderingMode(.AlwaysTemplate)
        icon.image = renderImage
        icon.tintColor = UIColor.grayColor()
    }
    
}
