import SpriteKit
import HLSpriteKit
import EZSwiftExtensions

class TetrisScene: SKScene {
    var background: SKSpriteNode!
    var tetrisGrid: HLGridNode!
    var tetrisBoard: TetrisBoard!
    var fallingTetrimino: Tetrimino!
    var isGameOver = false
    var scoreLabel: SKLabelNode!
    var bestScoreLabel: SKLabelNode!
    var gestureRecognizers: [UIGestureRecognizer] = []
    
    lazy var pauseOverlay: SKSpriteNode = {
        let overlay = SKSpriteNode(imageNamed: "bg")
        overlay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        overlay.zPosition = 2000
        
        let pausedLabel = SKSpriteNode(imageNamed: "pauseLabel")
        pausedLabel.position = CGPoint(x: 0, y: 400)
        pausedLabel.zPosition = 2001
        
        overlay.addChild(pausedLabel)
        
        let resumeButton = ButtonNode(imageNamed: "resumeButton")
        resumeButton.pressedTexture = SKTexture(imageNamed: "resumeButton_p")
        resumeButton.unpressedTexture = SKTexture(imageNamed: "resumeButton")
        resumeButton.callBackFirst = false
        resumeButton.zPosition = 2001
        resumeButton.onClick = {
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let unpauseAction = SKAction.run {
                [weak self] in
                overlay.removeFromParent()
                if let myself = self {
                    myself.background.isPaused = false
                    myself.gestureRecognizers.forEach { $1.isEnabled = true }
                }
            }
            overlay.run(SKAction.sequence([fadeOut, unpauseAction]))
        }
        overlay.addChild(resumeButton)
        
        let mainMenuButton = ButtonNode(imageNamed: "mainMenuButton")
        mainMenuButton.callBackFirst = false
        mainMenuButton.pressedTexture = SKTexture(imageNamed: "mainMenuButton_p")
        mainMenuButton.unpressedTexture = SKTexture(imageNamed: "mainMenuButton")
        mainMenuButton.position = CGPoint(x: 0, y: -100)
        mainMenuButton.zPosition = 2001
        mainMenuButton.onClick = {
            [weak self] in
            let scene = GameScene(fileNamed: "GameScene")!
            let transition = SKTransition.push(with: .right, duration: 0.5)
            scene.scaleMode = .aspectFit
            self?.view!.presentScene(scene, transition: transition)
        }
        overlay.addChild(mainMenuButton)
        
        return overlay
    }()
    
