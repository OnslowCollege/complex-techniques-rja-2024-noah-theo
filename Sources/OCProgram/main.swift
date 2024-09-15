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
    let allInButton = OCButton(text: "All In")
    let insuranceButton = OCButton(text: "Insurance")
    let doubleButton = OCButton(text: "Double")
    let increaseButton = OCButton(text: "Increase")
    let decreaseButton = OCButton(text: "Decrease")
    let resetButton = OCButton(text: "Again")
    var dealerSecondCardHidden = true
    var currentBet: Int = 10
    var betLabel = OCLabel(text: "Bet: 10")
    var bankroll: Int = 100
    var bankrollLabel = OCLabel(text: "NCEA Credits: 100")
    var result: String = ""
    var defaultLabel = OCLabel(text: "Default Bet: 10")
    var insuranceBet: Int = 0
    var hashit: Bool = false
    let helpButton = OCButton(text: "?")
    let helpMenuButton = OCButton(text: "Show Strategy")
    let closeMenuButton = OCButton(text: "Close")
    var menuLabel = OCLabel(text: "Blackjack Rules:")
    var masterVBox = OCVBox(controls: [])
    var helpVbox = OCVBox(controls: [])
    var sideVbox = OCVBox(controls: [])
    let rulesImg = OCImageView(filename: "gamerules.png")
    let strategyImg = OCImageView(filename: "strategy.png")
    var helpHbox = OCHBox(controls: [])
    var rulesLabel = OCTextArea()
    let cardRules = """
Card Values:
Number cards (2-10): Face value.
Face cards (King, Queen, Jack): 10 points.
Ace: 1 or 11 points (whichever benefits the hand).

Gameplay:
The player and dealer are each dealt two cards. The player's cards are both face-up, while the dealer has one face-up card and one face-down card.
The player must decide how to play their hand based on the sum of their cards and the dealer’s face-up card.

Player's Actions:
Hit: Take another card.
Stand: Keep the current hand and end the turn.
Double: Double the original bet, receive one additional card, and then stand.
Insurance: If the dealer’s upcard is an Ace, the player can take "insurance" against the dealer having Blackjack. If the dealer has Blackjack, the insurance bet pays 2:1, but the player loses the original bet.

Dealer's Actions:
The dealer reveals their face-down card once the player has finished their turn.
The dealer must hit until their hand totals 17 or higher.

Winning Conditions:
Blackjack: An Ace and any 10-point card dealt to the player in the first two cards. This is an automatic win unless the dealer also has Blackjack (in which case it's a tie).
Bust: If the player's or dealer’s hand exceeds 21, they lose.
Compare Hands: If neither busts, the hand closest to 21 wins.
Tie: If the player and dealer have the same hand value, the bet is returned (no win or loss).

Betting:
Win: If the player wins the hand by beating the dealer, they get paid 1:1 on their bet. This means they receive an amount equal to their original bet in addition to their bet being returned.
Blackjack: If the player gets a Blackjack and the dealer doesn’t also have Blackjack, the player is paid 3:2.
Tie: If the player and the dealer have the same hand value, it's a tie. In this case, the player’s bet is returned, and no credits are won or lost.
Loss: If the player loses to the dealer, their bet is forfeited.
"""

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
        let playerVbox = OCVBox(controls: [OCLabel(text: "Player Cards: ")])
        playerVbox.append(betLabel)
        playerView.append(playerVbox)

        for card in playerCards {
            playerView.append(OCImageView(filename: card.image))
        }
        let playerScore = calculateScore(cards: playerCards)
        playerVbox.append(OCLabel(text: "Player Score: \(playerScore)"))
        self.betLabel.text = "Bet: \(currentBet)"
        self.bankrollLabel.text = "NCEA Credits: \(bankroll)"
    }

    func updateDealerScore() {
        dealerView.empty()
        let dealerVbox = OCVBox(controls: [OCLabel(text: "Dealer Cards: ")])
        dealerView.append(dealerVbox)
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
        dealerVbox.append(OCLabel(text: "Dealer Score: \(dealerScore)"))
    }

    // Show cards to start game.
    func startGame(button: any OCControlClickable) {
        // Ensure not betting more than they have.
        if bankroll < currentBet {
            sideVbox.append(OCLabel(text: "Insufficent balance to place this bet."))
            return
        }

        // Reset cards and views and enable correct buttons.
        playerCards = []
        dealerCards = []
        playerView.empty()
        dealerView.empty()
        sideVbox.empty()
        sideVbox.append(helpButton)
        increaseButton.enabled = false
        decreaseButton.enabled = false
        allInButton.enabled = false

        // Add 2 cards for player.
        let playerCard1 = "\(deck[currentCard].image)"
        playerView.append(OCImageView(filename: playerCard1))
        playerCards.append(deck[currentCard])
        currentCard += 1

        let playerCard2 = "\(deck[currentCard].image)"
        playerView.append(OCImageView(filename: playerCard2))
        playerCards.append(deck[currentCard])
        currentCard += 1

        // One card for dealer.
        let dealerCard = "\(deck[currentCard].image)"
        dealerView.append(OCImageView(filename: dealerCard))
        dealerCards.append(deck[currentCard])
        currentCard += 1

        // Second dealer card is hidden.
        dealerView.append(OCImageView(filename: "back.png"))
        dealerCards.append(deck[currentCard])
        currentCard += 1
        // Ensure correct action buttons enabled.
        dealButton.enabled = false
        hitButton.enabled = true
        standButton.enabled = true
        doubleButton.enabled = true

        // Check if player is allowed to take insurance.
        if dealerCards[0].value == "A" {
            insuranceButton.enabled = true
        }

        // After adding cards update both views and score.
        updatePlayerScore()
        updateDealerScore()
        // Check if player has blackjack if so round ends and player wins.
        if calculateScore(cards: playerCards) == 21 {
            hitButton.enabled = false
            standButton.enabled = false
            insuranceButton.enabled = false
            doubleButton.enabled = false
            sideVbox.append(OCLabel(text: "Blackjack! Yay you won \(Int(Double(currentBet) * 1.5))"))
            result = "blackjack"
            sideVbox.append(resetButton)
            updatesBankroll()
        }
    }


    /// When dealer clicks hit button.
    func hitPlayer(button: any OCControlClickable) {
        // Can no longer double after hitting.
        doubleButton.enabled = false
        // Add card to playerView.
        playerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        playerCards.append(deck[currentCard])
        currentCard += 1
        // Update player view.
        updatePlayerScore()
        // Make sure player hasn't busted if they have end game with loss.
        if calculateScore(cards: playerCards) > 21 {
            hitButton.enabled = false
            standButton.enabled = false
            insuranceButton.enabled = false
            sideVbox.append(OCLabel(text: "Bust! You lose your bet."))
            sideVbox.append(resetButton)
            result = "lost"
            updatesBankroll()
        }
    }

    /// Func for after standing and to add card to dealer.
    func hitDealer() {
        dealerCards.append(deck[currentCard])
        dealerView.append(OCImageView(filename: "\(deck[currentCard].image)"))
        currentCard += 1
        updateDealerScore()
    }

    func resestGame(button: any OCControlClickable) {
        if bankroll <= 0 {
            displayGameOver()
        }
        playerCards = []
        dealerCards = []
        dealerSecondCardHidden = true

        playerView.empty()
        dealerView.empty()
        sideVbox.empty()
        sideVbox.append(helpButton)
        result = ""

        dealButton.enabled = true
        hitButton.enabled = false
        standButton.enabled = false
        allInButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false
        increaseButton.enabled = true
        decreaseButton.enabled = true
        allInButton.enabled = true
        if currentCard > 42 {
            deck.shuffle()
            sideVbox.append(OCLabel(text: "Deck Shuffled"))
            currentCard = 0
        }
        if currentBet > bankroll {
            currentBet = bankroll
            defaultLabel.text = "Default Bet:\(currentBet)"
        }
    }

    func standPlayer(button: any OCControlClickable) {
        hitButton.enabled = false
        standButton.enabled = false
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
            sideVbox.append(OCLabel(text: "Dealer Bust. You win \(currentBet)."))
            result = "player"
            sideVbox.append(resetButton)
            updatesBankroll()  
        } else if dealerScore > playerScore {
            sideVbox.append(OCLabel(text: "Dealer Wins. You lose \(currentBet)."))
            result = "lost"
            sideVbox.append(resetButton)
            updatesBankroll()
        } else if dealerScore < playerScore {
            sideVbox.append(OCLabel(text: "You win \(currentBet)."))
            result = "player"
            sideVbox.append(resetButton)
            updatesBankroll()  
        } else {
            sideVbox.append(OCLabel(text: "Tie. You get your bet back."))
            result = "tie"
            sideVbox.append(resetButton)
            updatesBankroll()  
        }
    }

    func updatesBets() {
        self.betLabel.text = "Bet: \(currentBet)"
        self.defaultLabel.text = "Default Bet: \(currentBet)"
        self.bankrollLabel.text = "NCEA Credits: \(bankroll)"
    }

    func updatesBankroll() {
        switch result {
        case "player" :
            bankroll += currentBet  
            bankrollLabel.text = "NCEA Credits: \(bankroll)"
        case "blackjack":
            bankroll += Int(Double(currentBet) * 1.5)
            bankrollLabel.text = "NCEA Credits: \(bankroll)"
        case "tie":
            bankrollLabel.text = "NCEA Credits: \(bankroll)"
        case "lost":
            bankroll -= currentBet
            bankrollLabel.text = "NCEA Credits: \(bankroll)"
        default:
            break
        }
    }

    func doubleDown(button: any OCControlClickable) {
        if currentBet*2 > bankroll {
            sideVbox.append(OCLabel(text: "Not enough balance to double down."))
            doubleButton.enabled = false
            return
        }
        currentBet *= 2

        updatesBets()
        hitPlayer(button: button)

        if calculateScore(cards: playerCards) > 21{
            return
        }

        hitButton.enabled = false
        standButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false

        standPlayer(button: button)
    }

    func takeInsurance(button: any OCControlClickable) {
        if currentBet / 2 > bankroll - currentBet{
            sideVbox.append(OCLabel(text: "Not enough balance to insnure."))
            insuranceButton.enabled = false
            return
        }
        insuranceBet = currentBet / 2
        bankroll -= insuranceBet
        sideVbox.append(OCLabel(text: "Insurance Bet Placed: \(insuranceBet)"))
        OCDialog(title: "Insurance Bet Placed", message: "Insurance Bet Placed: \(insuranceBet)", app: self).show()
        updatesBankroll()


        let dealerHasBlackjack = calculateScore(cards: dealerCards) == 21

        if dealerHasBlackjack {
            // dealer has blackjack.
            OCDialog(title: "Insurance", message: "Dealer has Blackjack! Insurance pays 2:1. You get \(insuranceBet * 2) from the insurance, but you lose your main bet.", app: self).show()
            bankroll += insuranceBet * 2
            result = "lost"
            sideVbox.append(resetButton)
            updatesBankroll()

            dealerSecondCardHidden = false
            updateDealerScore()
        } else {
            OCDialog(title: "Insurance", message: "Dealer does not have Blackjack. You lose your insurance bet.", app: self).show()
            insuranceBet = 0
            updatesBankroll()

            hitButton.enabled = true
            standButton.enabled = true
        }
        insuranceButton.enabled = false
    }

    func displayGameOver(){
        OCDialog(title: "Game over", message: "Oh no! You lost all of your credits and have now failed NCEA! Luckily Onslow College thinks this will reflect badly on them and have loaned you 100 more NCEA credts. Try not to lose them this time!", app: self).show()
        bankroll = 100
        currentBet = 10
        updatesBets()
        // reset views?
    }

    func increaseBet(button: any OCControlClickable) {
        if currentBet + 5 <= bankroll {
            currentBet += 5
            self.defaultLabel.text = "Default Bet: \(currentBet)"
            updatesBets()

            if currentBet > 5{
                decreaseButton.enabled = true
            }
        }
        if currentBet + 5 > bankroll {
            increaseButton.enabled = false 
        }
    }

    func decreaseBet(button: any OCControlClickable) {
        allInButton.enabled = true
        if currentBet > 5 {
            currentBet -= 5
            self.defaultLabel.text = "Default Bet: \(currentBet)"
            updatesBets()

            if currentBet + 5 <= bankroll {
                increaseButton.enabled = true
            }
        }
        if currentBet <= 5 {
            decreaseButton.enabled = false
        }
    }

    func allInButton(button: any OCControlClickable) {
        currentBet = bankroll
        updatesBets()
        allInButton.enabled = false
    }

    func showRulesStrategy(button: any OCControlClickable) {
        self.masterVBox.visible = false
        self.helpVbox.visible = true
        self.helpButton.visible = false
        self.sideVbox.visible = false
    }

    func menuButton(button: any OCControlClickable) {
        if helpMenuButton.text == "Show Strategy" {
            self.helpMenuButton.text = "Show Rules"
            self.menuLabel.text = "Basic Blackjack Strategy:"
            self.helpVbox.empty()
            self.helpVbox.append(menuLabel)
            self.helpVbox.append(strategyImg)
            self.helpVbox.append(helpHbox)
        } else {
            self.helpMenuButton.text = "Show Strategy"
            self.menuLabel.text = "Blackjack Rules:"
            self.helpVbox.empty()
            self.helpVbox.append(menuLabel)
            self.helpVbox.append(rulesImg)
            self.helpVbox.append(helpHbox)
        }
    }

    func closeButton(button: any OCControlClickable) {
        self.helpVbox.visible = false
        self.masterVBox.visible = true
        self.helpButton.visible = true
        self.sideVbox.visible = true
    }

    func visibiltyUpdate() {
        self.masterVBox.visible = false
        self.helpVbox.visible = true
        self.helpButton.visible = false
        self.sideVbox.visible = false 
    }

    func visibiltyUpdateTwo() {
        self.helpVbox.visible = false
        self.masterVBox.visible = true
        self.helpButton.visible = true
        self.sideVbox.visible = true
    }


    override open func main(app: any OCAppDelegate) -> OCControl {
        visibiltyUpdate()
        let size = OCSize(fromString: "120%")
        rulesImg.width = size
        let strategySize = OCSize(fromString: "200%")
        self.strategyImg.width = strategySize
        self.rulesLabel.text = cardRules
        self.rulesLabel.width = OCSize(fromString: "300%")
        self.rulesLabel.height = OCSize(fromString: "70%")
        hitButton.enabled = false
        standButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false
        dealButton.onClick(self.startGame)
        hitButton.onClick(self.hitPlayer)
        resetButton.onClick(self.resestGame)
        self.standButton.onClick(self.standPlayer)
        self.increaseButton.onClick(self.increaseBet)
        self.decreaseButton.onClick(self.decreaseBet)
        self.doubleButton.onClick(self.doubleDown)
        self.insuranceButton.onClick(self.takeInsurance)
        self.allInButton.onClick(self.allInButton)
        self.helpButton.onClick(self.showRulesStrategy)
        self.closeMenuButton.onClick(self.closeButton)
        self.helpMenuButton.onClick(self.menuButton)
        deck = shuffleDeck(deck: generateDeck())
        playerView.append(OCLabel(text: "Player Score:\(calculateScore(cards: playerCards))"))
        sideVbox.append(helpButton)
        playerView.append(betLabel)
        self.helpHbox = OCHBox(controls: [helpMenuButton, closeMenuButton])
        self.helpVbox = OCVBox(controls: [menuLabel, rulesLabel, helpHbox])
        let hitStandVBox = OCVBox(controls: [hitButton, standButton])
        let splitInsuranceVBox = OCVBox(controls: [allInButton, insuranceButton])
        let dealDoubleVBox = OCVBox(controls: [dealButton, doubleButton])
        let betVBox = OCVBox(controls: [increaseButton, decreaseButton])
        let balanceVbox = OCVBox(controls: [defaultLabel, bankrollLabel])
        let masterHBox = OCHBox(controls: [balanceVbox, hitStandVBox, splitInsuranceVBox, dealDoubleVBox, betVBox])
        self.helpVbox.visible = false
        self.masterVBox = OCVBox(controls: [
            dealerView, playerView, masterHBox
        ])

        let maincontainer = OCHBox(controls: [
            masterVBox, helpVbox, sideVbox
        ])
        visibiltyUpdateTwo()
        return maincontainer
    }
}

BlackJackApp().start()