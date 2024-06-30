
//
//  main.swift
//  OCProgram
//
//  Created by Noah Le Ru on 1/01/24.
//

import Foundation
import OCGUI
// Names of file to load flashcards from.

// Struct for each value on each side of card.
struct Card{
    // Value of card.
    let value: String
    // Suite of card.
    let suite: String
    // Image of card.
}

// Application to play blackjack.
class BlackJackApp : OCApp{
    let playerView = OCHBox(controls: [OCLabel(text: "Player Cards: ")])
    let dealerView = OCHBox(controls: [OCLabel(text: "Dealer Cards: ")])
    // Return total layout of GUI.
    let listView = OCListView()
    var deck: [Card] = []
    var playerCards: [Card] = []
    var currentCard = 0


    func generateDeck() -> [Card] {
        // Each value and suite.
        let values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        let suites = ["Hearts", "Diamonds", "Clubs", "Spades"]
        // Take each combo and add it to list.
        for suite in suites {
            for value in values {
                deck.append(Card(value: value, suite: suite))
            }
        }
        return deck
    }
    /// Shuffle deck.
    func shuffleDeck(deck: [Card]) -> [Card] {
        return deck.shuffled()
    }
    // Show cards to start game.
    func startGame() {
        // Add card to player view and dealer view.
        playerView.append(OCLabel (text: "\(deck[currentCard].value)-\(deck[currentCard].suite)---"))
        // Increase current card so new card is selected.
        // Could remove from list.
        currentCard += 1
        playerView.append(OCLabel (text: "\(deck[currentCard].value)-\(deck[currentCard].suite)"))
        currentCard += 1
        dealerView.append(OCLabel (text: "\(deck[currentCard].value)-\(deck[currentCard].suite)---"))
        currentCard += 1
        dealerView.append(OCLabel (text: "Back of card"))
    }
    /// When dealer clicks hit button.
    func hitPlayer() {
        // Adds card to playerView.
        playerView.append(OCLabel (text: "\(deck[currentCard].value)-\(deck[currentCard].suite)"))
        currentCard += 1
    }
    /// Might not be necesarry.
    func hitDealer() {
        // Adds card to playerView.
        dealerView.append(OCLabel (text: "\(deck[currentCard].value)-\(deck[currentCard].suite)"))
        currentCard += 1
    }

    override open func main(app: any OCAppDelegate) -> OCControl {
        deck = shuffleDeck(deck: generateDeck())

        startGame() 
        hitPlayer()
        return OCVBox(controls: [
            playerView, dealerView
        ])
    }
}

BlackJackApp().start()
