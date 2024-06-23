
//
//  main.swift
//  OCProgram
//
//  Created by Noah Le Ru on 1/01/24.
//

import Foundation
import OCGUI
// Names of file to load flashcards from.
let FILENAME: String = "cards.txt"

// Struct for each value on each side of card.
struct Card{
    // Name of element.
    let value: String
    // Symbol of element.
    let suite: String
}

// Application to show make user guess selected number of flashcards.
class FlashcardApp : OCApp{
    func generateDeck() -> [Card] {
        let values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        let suites = ["Hearts", "Diamonds", "Clubs", "Spades"]
    
        var deck = [Card]()
    
        for suite in suites {
            for value in values {
                deck.append(Card(value: value, suite: suite))
            }
        }
        return deck
    }

    func shuffleDeck(deck: [Card]) -> [Card] {
        return deck.shuffled()
    }

    override open func main(app: any OCAppDelegate) -> OCControl {
        let mainView = OCHBox(controls: [])
        // Return total layout of GUI.
        let deck = generateDeck()
        let listView = OCListView()
        let shuffledDeck = shuffleDeck(deck: deck)

        for card in shuffledDeck {
            listView.append(item: "\(card.value)-\(card.suite)")
        }

        mainView.append(control: listView)

        return OCVBox(controls: [
            mainView
        ])
    }
}

FlashcardApp().start()