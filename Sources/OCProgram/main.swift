
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
    let image: String
}

// Application to play blackjack.
class BlackJackApp : OCApp{
    let playerView = OCHBox(controls: [OCLabel(text: "Player Cards: ")])
    let dealerView = OCHBox(controls: [OCLabel(text: "Dealer Cards: ")])
    // Return total layout of GUI.
    let listView = OCListView()
    var deck: [Card] = []
    var playerCards: [Card] = []
    var dealerCards: [Card] = []
    var currentCard = 0


    func generateDeck() -> [Card] {
        // Each value and suite.
        let values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        let suites = ["hearts", "diamonds", "clubs", "spades"]
        // Take each combo and add it to list.
        for suite in suites {
            for value in values {
                deck.append(Card(value: value, suite: suite, image: "\(suite)_\(value).png"))
            }
        }
        return deck
    }
    /// Shuffle deck.
    func shuffleDeck(deck: [Card]) -> [Card] {
        return deck.shuffled()
    }
    func calculateScore(cards: [Card]) -> Int {
        var score = 0
        var aces = 0
        for card in cards{
            switch card.value {
                case "A":
                    score += 11
                    aces += 1
                case "K", "Q", "J":
                    score += 10
                default: 
                    print(score)
                    score += Int(card.value) ?? 0
                    print(score)
            }
            // If have ace and score is more thant 21 ace becomes a 1.
            while score > 21 && aces > 1 {
                score -= 11
                aces -= 1
            }
        }
    return score
    }
    // Show cards to start game.
    func startGame() {
        // Add card to player view and dealer view.
        playerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        playerCards.append(deck[currentCard])
        // Increase current card so new card is selected.
        // Could remove from list.
        currentCard += 1
        playerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        playerCards.append(deck[currentCard])
        currentCard += 1
        dealerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        currentCard += 1
        dealerView.append(OCImageView(filename: "back_dark.png"))
    }
    /// When dealer clicks hit button.
    func hitPlayer() {
        // Adds card to playerView.
        playerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        playerCards.append(deck[currentCard])
        currentCard += 1
    }
    /// Might not be necesarry.
    func hitDealer() {
        // Adds card to playerView.
        dealerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        currentCard += 1
    }

    override open func main(app: any OCAppDelegate) -> OCControl {
        deck = shuffleDeck(deck: generateDeck())

        startGame()
        hitPlayer()
        playerView.append(OCLabel(text: "Player Score:\(calculateScore(cards: playerCards))"))

        let maincontainer = OCVBox(controls: [
            playerView, dealerView
        ])

    // Change background color.

        return maincontainer
    }
}

BlackJackApp().start()
