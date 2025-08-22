//
//  Copyright © 2015 Apparata AB. All rights reserved.
//

import Foundation

open class Node {
    
    final weak var delegate: NodeDelegate?
    
    public final internal(set) var title: String
    
    public final internal(set) var inputs: [AbstractNodeInput]
    
    public final internal(set) var outputs: [AbstractNodeOutput]
    
    public final internal(set) var parameters: [AbstractNodeParameter]
    
    private var reevaluationNeeded: Bool = true
        
    public init(title: String, inputs: [AbstractNodeInput], outputs: [AbstractNodeOutput], parameters: [AbstractNodeParameter] = []) {
        self.title = title
        self.inputs = inputs
        self.outputs = outputs
        self.parameters = parameters

        for input in inputs {
            input.node = self
        }
        
        for output in outputs {
            output.node = self
        }
        
        for parameter in parameters {
            parameter.node = self
        }
    }
    
    /// Override. Set evaluated value for all outputs.
    open func evaluate() -> Bool {
        return true
    }
    
    final func performEvaluation() -> Bool {
        let result: Bool
        if reevaluationNeeded {
            reevaluationNeeded = false
            result = evaluate()
            delegate?.node(self, didEvaluateWithResult: result)
        } else {
            result = true
        }
        
        return result
    }
    
    final func reevaluate() {
        
        reevaluationNeeded = true
        
        var hasAtLeastOneConnectedOutput = false
        for output in outputs {
            for connection in output.connections {
                hasAtLeastOneConnectedOutput = true
                connection.input.node?.reevaluate()
            }
        }
        
        if hasAtLeastOneConnectedOutput {
            // Just pass on the reevaluation needed request
            // if there are connected outputs
        } else {
            // This is the end of a chain. The buck stops here.
            _ = performEvaluation()
        }
    }
    
    public final func index(of input: AbstractNodeInput) -> NSInteger? {
        for i in 0..<inputs.count {
            if input === inputs[i] {
                return i
            }
        }
        return 0
    }

    public final func index(of input: AbstractNodeOutput) -> NSInteger? {
        for i in 0..<outputs.count {
            if input === outputs[i] {
                return i
            }
        }
        return 0
    }

    public final func index(of input: AbstractNodeParameter) -> NSInteger? {
        for i in 0..<parameters.count {
            if input === parameters[i] {
                return i
            }
        }
        return 0
    }

}

extension Node: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs === rhs
}

protocol NodeDelegate: AnyObject {
    func node(_ node: Node, didEvaluateWithResult result: Bool)
}

