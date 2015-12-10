
//
//  SimonMenuVCInterfaceController.swift
//  Simon Game
//
//  Created by Miguel Fagundez on 12/9/15.
//  Copyright © 2015 Miguel Fagundez. All rights reserved.
//

import WatchKit
import Foundation


class SimonMenuVC: WKInterfaceController, endGameDelegate {

    @IBOutlet var scoreLbl: WKInterfaceLabel!
    @IBOutlet var gameOverLbl: WKInterfaceLabel!
    var score: Int?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (score != nil) {
            self.scoreLbl.setText("Score:\(self.score!)")
            self.scoreLbl.setHidden(false)
            self.gameOverLbl.setHidden(false)
        }else{
            self.gameOverLbl.setHidden(true)
            self.scoreLbl.setHidden(true)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func startGame() {
        self.pushControllerWithName("SimonGameVC", context: self)
    }
    
    func endGame(score: Int) {
        print("GAME Ended!")
        self.score = score
    }
   
}
