//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

public enum NodeConnectionError: Error {
    case invalidConnection
}

public final class NodeConnection {
    
    public private(set) var output: AbstractNodeOutput
    
    public private(set) var input: AbstractNodeInput
    
    public static func canConnect(_ output: AbstractNodeOutput, to input: AbstractNodeInput) -> Bool {
 
        if input.occupied {
            return false
        }
        
        // Can't connect to same node.
        if input.node === output.node {
            return false
        }
        
        if input.type != output.type {
            return false
        }
        
        return true
    }
    
    public static func connect(_ output: AbstractNodeOutput, to input: AbstractNodeInput) throws -> NodeConnection {
        guard NodeConnection.canConnect(output, to: input) else {
            throw NodeConnectionError.invalidConnection
        }
        
        let connection = NodeConnection(output: output, input: input)
        output.addConnection(connection)
        input.attach(connection: connection)
        
        return connection
    }
    
    private init(output: AbstractNodeOutput, input: AbstractNodeInput) {
        self.output = output
        self.input = input
    }
}

extension NodeConnection: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public func ==(lhs: NodeConnection, rhs: NodeConnection) -> Bool {
    return lhs === rhs
}
