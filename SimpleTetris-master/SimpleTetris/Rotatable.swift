protocol Rotatable {
    func rotate()
    
    var rotationIndex: Int { get set }
    var numberOfRotations: Int { get }
}
