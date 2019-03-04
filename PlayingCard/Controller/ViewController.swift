//
//  ViewController.swift
//  PlayingCard
//
//  Created by Islam Gharib on 1/23/19.
//  Copyright © 2019 Gharib. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var deck = PlayingCardDeck()
    
    @IBOutlet weak var playingCardView: PlayingCardView!{
        // handel the swipe gesture recogniser ,  handel the scale gesture recogniser
        didSet{
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left,.right]
            playingCardView.addGestureRecognizer(swipe)
            
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(playingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    @objc func nextCard(){
        if let card = deck.draw(){
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    // handel the tap gesture recogniser
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            playingCardView.isFaceUp = !playingCardView.isFaceUp
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

