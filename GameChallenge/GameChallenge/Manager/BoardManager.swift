//
//  BoardManager.swift
//  GameChallenge
//
//  Created by Mateus Nobre on 16/03/21.
//

import Foundation
import GameplayKit
import SpriteKit

enum SubmitionResult {
    case gold
    case silver
    case bronze
    case wrong
}

class BoardManager {
    let gamePlayManager: GameplayManager
    let legend: Legend
    private(set) var cards = Set<Card>()
    var deck: [Card]
    var maxCardsBoard = 4
    var startPoint: CGPoint = CGPoint()
    var spaceBetweenCards = CGFloat()
    var cardHeight = CGFloat()

    init(manager: GameplayManager, legend: Legend) {
        gamePlayManager = manager
        self.legend = legend
        self.deck = []
        tempGenerateCards(num: 20)
        shuffleDeck()
    }

    //Funcao temporaria, remover quando as cartas  vierem
    // de outro Manager
    func tempGenerateCards(num: Int) {
        for index in 0..<num {
            let card = Card(identifier: index, assetName: "")
            self.deck.append(card)
        }
    }

    func add(_ cards: Card...) {
        for card in cards {
            if self.cards.count >= self.maxCardsBoard {return}
            self.cards.insert(card)
            gamePlayManager.add(entity: card)
        }
    }

    func renderCardToView(view: SKNode, cardNode: SKNode) {
        view.addChild(cardNode)
        cardNode.position = calcBoardNewCardPosition()
    }

    func calcBoardNewCardPosition() -> CGPoint {
        let yPosition = startPoint.y - CGFloat(cards.count) * (spaceBetweenCards + cardHeight)
        return CGPoint(x: startPoint.x, y: yPosition)
    }

    func clear(wrongCards: Set<Card>) {
        for card in wrongCards {
            cards.remove(card)
        }
    }

    func drawCards(amount: Int) -> [Card] {
        var returnedCards: [Card] = []
        if self.deck.count < amount {
            return []
        }
        for _ in 0..<amount {
            let lastCard = addCardToDownDeck(self.deck.last!)
            returnedCards.append(lastCard)
        }
        return returnedCards
    }

    func addCardToDownDeck(_ card: Card) -> Card {
        var tempDeck: [Card] = []
        tempDeck.append(card)
        let card = self.deck.removeLast()
        tempDeck.append(contentsOf: self.deck)
        self.deck = tempDeck
        return card
    }

    func shuffleDeck() {
        var newDeck: [Card] = []
        let initialCardsCount = self.deck.count
        for _ in 0..<initialCardsCount {
            let randomPosition = Int.random(in: 0..<self.deck.count)
            newDeck.append(self.deck[randomPosition])
            self.deck.remove(at: randomPosition)
        }
        self.deck = newDeck
    }

    func checkSubmition() {
        let pontuationAndWrongCard = calculatePontuationAndWrongCards(legend: self.legend, cards: self.cards)
        if pontuationAndWrongCard.1.count > 0 {
            executeActionFrom(submition: .wrong, wrongCards: pontuationAndWrongCard.1)
            return
        }
        let pontuation = pontuationAndWrongCard.0
        if pontuation>=16 {
            executeActionFrom(submition: .gold)
            return
        } else if pontuation>=13 {
            executeActionFrom(submition: .silver)
            return
        } else {
            executeActionFrom(submition: .bronze)
            return
        }
    }

    func calculatePontuationAndWrongCards(legend: Legend, cards: Set<Card>) -> (Int, Set<Card>) {
        guard let legendComponent = legend.component(ofType: LegendComponent.self) else { return (0, cards) }
        var primaryCount = 0
        var secundaryCount = 0
        var wrongCards = Set<Card>()
        for card in cards {
            if let cardInfoComponent = card.component(ofType: CardInfoComponent.self) {
                let cardIdentifier = cardInfoComponent.identifier
                if legendComponent.primary.contains(cardIdentifier) {
                    primaryCount += 1
                } else if legendComponent.secundary.contains(cardIdentifier) {
                    secundaryCount += 1
                } else {
                    wrongCards.insert(card)
                }
            }
        }
        let pontuation = 4*primaryCount + secundaryCount
        return (pontuation, wrongCards)
    }

    func executeActionFrom(submition: SubmitionResult, wrongCards: Set<Card> = Set<Card>()) {
        switch submition {
        case .gold, .silver, .bronze:
            print(submition)
        case .wrong:
            clear(wrongCards: wrongCards)
        }
    }
}
