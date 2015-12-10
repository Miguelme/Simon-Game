//
//  SimonGameVC.swift
//  Simon Game
//
//  Created by Miguel Fagundez on 12/9/15.
//  Copyright © 2015 Miguel Fagundez. All rights reserved.
//

import WatchKit
import Foundation

protocol endGameDelegate {
    func endGame(score: Int)
}

class SimonGameVC: WKInterfaceController {

    @IBOutlet var uLBtn: WKInterfaceButton!
    @IBOutlet var uRBtn: WKInterfaceButton!
    @IBOutlet var lLBtn: WKInterfaceButton!
    @IBOutlet var lRBtn: WKInterfaceButton!
    @IBOutlet var notifLbl: WKInterfaceLabel!
    
    var currentGameSecuence : [Int] = []
    let kGameTurnCount = 1000
    let quadrantColors = [UIColor.redColor(), UIColor.blueColor(), UIColor.yellowColor(), UIColor.greenColor()]
    var currentPlayerTurn = 0
    var blockedButtons = true
    var userInputButtons : [Int] = []
    var delegate: endGameDelegate?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.delegate = (context as! endGameDelegate)
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        startGame()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    @IBAction func uLAction() {
        self.playerPressedQuadrant(0)
    }
    @IBAction func uRAction() {
        self.playerPressedQuadrant(1)
    }
    @IBAction func lLAction() {
        self.playerPressedQuadrant(2)
    }
    @IBAction func lRAction() {
        self.playerPressedQuadrant(3)
    }
    
    func generateNewGameSecuence()-> [Int]{
        
        var game: [Int] = []
        for i in 0..<kGameTurnCount{
            let randomInt = Int(arc4random_uniform(4))
            game.append(randomInt)
        }
        
        return game
    }
    
    func quadrantFlashColors() ->[UIColor] {
        
        var flashColors: [UIColor] = []
        for color in quadrantColors {
            flashColors.append(color.colorWithAlphaComponent(0.5))
        }
        
        return flashColors
    }
    
    func gameButtons() -> NSArray {
        return [self.uLBtn, self.uRBtn, self.lLBtn, self.lRBtn]
    }
    func flashQuadrantWithIndex(index: Int){
        let buttonToFlash = self.gameButtons() [index] as! WKInterfaceButton
        let flashColor : UIColor = quadrantFlashColors()[index]
        buttonToFlash.setBackgroundColor(flashColor)
//        print("about to")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
  //          print("inside")
            buttonToFlash.setBackgroundColor(self.quadrantColors[index])
        })
        
    }
    
    func startGame(){
        self.currentPlayerTurn = 1
        self.currentGameSecuence = self.generateNewGameSecuence()
        self.notifLbl.setText("Ready")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.notifLbl.setText("Set")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.notifLbl.setText("Go!")
                self.playSeriesForTurn(self.currentPlayerTurn)
            })
        })
    }
    
    func playSeriesForTurn(turn: Int){
        self.playSeriesFromIndex(0, toIndex: turn)
    }
    
    func playSeriesFromIndex(fromIndex: Int, toIndex: Int){
        if fromIndex == toIndex {
            self.startPlayerTurn()
            return
        }
        let currentQuadrant = self.currentGameSecuence[fromIndex]
        self.flashQuadrantWithIndex(currentQuadrant)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.playSeriesFromIndex(fromIndex + 1, toIndex: toIndex)
        })
        
    }
    
    func playerPressedQuadrant(index: Int){
        if blockedButtons {
            return
        }
        self.userInputButtons.append(index)
        
        for i in 0..<self.userInputButtons.count{
            if self.userInputButtons[i] != self.currentGameSecuence[i]{
                self.endGame()
                return
            }
            
        }
        
        if self.userInputButtons.count == self.currentPlayerTurn{
            self.startSimonTurn()
        }
        
    }
    
    func startSimonTurn(){
        self.currentPlayerTurn++
        self.blockedButtons = true
        self.notifLbl.setText("Nice Job!")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.notifLbl.setText("Simon's Turn!")
            self.playSeriesForTurn(self.currentPlayerTurn)
        })
    }
    
    func startPlayerTurn(){
        self.blockedButtons = false
        self.notifLbl.setText("It's your turn!")
        self.userInputButtons = []
    }
    
    func endGame(){
        self.notifLbl.setText("Wrong!")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {

            self.delegate?.endGame(self.currentPlayerTurn)
        
            self.popController()
        })
    }
}


