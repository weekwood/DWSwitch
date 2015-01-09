//
//  ViewController.swift
//  DWSwitchDemo
//
//  Created by di wu on 1/6/15.
//  Copyright (c) 2015 di wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var ibSwitch: DWAnimationSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mySwitch1 = DWAnimationSwitch(frame: CGRectMake(0, 0, 100, 50))
        mySwitch1.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5 - 80)
        mySwitch1.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
        mySwitch1.offImage = UIImage(named: "cross")
        mySwitch1.onImage = UIImage(named: "check")
        mySwitch1.onTintColor = UIColor.blueColor()
        mySwitch1.isRounded = false;
        self.view.addSubview(mySwitch1)
    }
    func switchChanged(sender: DWAnimationSwitch) {
        println("Changed value to: \(sender.on)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

