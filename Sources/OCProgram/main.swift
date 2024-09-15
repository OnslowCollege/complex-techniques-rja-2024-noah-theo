//
//  main.swift
//  OCProgram
//
//  Created by Noah Le Ru on 24/06/24.
//

import Foundation
import OCGUI

// Struct for deck of card with images.
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
    // Define Neccesary GUI variables.
    var playerView = OCHBox(controls: [OCLabel(text: "Player Cards: ")])
    let dealerView = OCHBox(controls: [OCLabel(text: "Dealer Cards: ")])
    let listView = OCListView()
    let dealButton = OCButton(text: "Deal")
    let hitButton = OCButton(text: "Hit")
    let standButton = OCButton(text: "Stand")
    let allInButton = OCButton(text: "All In")
    let insuranceButton = OCButton(text: "Insurance")
    let doubleButton = OCButton(text: "Double")
    let increaseButton = OCButton(text: "Increase Bet")
    let decreaseButton = OCButton(text: "Decrease Bet")
    let resetButton = OCButton(text: "Again")
    var betLabel = OCLabel(text: "Bet: 10")
    let helpButton = OCButton(text: "?")
    let closeMenuButton = OCButton(text: "Close")
    var menuLabel = OCLabel(text: "Blackjack Rules:")
    var masterVBox = OCVBox(controls: [])
    var helpVbox = OCVBox(controls: [])
    var sideVbox = OCVBox(controls: [])
    let rulesImg = OCImageView(filename: "rules.png")
    let strategyImg = OCImageView(filename: "strategy.png")
    var helpHbox = OCHBox(controls: [])
    var helpVboxTwo = OCVBox(controls: [])
    let menuLabelTwo =  OCLabel(text: "Basic Blackjack Strategy:")
    var bankrollLabel = OCLabel(text: "NCEA Credits: 100")
    var defaultLabel = OCLabel(text: "Default Bet: 10")

    // Define Neccesary logic variables.
    var deck: [Card] = []
    var playerCards: [Card] = []
    var dealerCards: [Card] = []
    var dealerSecondCardHidden = true
    var currentCard = 0
    var currentBet: Int = 10
    var bankroll: Int = 10 
    var result: String = ""
    var insuranceBet: Int = 0
    var hashit: Bool = false



    /// Function to generate card deck with value, suite and image.
    func generateDeck() -> [Card] {
        // Each value and suite.
        let values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        let suites = ["hearts", "diamonds", "clubs", "spades"]
        // Take each combo + corresponding image and add it to list.
        for suite in suites {
            for value in values {
                // Image works as image files are appropriately named.
                deck.append(Card(value: value, suite: suite, image: "\(suite)_\(value).png"))
            }
        }
        return deck
    }


    /// Shuffle the deck.
    func shuffleDeck(deck: [Card]) -> [Card] {
        return deck.shuffled()
    }


    /// Takes list of cards an calculate score in blackjack terms.
    func calculateScore(cards: [Card]) -> Int {
        var score = 0
        var aces = 0
        for card in cards{
            // For each card find value and add correspoding number to score.
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

    /// Function to update GUI elements of player view.
    func updatePlayerScore() {
        // Empty it.
        playerView.empty()
        // Read all updated elements.
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

    // Function to update GUI elements of dealerview.
    func updateDealerScore() {
        // Empty container.
        dealerView.empty()
        // Re add everything as updated.
        let dealerVbox = OCVBox(controls: [OCLabel(text: "Dealer Cards: ")])
        dealerView.append(dealerVbox)

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


    /// Function shows necesarry cards at start of game.
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


    /// Func for when player decides to hit.
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

    /// Func for once round over for game to restart another round.
    func resestGame(button: any OCControlClickable) {
        // Check if lost game yet.
        if bankroll <= 0 {
            displayGameOver()
        }
        // Reset views and neccesary variables.
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

        // Check if deck needs to be reset and shuffled.

        if currentCard > 42 {
            deck.shuffle()
            sideVbox.append(OCLabel(text: "Deck Shuffled"))
            currentCard = 0
        }
        if currentBet > bankroll {
            currentBet = bankroll
            defaultLabel.text = "Default Bet: \(currentBet)"
        }
    }

    // Func for once player stands and becomes delears turn.
    func standPlayer(button: any OCControlClickable) {
        // Can no longer perform actions.
        hitButton.enabled = false
        standButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false
        dealerSecondCardHidden = false
        updateDealerScore()

        // Dealer hits until 17 or above as per rules.
        while calculateScore(cards: dealerCards) < 17 {
            hitDealer()
        }

        // Ensure scores are correct.
        let dealerScore = calculateScore(cards: dealerCards)
        let playerScore = calculateScore(cards: playerCards)

        // Handle result from dealer and player score.
        // Update correct result and handle bankroll too handle bets.
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

    /// Update all the betting labels.
    func updatesBets() {
        self.betLabel.text = "Bet: \(currentBet)"
        self.defaultLabel.text = "Default Bet: \(currentBet)"
        self.bankrollLabel.text = "NCEA Credits: \(bankroll)"

    }

    /// Func to handle bets depending on player result.
    func updatesBankroll() {
        // Add or minus from bankroll depnding on result.
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


    /// Function for when player chooses to double down.
    func doubleDown(button: any OCControlClickable) {
        // Make sure have enough balance to perform.
        if currentBet*2 > bankroll {
            sideVbox.append(OCLabel(text: "Not enough balance to double down."))
            doubleButton.enabled = false
            return
        }
        // Double bet and hit one card.
        currentBet *= 2

        updatesBets()
        hitPlayer(button: button)

        // If bust !!!! check
        if calculateScore(cards: playerCards) > 21{
            currentBet /= 2
            updatesBets()
            return
        }

        // Disable actions.
        hitButton.enabled = false
        standButton.enabled = false
        insuranceButton.enabled = false
        doubleButton.enabled = false


        standPlayer(button: button)
        currentBet /= 2
        updatesBets()
    }
  
    
    /// Function for when player takes insurance.
    func takeInsurance(button: any OCControlClickable) {
        // Make sure enoguh balance to ensure.
        if currentBet / 2 > bankroll - currentBet{
            sideVbox.append(OCLabel(text: "Not enough balance to insnure."))
            insuranceButton.enabled = false
            return
        }
        // Set insurance bet.
        insuranceBet = currentBet / 2
        bankroll -= insuranceBet
        sideVbox.append(OCLabel(text: "Insurance Bet Placed: \(insuranceBet)"))
        updatesBankroll()

        // Check if dealaer has blackjack and respond appropriately.
        let dealerHasBlackjack = calculateScore(cards: dealerCards) == 21

        if dealerHasBlackjack {
            // Dealer has blackjack give insurance and cont game.
            OCDialog(title: "Insurance", message: "Dealer has Blackjack! Insurance pays 2:1. You get \(insuranceBet * 2) from the insurance, but you lose your main bet.", app: self).show()
            bankroll += insuranceBet * 2
            result = "lost"
            sideVbox.append(resetButton)
            updatesBankroll()

            dealerSecondCardHidden = false
            updateDealerScore()
        } else {
            // Else lose bet and play on.
            OCDialog(title: "Insurance", message: "Dealer does not have Blackjack. You lose your insurance bet.", app: self).show()
            insuranceBet = 0
            updatesBankroll()

            hitButton.enabled = true
            standButton.enabled = true
        }
        // Disable cant insure again.
        insuranceButton.enabled = false
    }

  
    /// Function for once player loses all credits.
    func displayGameOver(){
        // Display message and reset betting vriables so player can continue.
        OCDialog(title: "Game over", message: "Oh no! You lost all of your credits and have now failed NCEA! Luckily Onslow College thinks this will reflect badly on them and have loaned you 100 more NCEA credts. Try not to lose them this time!", app: self).show()
        bankroll = 100
        currentBet = 10
        updatesBets()
    }

    /// Func to increase bet.
    func increaseBet(button: any OCControlClickable) {
        // Increase bet.
        if currentBet + 5 <= bankroll {
            currentBet += 5
            self.defaultLabel.text = "Default Bet: \(currentBet)"
            updatesBets()
            // If too close to boundary can no longer increase or decrease.
            if currentBet > 5{
                decreaseButton.enabled = true
            }
        }
        if currentBet + 5 > bankroll {
            increaseButton.enabled = false 
        }
    }

    /// Func to decrease bet.
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


    // Func to go bet all your balance.
    func allInButton(button: any OCControlClickable) {
        currentBet = bankroll
        updatesBets()
        allInButton.enabled = false
    }

    func showRulesStrategy(button: any OCControlClickable) {
        self.masterVBox.visible = false
        self.helpVbox.visible = true
        self.helpVboxTwo.visible = true
        self.helpButton.visible = false
        self.sideVbox.visible = false
    }

    func closeButton(button: any OCControlClickable) {
        self.helpVbox.visible = false
        self.helpVboxTwo.visible = false
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
        let strategySize = OCSize(fromString: "100%")
        self.strategyImg.width = strategySize

        // Add event listeners and enabled correct buttons.

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
        
        // Generate deck correctly.

        deck = shuffleDeck(deck: generateDeck())
        playerView.append(OCLabel(text: "Player Score:\(calculateScore(cards: playerCards))"))
        sideVbox.append(helpButton)
        playerView.append(betLabel)
        // GUI layout.
        self.helpVbox = OCVBox(controls: [menuLabel, rulesImg, closeMenuButton])
        self.helpVboxTwo = OCVBox(controls: [menuLabelTwo, strategyImg])
        let hitStandVBox = OCVBox(controls: [hitButton, standButton])
        let splitInsuranceVBox = OCVBox(controls: [allInButton, insuranceButton])
        let dealDoubleVBox = OCVBox(controls: [dealButton, doubleButton])
        let betVBox = OCVBox(controls: [increaseButton, decreaseButton])
        let balanceVbox = OCVBox(controls: [defaultLabel, bankrollLabel])
        let masterHBox = OCHBox(controls: [balanceVbox, hitStandVBox, splitInsuranceVBox, dealDoubleVBox, betVBox])
        self.helpVbox.visible = false
        self.helpVboxTwo.visible = false
        self.masterVBox = OCVBox(controls: [
            dealerView, playerView, masterHBox
        ])

        let maincontainer = OCHBox(controls: [
            masterVBox, helpVbox, helpVboxTwo, sideVbox
        ])
        visibiltyUpdateTwo()
        return maincontainer
    }
}

BlackJackApp().start()


