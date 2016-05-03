//
//  CEOperation.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-29.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation

enum CEOperationState: Int {
    case Ready
    case Executing
    case Finished
}

func <(lhs: CEOperationState, rhs: CEOperationState) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

func ==(lhs: CEOperationState, rhs: CEOperationState) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

class CEOperation: NSOperation {
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state"]
    }

    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }

    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }

    override var finished: Bool {
        return state == .Finished
    }

    override var executing: Bool {
        return state == .Executing
    }

    override var ready: Bool {
        return (state == .Ready && super.ready) || cancelled
    }

    private let stateLock = NSLock()
    var _state: CEOperationState
    var state: CEOperationState {
        set (newState) {
            willChangeValueForKey("state")

            stateLock.withCriticalScope {
                guard _state != .Finished else {
                    return
                }
                _state = newState
            }
            didChangeValueForKey("state")
        }
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
    }

    override init() {
        _state = .Ready
        super.init()
    }

    override func addDependency(operation: NSOperation) {
        assert(state < .Executing, "Dependencies cannot be modified after execution has begun.")
        super.addDependency(operation)
    }
}

extension NSLock {
    func withCriticalScope<T>(@noescape block: Void -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}