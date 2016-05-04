//
//  SwitchingViewController.swift
//  MySimon
//
//  Created by Janet Weber on 3/30/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//

import UIKit

class SwitchingViewController: UIViewController {
    private var gamePlayViewController: GamePlayViewController!
    private var instructionsViewController: InstructionsViewController!
    private var settingsViewController: SettingsViewController!

    private func switchViewController(from fromVC:UIViewController?, to toVC:UIViewController?) {
        if fromVC != nil {
            fromVC!.willMoveToParentViewController(nil)
            fromVC!.view.removeFromSuperview()
            fromVC!.removeFromParentViewController()
        }
        
        if toVC != nil {
            self.addChildViewController(toVC!)
            self.view.insertSubview(toVC!.view, atIndex: 0)
            toVC!.didMoveToParentViewController(self)
        }
    } // end of switchViewController functions
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gamePlayViewController = storyboard?.instantiateViewControllerWithIdentifier("Play") as! GamePlayViewController
        gamePlayViewController.view.frame = view.frame
        switchViewController(from: nil, to: gamePlayViewController)
    } // end of viewDidLoad()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if gamePlayViewController != nil && gamePlayViewController!.view.superview == nil {
            gamePlayViewController = nil
        }
        if settingsViewController != nil && settingsViewController!.view.superview == nil {
            settingsViewController = nil
        }
        if instructionsViewController != nil && instructionsViewController!.view.superview == nil {
            instructionsViewController = nil
        }
    } // end of didReceiveMemoryWarning()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func switchViews(sender: UIBarButtonItem) {
        // Create the new view controller, if required
        switch (sender.tag) {
        case 2: if settingsViewController?.view.superview == nil {
            if settingsViewController == nil {
                settingsViewController = storyboard?.instantiateViewControllerWithIdentifier("Settings") as! SettingsViewController
            }
        }
        case 3: if instructionsViewController?.view.superview == nil {
            if instructionsViewController == nil {
                instructionsViewController = storyboard?.instantiateViewControllerWithIdentifier("Instructions") as! InstructionsViewController
            }

        }
        default: if gamePlayViewController?.view.superview == nil {
            if gamePlayViewController == nil {
                gamePlayViewController = storyboard?.instantiateViewControllerWithIdentifier("Play") as! GamePlayViewController
            }
        }
        }
        
/*
        if settingsViewController?.view.superview == nil {
            if settingsViewController == nil {
                settingsViewController = storyboard?.instantiateViewControllerWithIdentifier("Settings") as! SettingsViewController
            }
        } else if instructionsViewController?.view.superview == nil {
            if instructionsViewController == nil {
                instructionsViewController = storyboard?.instantiateViewControllerWithIdentifier("Instructions") as! InstructionsViewController
            }
        }else if gamePlayViewController?.view.superview == nil {
            if gamePlayViewController == nil {
                gamePlayViewController = storyboard?.instantiateViewControllerWithIdentifier("Play") as! GamePlayViewController
            }
        }
*/
        
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationCurve(.EaseInOut)
        
        // Switch view controllers
        switch (sender.tag) {
        case 2: // settings tool bar button item pressed - switch view to settings
            UIView.setAnimationTransition(.CurlUp, forView: view, cache: true)
            settingsViewController.view.frame = view.frame
            if gamePlayViewController != nil && gamePlayViewController!.view.superview != nil {
                switchViewController(from: gamePlayViewController, to: settingsViewController)
            } else if instructionsViewController != nil && instructionsViewController!.view.superview != nil {
                switchViewController(from: instructionsViewController, to: settingsViewController)
            }
        case 3: // instructions tool bar button item pressed - switch view to instructions
            UIView.setAnimationTransition(.CurlDown, forView: view, cache: true)
            instructionsViewController.view.frame = view.frame
            if gamePlayViewController != nil && gamePlayViewController!.view.superview != nil {
                switchViewController(from: gamePlayViewController, to: instructionsViewController)
            } else if settingsViewController != nil && settingsViewController!.view.superview != nil {
                switchViewController(from: settingsViewController, to: instructionsViewController)
            }
        
        default: // play tool bar button item pressed - switch view to play (default view)
            UIView.setAnimationTransition(.FlipFromLeft, forView: view, cache: true)
            gamePlayViewController.view.frame = view.frame
            if instructionsViewController != nil && instructionsViewController!.view.superview != nil {
                switchViewController(from: instructionsViewController, to: gamePlayViewController)
            } else if settingsViewController != nil && settingsViewController!.view.superview != nil {
                switchViewController(from: settingsViewController, to: gamePlayViewController)
            }

        }
        
        UIView.commitAnimations()
        
    } // end of switchViews function

}
