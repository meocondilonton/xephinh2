import HLSpriteKit

class OShapedTetrimino : Tetrimino {
    override var touchingSides: [TetrisBlock] {
        return [blocks[1], blocks[3]]
    }
    
    override init(tetrisBoard: TetrisBoard) throws {
        try super.init(tetrisBoard: tetrisBoard)
        let texture = SKTexture(imageNamed: "otetrimino")
        var shouldThrowError = false
        if tetrisBoard.tetrisBlocks[4][0] != nil ||
            tetrisBoard.tetrisBlocks[4][1] != nil ||
            tetrisBoard.tetrisBlocks[5][0] != nil ||
            tetrisBoard.tetrisBlocks[5][1] != nil {
            shouldThrowError = true
        }
        
        blocks = [
            TetrisBlock(x: 4, y: 0, texture: texture, tetrisBoard: tetrisBoard),
            TetrisBlock(x: 4, y: 1, texture: texture, tetrisBoard: tetrisBoard),
            TetrisBlock(x: 5, y: 0, texture: texture, tetrisBoard: tetrisBoard),
            TetrisBlock(x: 5, y: 1, texture: texture, tetrisBoard: tetrisBoard)
        ]
        tetrisBoard.syncModel()
        
        if shouldThrowError {
            throw TetrisBlockOverflow()
        }
    }
}
