import SpriteKit

class ButtonNode: SKSpriteNode {
    var onClick: (() -> Void)?
    var unpressedTexture: SKTexture?
    var pressedTexture: SKTexture?
    var callBackFirst = true
    
    func onTouch() {
        let action = SKAction.animate(with: [pressedTexture!, unpressedTexture!], timePerFrame: 0.1)
        let callBack = SKAction.run {
            [weak self] in
            self?.onClick?()
        }
        
        if callBackFirst {
            let sequence = SKAction.sequence([callBack, action])
            self.run(sequence)
        } else {
            let sequence = SKAction.sequence([action, callBack])
            self.run(sequence)
        }
    }
}
