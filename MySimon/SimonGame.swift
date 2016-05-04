//
//  SimonGame.swift
//  MySimon
//
//  Created by Janet Weber on 4/4/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//
// Mistake sound from:  http://www.freesound.org/people/Raccoonanimator/sounds/160907/
// Winning sound from: http://www.freesound.org/people/mojomills/sounds/167539/

import Foundation
import AVFoundation
import UIKit

// GLOBAL Variables
var timer = NSTimer?()              // Timer
var audioPlayer = AVAudioPlayer()   // Audio Player


class SimonGame {
    
    var viewController : GamePlayViewController!
    var playing : Bool              // Bool indicates playing (only true when it's time for 
                                    //   user to repeat sequence).
    var sequence : [Int]            // integer array containing correct sequence for round
    var indexMatched : Int          // current index up to which point user has matched
    var buttonTaps : Int            // count of button taps
    var roundCount : Int            // how many rounds has user played?
    var level : Int                 // what level is user currently playing?
    var levelThreshold : Int        // what is the level threshold?
    var matchesThisLevel : Int      // how many matches for user at this level?
    var userResp : [Int]
    
    let len = UInt32(4)             // constant for how many colors/tones are used in  the game
    let count = 25                  // Game length sequence limit
    
    // UIImage constants
    let redFrowny = UIImage(named: "redFrowny")
    let blueSurprise = UIImage(named:"blueSurprise")
    let blueSmiley = UIImage(named: "blueSmiley")
    let greenSmiley = UIImage(named: "greenSmiley")
    let blueDistressed = UIImage(named: "blueDistressed2")
    let yellowSmiley = UIImage(named: "yellowSmiley")
    
    init() {                    // instance initializer
        playing = false
        sequence = []
        indexMatched = 0
        buttonTaps = 0
        roundCount = 0
        level = 1
        levelThreshold = 15      // Should be 15 for real.  Other settings (4) for debugging.
        matchesThisLevel = 0
        userResp = []
    } // end of init()
    
    // **************************************************************************************************************
    // TIMER Functions
    // **************************************************************************************************************
    func startTookTooLong() {
        if timer == nil {                                       // This function starts a timer which will fire in
            timer = NSTimer.scheduledTimerWithTimeInterval(3,   // 3 seconds (the amount of time the user has to
                target:self,                                    // begin responding) if it's not invalidated before
                selector: #selector(SimonGame.tookTooLong),     // 3 seconds (see stopTookTooLong()).
                userInfo: nil, repeats: false)
        }
    }
    
    func stopTookTooLong() {        // This function stops or invalidates a timer.  Used
        if timer != nil {           // with above function for timing user response.
            timer!.invalidate()
            timer = nil
        }
    }
    
    @objc func tookTooLong() {      // This function is triggered if the timer ever fires
        stopTookTooLong()           // indicating the round is over.
        roundFinished(2)            // Stop the timer and call roundFinished() reason 2
    }
    
    // **************************************************************************************************************
    // DELAY(Double, closure) function (using dispatch_after)
    // Function waits the time specified in seconds (passed in as the Double) and then performs
    // the code passed in as the closure.
    // **************************************************************************************************************
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // **************************************************************************************************************
    // Functions used to display the current pattern
    //      highLightButton(Int)
    //      displayPatternSoFar(Int, Double)
    // **************************************************************************************************************
    func highlightButton(btag: Int) {               // The highlightButton(btag) function calls the
        let t = 0.25                                // 'highlight' function in GamePlayViewcontroller
        viewController.highlight(btag, flash: true) // passing the button tag (btag) and boolean (flash) that
        self.playTone(btag)                         // will set button highlight property initally to true.
        delay(t){                                   // Then after time "t" calls 'highlight' function again with 
            self.viewController.highlight(btag, flash: false) // button highlight property of false.
        }                                           // The appropriate button tone is played
    } // end of highlightButton()
    // *************************************************************************************************************
    func displayPatternSoFar(index: Int, wait: Double) { // Recursive function to highlight buttons in current sequence
        if (index > 0) {                                 // to be matched. The index argument is the index into the
            displayPatternSoFar(index-1, wait: wait-0.75)// sequence for this round that has been correctly matched
        }                                                // thus far.  The wait argument inserts a delay - otherwise it
                                                         // happens too fast to see. Calls itself from high to low index,
        let buttonTag = sequence[index]                  // then when at 0 begins highlighting as it returns back up the
        delay(wait) {self.highlightButton(buttonTag)}    // stack (from low to high).
    }
    // **************************************************************************************************************
    // Generate a random number (0 - num (4) of elements to be repeatd) count (25) times.
    // Use that random number as index into char set and append char
    // at that index to generated sequence string.
    // **************************************************************************************************************
    func generateSequence() -> Void {
        sequence = []
        
        // These used for debugging
//        sequence = [12,13,10,11]
//        self.sequence = [12,13,10,12,13,13,11,10]
//        self.sequence = [10,10,10,10,10,10,10,10]

        var randNum : Int                   // random number betw 0 and count of elements to be repeatd
        
        for _ in 0..<count  {                    // count (25) times
            randNum =
                Int(arc4random_uniform(len))+10  // generate random number (len is 4) and add 10
                                                 //    (button tags are 10,11,12,13)
            self.sequence.append(randNum)        // insert into sequence array
        }
    } // end of function generateSequence()

