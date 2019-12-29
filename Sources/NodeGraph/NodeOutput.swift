//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

public protocol AbstractNodeOutput: class {
    var node: Node? { get set }
    var title: String { get }
    var type: Any.Type { get }
    var value: Any? { get }
    var connections: Set<NodeConnection> { get }
    
    func addConnection(_ connection: NodeConnection)
    func removeConnection(_ connection: NodeConnection)
}

public enum NodeOutputError: Error {
    case invalidType
}

public final class NodeOutput<T>: AbstractNodeOutput {
    
    public weak var node: Node?
    
    public var type: Any.Type {
        return T.self
    }
    
    public private(set) var title: String
    
    public private(set) var connections: Set<NodeConnection> = Set<NodeConnection>()
    
    private var evaluatedValue: Any?
    
    public var value: Any? {
                
        let successfullyEvaluated = node?.performEvaluation() ?? false
        if successfullyEvaluated {
            return evaluatedValue
        } else {
            return nil
        }
    }
    
    public init(title: String) {
        self.title = title
    }
    
    public func addConnection(_ connection: NodeConnection) {
        connections.insert(connection)
    }
    
    public func removeConnection(_ connection: NodeConnection) {
        connections.remove(connection)
    }
    
    public func setEvaluatedValue(_ value: Any) throws {
        
        // We are going to do some dirty stuff here since reflection
        // in Swift 3 won't let us access the type info for the generic
        // type T in an Optional<T>. We will compare strings! Sorry!
        
        let typeString = String(describing: type)
        let valueTypeString = String(describing: Swift.type(of: value))
        
        if typeString == valueTypeString {
            // In this case, we are good.
        } else if typeString == "Optional<\(valueTypeString)>" {
            // In this case, we are also good.
        } else if "Optional<\(typeString)>" == valueTypeString {
            // Not sure if this will ever happen, but let it pass.
        } else {
            throw NodeOutputError.invalidType
        }
        
        evaluatedValue = value
    }
}

extension NodeOutput: Equatable {
    
}

public func ==<T>(lhs: NodeOutput<T>, rhs: NodeOutput<T>) -> Bool {
    return lhs === rhs
}
