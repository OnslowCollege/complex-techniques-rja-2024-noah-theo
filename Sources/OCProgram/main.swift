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
    var playerView = OCHBox(controls: [OCLabel(text: "Player Cards: ")])
    let dealerView = OCHBox(controls: [OCLabel(text: "Dealer Cards: ")])
    // Return total layout of GUI.
    let listView = OCListView()
    var deck: [Card] = []
    var playerCards: [Card] = []
    var dealerCards: [Card] = []
    var currentCard = 0
    let dealButton = OCButton(text: "Deal")
    let hitButton = OCButton(text: "Hit")
    let standButton = OCButton(text: "Stand")
    let splitButton = OCButton(text: "Split")
    let insuranceButton = OCButton(text: "Insurance")
    let doubleButton = OCButton(text: "Double")
    let increaseButton = OCButton(text: "Increase")
    let decreaseButton = OCButton(text: "Decrease")
    let resetButton = OCButton(text: "Again")
    let helpbutton = OCButton(text: "?")
    var dealerSecondCardHidden = true

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
        print(deck)
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
                    score += Int(card.value) ?? 0
            }
            // If have ace and score is more thant 21 ace becomes a 1.
            while score > 21 && aces > 0 {
                score -= 10
                aces -= 1
            }
        }
    return score
    }

    func updatePlayerScore() {
        playerView.empty()
        playerView.append(OCLabel(text: "Player Cards: "))

        for card in playerCards {
            playerView.append(OCImageView(filename: card.image))
        }
        let playerScore = calculateScore(cards: playerCards)
        playerView.append(OCLabel(text: "Player Score: \(playerScore)"))
    }

    func updateDealerScore() {
        dealerView.empty()
        dealerView.append(OCLabel(text: "Dealer Cards: "))
        // Re-add the dealer's cards
        for (index, card) in dealerCards.enumerated() {
            if dealerSecondCardHidden && index == 1 {
                dealerView.append(OCImageView(filename: "back.png"))
            } else {
                dealerView.append(OCImageView(filename: card.image))
            }
        }
        let visibleDealerCards = dealerSecondCardHidden ? [dealerCards[0]] : dealerCards
        let dealerScore = calculateScore(cards: visibleDealerCards)
        dealerView.append(OCLabel(text: "Dealer Score: \(dealerScore)"))
    }

    // Show cards to start game.
    func startGame(button: any OCControlClickable) {
        playerCards = []
        dealerCards = []
        playerView.empty()
        dealerView.empty()

        // Add card to player view and dealer view.
        let playerCard1 = "\(deck[currentCard].image)"
        playerView.append(OCImageView(filename: playerCard1))
        playerCards.append(deck[currentCard])
        currentCard += 1

        let playerCard2 = "\(deck[currentCard].image)"
        playerView.append(OCImageView(filename: playerCard2))
        playerCards.append(deck[currentCard])
        currentCard += 1

        let dealerCard = "\(deck[currentCard].image)"
        dealerView.append(OCImageView(filename: dealerCard))
        dealerCards.append(deck[currentCard])
        currentCard += 1

        dealerView.append(OCImageView(filename: "back.png"))
        dealerCards.append(deck[currentCard])
        currentCard += 1
        dealButton.enabled = false
        hitButton.enabled = true
        standButton.enabled = true
        splitButton.enabled = true
        insuranceButton.enabled = true
        doubleButton.enabled = true
        updatePlayerScore()
        updateDealerScore()
        if calculateScore(cards: playerCards) == 21 {
            hitButton.enabled = false
            playerView.append(OCLabel(text: "Blackjack! Yay!"))
            standButton.enabled = false
            splitButton.enabled = false
            insuranceButton.enabled = false
            doubleButton.enabled = false
            playerView.append(resetButton)
        }
}


    /// When dealer clicks hit button.
    func hitPlayer(button: any OCControlClickable) {
        // Adds card to playerView.
        playerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        playerCards.append(deck[currentCard])
        currentCard += 1
        updatePlayerScore()
        if calculateScore(cards: playerCards) > 21 {
            hitButton.enabled = false
            playerView.append(OCLabel(text: "Bust! You lose."))
            standButton.enabled = false
            splitButton.enabled = false
            insuranceButton.enabled = false
            doubleButton.enabled = false
            playerView.append(resetButton)
        }
    }

    func hitDealer() {
        dealerCards.append(deck[currentCard])
        dealerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        currentCard += 1
        updateDealerScore()
    }

    func resestGame(button: any OCControlClickable) {
        playerCards = []
        dealerCards = []
        dealerSecondCardHidden = true

        playerView.empty()
        dealerView.empty()

        dealButton.enabled = true
        hitButton.enabled = false
        standButton.enabled = false
        splitButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false
        if currentCard > 42 {
            deck.shuffle()
            playerView.append(OCLabel(text: "Deck Shuffled"))
            currentCard = 0
        }
    } 

    func standPlayer(button: any OCControlClickable) {
        hitButton.enabled = false
        standButton.enabled = false
        splitButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false
    
        dealerSecondCardHidden = false
        updateDealerScore()

        while calculateScore(cards: dealerCards) < 17 {
            hitDealer()
        }

        let dealerScore = calculateScore(cards: dealerCards)
        let playerScore = calculateScore(cards: playerCards)

        if dealerScore > 21 {
            dealerView.append(OCLabel(text: "Dealer Bust."))
            dealerView.append(resetButton)
        } else if dealerScore > playerScore {
            playerView.append(OCLabel(text: "Dealer Wins."))
            playerView.append(resetButton)
        } else if dealerScore < playerScore {
            playerView.append(OCLabel(text: "You Win."))
            playerView.append(resetButton)
        } else {
            playerView.append(OCLabel(text: "Tie."))
            playerView.append(resetButton)
        }
    }

    func helpButton(button: any OCControlClickable) {
        // pop up that will appear, confirming the user's order
        OCDialog(
            title: "Help",
            message: """
Here's a summary of the rules for a single-player blackjack game, including betting:

### **Objective**
- Beat the dealer by having a hand value closer to 21 without exceeding 21.

### **Card Values**
- Number cards (2-10): Face value.
- Face cards (Jack, Queen, King): 10 points.
- Aces: 1 or 11 points.

### **Game Setup**
- **Deck**: Usually 1-8 decks of 52 cards.
- **Players**: Single player against the dealer.
- **Bets**: Placed before cards are dealt. The player places chips in the betting area according to the table's minimum and maximum limits.

### **Game Play**
1. **Initial Deal**:
   - Player and dealer receive two cards each.
   - Player’s cards are face up.
   - Dealer has one card face up (upcard) and one card face down (hole card).

2. **Player’s Turn**:
   - **Hit**: Take an additional card.
   - **Stand**: Keep the current hand.
   - **Double Down**: Double the bet and take exactly one more card.
   - **Split**: If the initial two cards are of the same value, the player can split them into two hands, each with a separate bet.
   - **Surrender**: Forfeit half the bet and end the round (only available in some variations).

3. **Dealer’s Turn**:
   - Dealer reveals the hole card.
   - Dealer must hit until their hand is at least 17.
   - Dealer stands on 17 or higher.

4. **Outcome**:
   - If the player’s hand exceeds 21, they bust and lose the bet.
   - If the dealer busts, the player wins the bet.
   - If neither busts, the hand closest to 21 wins.
   - A tie (push) results in no loss or gain of the bet.

### **Payouts**
- **Winning Hand**: 1:1 payout.
- **Blackjack (Ace + 10-value card)**: 3:2 payout.
- **Insurance** (if the dealer's upcard is an Ace): Player can bet up to half their original bet that the dealer has blackjack. If correct, the payout is 2:1.

This summary covers the essential rules and actions for a single-player blackjack game, focusing on the player's interactions and decisions during the game.
""", app: self
        ).show()
    }

    override open func main(app: any OCAppDelegate) -> OCControl {
        hitButton.enabled = false
        standButton.enabled = false
        splitButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false
        dealButton.onClick(self.startGame)
        hitButton.onClick(self.hitPlayer)
        resetButton.onClick(self.resestGame)
        standButton.onClick(self.standPlayer)
        helpbutton.onClick(self.helpButton)
        

        deck = shuffleDeck(deck: generateDeck())
        playerView.append(OCLabel(text: "Player Score:\(calculateScore(cards: playerCards))"))

        let hitStandVBox = OCVBox(controls: [hitButton, standButton])
        let splitInsuranceVBox = OCVBox(controls: [splitButton, insuranceButton])
        let dealDoubleVBox = OCVBox(controls: [dealButton, doubleButton])
        let betVBox = OCVBox(controls: [increaseButton, decreaseButton])
        let masterHBox = OCHBox(controls: [hitStandVBox, splitInsuranceVBox, dealDoubleVBox, betVBox, helpbutton])

        let maincontainer = OCVBox(controls: [
            dealerView, playerView,  masterHBox
        ])
        
    // Change background color.
        return maincontainer
    }
}

BlackJackApp().start()