//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

public protocol AbstractNodeInput: class {
    var node: Node? { get set }
    var title: String { get }
    var type: Any.Type { get }
    var value: Any? { get }
    var connection: NodeConnection? { get }
    var occupied: Bool { get }
    
    func attach(connection: NodeConnection?)
    func detach()
}

public final class NodeInput<T>: AbstractNodeInput {
    
    public weak var node: Node?
    
    public var type: Any.Type {
        return T.self
    }
    
    public private(set) var title: String
    
    public internal(set) var connection: NodeConnection? {
        didSet {
            if connection == nil {
                value = nil
            } else {
                notifyNodeInputDidChange()
            }
        }
    }
    
    public var occupied: Bool {
        return connection != nil
    }
    
    public internal(set) var defaultValue: Any?
    
    public var value: Any? {
        get {
            if let connection = connection {
                return connection.output.value ?? defaultValue
            }
            return actualValue ?? defaultValue
        }
        set {
            actualValue = newValue
            notifyNodeInputDidChange()
        }
    }
    
    private var actualValue: Any?
    
    public init(title: String, defaultValue: Any?) {
        self.title = title
        self.defaultValue = defaultValue
    }
    
    public func attach(connection: NodeConnection?) {
        self.connection = connection
    }
    
    public func detach() {
        connection = nil
    }
    
    private func notifyNodeInputDidChange() {
        node?.reevaluate()
    }
}

extension NodeInput: Equatable {
    
}

public func ==<T>(lhs: NodeInput<T>, rhs: NodeInput<T>) -> Bool {
    return lhs === rhs
}
