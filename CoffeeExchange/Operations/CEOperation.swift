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

class CEOperation: Operation {
    class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state"]
    }

    class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }

    class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }

    override var isFinished: Bool {
        return state == .Finished
    }

    override var isExecuting: Bool {
        return state == .Executing
    }

    override var isReady: Bool {
        return (state == .Ready && super.isReady) || isCancelled
    }

    private let stateLock = NSLock()
    var _state: CEOperationState
    var state: CEOperationState {
        set (newState) {
            willChangeValue(forKey: "state")

            stateLock.withCriticalScope {
                guard _state != .Finished else {
                    return
                }
                _state = newState
            }
            didChangeValue(forKey: "state")
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

    override func addDependency(_ operation: Operation) {
        assert(state < .Executing, "Dependencies cannot be modified after execution has begun.")
        super.addDependency(operation)
    }
}

extension NSLock {
    func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
