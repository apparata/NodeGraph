//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

public protocol AbstractNodeParameter: class {
    var node: Node? { get set }
    var title: String { get }
    var type: Any.Type { get }
    var value: Any? { get }
}

// The node parameter is a variable that can be used by the
// evaluation function of the node.
public final class NodeParameter<T>: AbstractNodeParameter {
    
    public weak var node: Node?
    
    public var type: Any.Type {
        return T.self
    }
    
    public private(set) var title: String
    
    public internal(set) var defaultValue: Any?
    
    public var value: Any? {
        get {
            return actualValue ?? defaultValue
        }
        set {
            actualValue = newValue
            notifyNodeParameterDidChange()
        }
    }
    
    private var actualValue: Any?
    
    public init(title: String, defaultValue: Any?) {
        self.title = title
        self.defaultValue = defaultValue
    }
    
    private func notifyNodeParameterDidChange() {
        node?.reevaluate()
    }
}

extension NodeParameter: Equatable {
    
}

public func ==<T>(lhs: NodeParameter<T>, rhs: NodeParameter<T>) -> Bool {
    return lhs === rhs
}
