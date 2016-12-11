

class TetrisUtility {
    private init() {}
    
    static func rotateClockwise(x: inout Int, y: inout Int) {
        let temp = y
        y = x
        x = -temp
    }
    
    static func rotateAnticlockwise(x: inout Int, y: inout Int) {
        let temp = x
        x = y
        y = -temp
    }
    
    static func tryRotate(_ tetrimino: Tetrimino, clockwiseAbout rotationPointBlockIndex: Int) -> Bool {
        return tryRotate(tetrimino, about: rotationPointBlockIndex, withClosure: rotateClockwise)
    }
    
    static func tryRotate(_ tetrimino: Tetrimino, anticlockwiseAbout rotationPointBlockIndex: Int) -> Bool {
        return tryRotate(tetrimino, about: rotationPointBlockIndex, withClosure: rotateAnticlockwise)
    }
    
    private static func tryRotate(_ tetrimino: Tetrimino, about rotationPointBlockIndex: Int, withClosure closure: (inout Int, inout Int) -> Void) -> Bool {
        var finalPositionsValid = [Bool]()
        let rotationBlock = tetrimino.blocks[rotationPointBlockIndex]
        
        // relative coordinates
        var x1 = tetrimino.blocks[0].x - rotationBlock.x
        var y1 = tetrimino.blocks[0].y - rotationBlock.y
        var x2 = tetrimino.blocks[1].x - rotationBlock.x
        var y2 = tetrimino.blocks[1].y - rotationBlock.y
        var x3 = tetrimino.blocks[2].x - rotationBlock.x
        var y3 = tetrimino.blocks[2].y - rotationBlock.y
        var x4 = tetrimino.blocks[3].x - rotationBlock.x
        var y4 = tetrimino.blocks[3].y - rotationBlock.y
        
        closure(&x1, &y1)
        closure(&x2, &y2)
        closure(&x3, &y3)
        closure(&x4, &y4)
        
        let absoluteCoordinates = [
            (rotationBlock.x + x1, rotationBlock.y + y1),
            (rotationBlock.x + x2, rotationBlock.y + y2),
            (rotationBlock.x + x3, rotationBlock.y + y3),
            (rotationBlock.x + x4, rotationBlock.y + y4)
        ]
        
        for i in 0..<4 {
            if i != rotationPointBlockIndex {
                finalPositionsValid.append(tetrimino.isPositionValid(x: absoluteCoordinates[i].0, y: absoluteCoordinates[i].1))
            }
        }
        
        if !finalPositionsValid.contains(false) {
            for i in 0..<4 {
                tetrimino.blocks[i].node.removeFromParent()
                tetrimino.blocks[i].setXY(absoluteCoordinates[i].0, absoluteCoordinates[i].1)
            }
            tetrimino.updatePosition()
            return true
        }
        return false
    }
}
