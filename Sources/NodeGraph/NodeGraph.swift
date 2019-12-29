//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

public final class NodeGraph {
    
    public weak var delegate: NodeGraphDelegate?
    
    public private(set) var nodes: Set<Node>
    
    public private(set) var connections: Set<NodeConnection>
    
    public init() {
        nodes = Set<Node>()
        connections = Set<NodeConnection>()
    }
    
    public func addNode(_ node: Node) {
        nodes.insert(node)
        node.delegate = self
        delegate?.nodeGraph(self, didAddNode: node)
    }
    
    public func removeNode(_ node: Node) {
        removeAllConnectionsFromNode(node)
        nodes.remove(node)
        delegate?.nodeGraph(self, didRemoveNode: node)
    }
    
    public func removeAllConnectionsFromNode(_ node: Node) {
        for input in node.inputs {
            if let connection = input.connection {
                removeConnection(connection)
            }
        }
        
        for output in node.outputs {
            for connection in output.connections {
                removeConnection(connection)
            }
        }
    }
    
    @discardableResult
    public func connect(_ output: AbstractNodeOutput, to input: AbstractNodeInput) throws -> NodeConnection {
        let connection = try NodeConnection.connect(output, to: input)
        connections.insert(connection)
        delegate?.nodeGraph(self, didAddConnection: connection)
        return connection
    }
    
    public func removeConnection(_ connection: NodeConnection) {
        connection.output.removeConnection(connection)
        connection.input.detach()
        connections.remove(connection)
        delegate?.nodeGraph(self, didRemoveConnection: connection)
    }
}

extension NodeGraph: NodeDelegate {
    func node(_ node: Node, didEvaluateWithResult result: Bool) {
        delegate?.nodeGraph(self, didEvaluateNode: node, result: result)
    }
}

public protocol NodeGraphDelegate: class {
    func nodeGraph(_ nodeGraph: NodeGraph, didAddNode node: Node)
    func nodeGraph(_ nodeGraph: NodeGraph, didRemoveNode node: Node)
    func nodeGraph(_ nodeGraph: NodeGraph, didAddConnection connection: NodeConnection)
    func nodeGraph(_ nodeGraph: NodeGraph, didRemoveConnection connection: NodeConnection)
    func nodeGraph(_ nodeGraph: NodeGraph, didEvaluateNode node: Node, result: Bool)
}