    override func didMove(to view: SKView) {
        background = self.childNode(withName: "bg") as! SKSpriteNode
        self.view?.ignoresSiblingOrder = true
        let anchorPoint = NSValue(cgPoint: CGPoint(x: 0.5, y: 0.5))
        let tableLayout = HLTableLayoutManager(columnCount: 1, columnWidths: [(0.0)], columnAnchorPoints: [anchorPoint], rowHeights: [(0.0)])!
        tableLayout.rowSeparator = 15
        background.hlSetLayoutManager(tableLayout)
        
        let scoreboardNode = SKSpriteNode(color: UIColor.yellow.withAlphaComponent(0.77), size: CGSize(width: 700, height: 160))
        scoreboardNode.zPosition = 1001
        
        scoreLabel = SKLabelNode(text: "SCORE:           0")
        scoreLabel.fontSize = 61
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontColor = UIColor.black
        scoreLabel.position = CGPoint(x: 10, y: 5)
        scoreboardNode.addChild(scoreLabel)
        
        bestScoreLabel = SKLabelNode(text: "")
        bestScoreLabel.fontSize = 61
        bestScoreLabel.horizontalAlignmentMode = .center
        bestScoreLabel.fontName = "Courier-Bold"
        bestScoreLabel.fontColor = UIColor.black
        bestScoreLabel.position = CGPoint(x: 10, y: -50)
        scoreboardNode.addChild(bestScoreLabel)
        
        background.addChild(scoreboardNode)
        
        tetrisGrid = HLGridNode(gridWidth: 10, squareCount: 200, anchorPoint: CGPoint(x: 0.5, y: 0.5), layoutMode: .fill, squareSize: CGSize(width: 50, height: 50), backgroundBorderSize: 0, squareSeparatorSize: 0)
        tetrisGrid.zPosition = 1000
        tetrisGrid.backgroundColor = UIColor.black
        tetrisGrid.squareColor = UIColor.black
        background.addChild(tetrisGrid)
        
        if !UserDefaults.standard.bool(forKey: "gestures") {
        
            let buttonGrid = HLGridNode(gridWidth: 6, squareCount: 6, anchorPoint: CGPoint(x: 0.5, y: 0.5), layoutMode: .fill, squareSize: CGSize(width: 100, height: 100), backgroundBorderSize: 0, squareSeparatorSize: 10)!
            buttonGrid.backgroundColor = UIColor.clear
            buttonGrid.squareColor = UIColor.clear
            
            let leftButton = ButtonNode(imageNamed: "leftButton")
            leftButton.pressedTexture = SKTexture(imageNamed: "leftButton_p")
            leftButton.unpressedTexture = SKTexture(imageNamed: "leftButton")
            leftButton.onClick = { [weak self] in self?.fallingTetrimino?.move(.left) }
            
            let rightButton = ButtonNode(imageNamed: "rightButton")
            rightButton.pressedTexture = SKTexture(imageNamed: "rightButton_p")
            rightButton.unpressedTexture = SKTexture(imageNamed: "rightButton")
            rightButton.onClick = { [weak self] in self?.fallingTetrimino?.move(.right) }
            
            let rotateButton = ButtonNode(imageNamed: "rotateButton")
            rotateButton.pressedTexture = SKTexture(imageNamed: "rotateButton_p")
            rotateButton.unpressedTexture = SKTexture(imageNamed: "rotateButton")
            rotateButton.onClick = { [weak self] in (self?.fallingTetrimino as? Rotatable)?.rotate() }
            
            let downButton = ButtonNode(imageNamed: "downButton")
            downButton.pressedTexture = SKTexture(imageNamed: "downButton_p")
            downButton.unpressedTexture = SKTexture(imageNamed: "downButton")
            downButton.onClick = { [weak self] in self?.fallingTetrimino?.moveDown() }
            
            let forcedDownButton = ButtonNode(imageNamed: "forcedDownButton")
            forcedDownButton.pressedTexture = SKTexture(imageNamed: "forcedDownButton_p")
            forcedDownButton.unpressedTexture = SKTexture(imageNamed: "forcedDownButton")
            forcedDownButton.onClick = { [weak self] in self?.fallingTetrimino?.forcedMoveDown() }
            
            let pauseButton = ButtonNode(imageNamed: "pauseButton")
            pauseButton.pressedTexture = SKTexture(imageNamed: "pauseButton_p")
            pauseButton.unpressedTexture = SKTexture(imageNamed: "pauseButton")
            pauseButton.callBackFirst = false
            pauseButton.onClick = { [weak self] in self?.pause() }
            
            buttonGrid.setContent([leftButton, rightButton, rotateButton, downButton, forcedDownButton, pauseButton])
            background.addChild(buttonGrid)
        }
        background.hlLayoutChildren()
        
        let rotateRecog = UITapGestureRecognizer(target: self, action: #selector(rotateRecognized))
        rotateRecog.numberOfTouchesRequired = 2
        gestureRecognizers.append(rotateRecog)
        for i in 1...10 {
            let leftRecog = UISwipeGestureRecognizer(target: self, action: #selector(moveLeftRecognized))
            leftRecog.numberOfTouchesRequired = i
            leftRecog.direction = .left
            gestureRecognizers.append(leftRecog)
            let rightRecog = UISwipeGestureRecognizer(target: self, action: #selector(moveRightRecognized))
            rightRecog.numberOfTouchesRequired = i
            rightRecog.direction = .right
            gestureRecognizers.append(rightRecog)
        }
        let downRecog = UISwipeGestureRecognizer(target: self, action: #selector(moveDownRecognized))
        downRecog.direction = .down
        downRecog.numberOfTouchesRequired = 1
        gestureRecognizers.append(downRecog)
        let forcedDownRecog = UISwipeGestureRecognizer(target: self, action: #selector(forcedDownRecognized))
        forcedDownRecog.direction = .down
        forcedDownRecog.numberOfTouchesRequired = 2
        gestureRecognizers.append(forcedDownRecog)
        gestureRecognizers.forEach {
            self.view?.addGestureRecognizer($0.1)
            if !UserDefaults.standard.bool(forKey: "gestures") {
                $0.1.isEnabled = false
            }
        }
        
        tetrisBoard = TetrisBoard(scene: self)
        bestScoreLabel.text = "BEST:\(String(tetrisBoard.bestScore).padLeft(length: 13))"
        tetrisBoard.addTetrimino()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            let scene = GameScene(fileNamed: "GameScene")!
            let transition = SKTransition.push(with: .right, duration: 0.5)
            scene.scaleMode = .aspectFit
            self.view!.presentScene(scene, transition: transition)
        } else {
            for touch in touches {
                let location = touch.location(in: self)
                if let button = self.nodes(at: location).first as? ButtonNode {
                    button.onTouch()
                }
            }
        }
    }
    
    func gameOver() {
        gestureRecognizers.forEach { $1.isEnabled = false }
        self.background.removeAllActions()
        self.fallingTetrimino = nil
        let gameOverBanner = SKSpriteNode(imageNamed: "gameOver")
        gameOverBanner.alpha = 0
        gameOverBanner.zPosition = 2000
        gameOverBanner.size = CGSize(width: 700, height: 336.5)
        gameOverBanner.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let finalScoreLabel = SKLabelNode(text: "SCORE:\(tetrisBoard.score)")
        finalScoreLabel.fontSize = 61
        finalScoreLabel.fontName = "Courier-Bold"
        finalScoreLabel.horizontalAlignmentMode = .center
        finalScoreLabel.fontColor = UIColor.black
        finalScoreLabel.position = CGPoint(x: 0, y: -50)
        finalScoreLabel.zPosition = 2001
        
        if tetrisBoard.score > tetrisBoard.bestScore {
            tetrisBoard.bestScore = tetrisBoard.score
            finalScoreLabel.position = CGPoint(x: 0, y: -70)
            let bestText = SKLabelNode(text: "NEW BEST SCORE!!")
            bestText.fontSize = 61
            bestText.fontName = "Courier-Bold"
            bestText.horizontalAlignmentMode = .center
            bestText.fontColor = UIColor.black
            bestText.position = CGPoint(x: 0, y: 0)
            bestText.zPosition = 2001
            gameOverBanner.addChild(bestText)
        }
        
        gameOverBanner.addChild(finalScoreLabel)
        
        addChild(gameOverBanner)
        let translucentNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.8), size: self.size)
        translucentNode.alpha = 0
        translucentNode.zPosition = 1999
        addChild(translucentNode)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let gameOverAction = SKAction.run { [weak self] in self?.isGameOver = true }
        let wait = SKAction.wait(forDuration: 0.2)
        gameOverBanner.run(SKAction.sequence([fadeIn, wait, gameOverAction]))
        translucentNode.run(fadeIn)
        
    }
    
    func pause() {
        gestureRecognizers.forEach { $1.isEnabled = false }
        self.background.isPaused = true
        pauseOverlay.alpha = 0
        self.addChild(pauseOverlay)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        pauseOverlay.run(fadeIn)
    }
    
    func rotateRecognized() {
        if let rotatable = self.fallingTetrimino as? Rotatable {
            rotatable.rotate()
        }
    }
    
    func moveLeftRecognized(sender: UISwipeGestureRecognizer) {
        for _ in 0..<sender.numberOfTouches {
            self.fallingTetrimino.move(.left)
        }
    }
    
    func moveRightRecognized(sender: UISwipeGestureRecognizer) {
        for _ in 0..<sender.numberOfTouches {
            self.fallingTetrimino.move(.right)
        }
    }
    
    func moveDownRecognized() {
        self.fallingTetrimino.moveDown()
    }
    
    func forcedDownRecognized() {
        self.fallingTetrimino.forcedMoveDown()
    }
}