    // **************************************************************************************************************
    // startRound(Bool)
    // Function called at start of each round.  A new sequence is generated and variables/properties updated/reset
    // **************************************************************************************************************
    func startRound(first: Bool) {
        if (level <= 10) {                      // Check level property (>10 means game over)
            viewController.smiley.hidden = true // hide the smiley
            generateSequence()                  // generate the sequence to match
            indexMatched = 0                    // initialize game property tracking how many we've matched
            delay(1) {self.playNextSeq()}       // play the next sequence after 1 second
            
            viewController.messageLabel.text = "" // reset message label
            if (!first) {                         // update messageLabel2 with roundCount (if not first round)
                viewController.messageLabel2.text = "Play Next Round \(roundCount+1)"
                delay(1.5) {self.viewController.messageLabel2.text = ""}   // after 1.5 secs reset messageLabel2
            }
            viewController.matchesForRoundLabel.text = String(indexMatched)// update stats label
        }

    } // end of startRound() method

    // **************************************************************************************************************
    // reset(bool)
    // Function called to start a brand new game.  The boolean passed in indicates if this is called from viewDidLoad.
    // All game properties are reset for a fresh start.
    // **************************************************************************************************************
    func reset(first: Bool) {   // Reset all of the class properties (myGame)
        playing = false         // only true when time for user to repeat sequence
        sequence = []
        indexMatched = 0
        buttonTaps = 0
        roundCount = 0
        level = 1
        levelThreshold = 15      // Should be 15 for real.  Other settings for debugging.
        matchesThisLevel = 0
        
        // Reset all of the statistics labels to display new game appropriate info
        viewController.matchesForLevelLabel.text = String(matchesThisLevel)
        viewController.levelLabel.text = String(level)
        viewController.thresholdLabel.text = String(levelThreshold)
        viewController.matchesForRoundLabel.text = String(indexMatched)
        
        // Display NEW GAME label every time unless called from viewDidLoad (just big smiley)
        if !first {
            viewController.messageLabel2.text = "NEW GAME!"
            delay(1.5) {self.viewController.messageLabel2.text = ""}
        }
        
        // Make sure the smileys are hidden
        viewController.smiley.hidden = true
        viewController.bigSmiley.hidden = true
        
    } // end of reset() method

    // **************************************************************************************************************
    // playNextSeq()
    // Function hides smiley image from previous play, then computes the wait time (time required to display the
    // sequence so far. diplayPatternSoFar is called with the index to repeat up to and the wait time.  After the
    // wait time (time for MySimon to play sequence), start the timer and set .playing to true (means it's time
    // for user to respond).  buttonTaps and userResp are readied for user response.
    // **************************************************************************************************************
    func playNextSeq() {
        var waitTime: Double
        
        viewController.smiley.hidden = true
        waitTime = Double(self.indexMatched+1)*0.75 - 0.75  // Compute how long to display current pattern to match
        displayPatternSoFar(indexMatched, wait: waitTime)   // Call recursive function to display current pattern to match
        delay(waitTime) {self.startTookTooLong()}           // Start timer (user only has 3 seconds to hit a button or
        delay(waitTime) {self.playing = true}               // the round is over).  Delay starting this timer until
                                                            // displayPatternSoFar() has time to complete.  Otherwise the
                                                            // timer starts while the pattern is being displayed and will
                                                            // eventually expire before user can respond - actually before
                                                            // the displayPatternSoFar() has even finished.
        buttonTaps = 0                  // initialize buttonTaps count property
        userResp = []                   // and userResp for capture user response sequence.
     } // end of playSeq()

