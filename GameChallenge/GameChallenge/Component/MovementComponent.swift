//
//  MovementComponent.swift
//  GameChallenge
//
//  Created by Pedro Sousa on 12/03/21.
//

import GameplayKit

class MovementComponent: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        guard let entity = self.entity,
              let followComponent = entity.component(ofType: FollowComponent.self),
              let spriteComponent = entity.component(ofType: SpriteComponent.self),
              let inteactionComponent = entity.component(ofType: InteractionComponent.self) else { return }

        let targetEntity = followComponent.target
        guard let targetSprite = targetEntity.component(ofType: SpriteComponent.self) else { return }

        let moveTo = targetSprite.node.position - (spriteComponent.origin / 10)

        spriteComponent.node.run(
            SKAction.move(to: moveTo, duration: 0.3)
        )

        inteactionComponent.node.run(
            SKAction.move(to: moveTo, duration: 0.3)
        )
    }
}