    // **************************************************************************************************************
    // managelevel()
    // Function called after each round, but only executes after every third round.  Stat labels are updated and the
    // level threshold is compared to the number of matches obtained during this level (last 3 rounds).  If threshold 
    // is met, increase level and threshold, then update corresponding stat labels.  Update the message label with
    // text indicating whether the level will be repeated or if we move to the next level.
    // **************************************************************************************************************
    func manageLevel() {
        if (roundCount%3 == 0) {
            viewController.matchesForLevelLabel.text = String(matchesThisLevel)
            if (matchesThisLevel >= levelThreshold) {
                level += 1
                levelThreshold += 3
                viewController.thresholdLabel.text = String(levelThreshold)
                if (level <= 10) {
                    viewController.levelLabel.text = String(level)
                    viewController.messageLabel2.text = "Next Level Achieved"
                }
            } else {
                viewController.messageLabel2.text = "Repeat Level"
            }
            matchesThisLevel = 0
        }
    } // end of managedLevel()
    
    // **************************************************************************************************************
    // roundFinished(Int)
    // Function called at end of each round.  The reason round has ended is indicated by the integer passed in.
    // **************************************************************************************************************
    func roundFinished(reason: Int) {
        self.playing = false                    // no longer accept colored button input from user
        
        switch reason {                         // Based on reason, update message label and smiley image
        case 1 :                                //   and play the mistake or winning tone
            viewController.messageLabel.text = "Oops! No match!"
            viewController.smiley.image = redFrowny
            //viewController.smiley.hidden = false
            self.playTone(99)
        case 2 :
            viewController.messageLabel.text = "Took too long!"
            viewController.smiley.image = blueDistressed
            self.playTone(99)
        case 3 :
            viewController.messageLabel.text = "AWESOME! \nEntire sequence matched!"
            viewController.smiley.image = blueSmiley
            self.playTone(98)
        default : print("Error finishing up round")
        }
        viewController.smiley.hidden = false    // Display the smiley image
        matchesThisLevel += indexMatched        // update index and corresponding label
        viewController.matchesForLevelLabel.text = String(matchesThisLevel)
        
        roundCount += 1                         // increment round count
        manageLevel()                           // call function to manage the level
        if level > 10 {                         // check to see if gameis over
            viewController.messageLabel.text = "HIGHEST level completed!"
            viewController.smiley.image = greenSmiley
            self.playTone(98)
        }
    } // end of roundOver()
    
    // **************************************************************************************************************
    // playTone(int)
    // This function plays the sound indicated by integer passed in.  .wav is default file extension.
    // **************************************************************************************************************
    func playTone(btag: Int) {
        var soundFile : String = ""         // initialize soundFile string and
        var ext : String = "wav"            // default file extension
        
        switch btag {
        case 10: soundFile = "C06"          // tone for blue button
        case 11: soundFile = "D08"          // tone for yellow button
        case 12: soundFile = "C18"          // tone for red button
        case 13: soundFile = "G01"          // tone for green button
        case 98: soundFile = "winning"      // tone for match of entire sequence OR completing level 10
                 ext = "mp3"                //       This file has .mp3 extension
        case 99: soundFile = "mistake"      // tone for mistake
        default: soundFile = "C06"          // DEFAULT (shouldn't get here)
        }
        
        // This code taken from stackOverflow
        // http://stackoverflow.com/questions/32816514/play-sound-using-avfoundation-with-swift-2
        // Construct the path to the sound file.
        let url:NSURL = NSBundle.mainBundle().URLForResource(soundFile, withExtension: ext)!
        
        // Make sure the audio player can find the file
        do { audioPlayer = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil) }
        catch let error as NSError { print(error.description) }
        
        audioPlayer.numberOfLoops = 0   // will play once
        audioPlayer.prepareToPlay()     // get ready
        audioPlayer.play()              // play the sound
    }
    
} // end of SimonGame class definition
