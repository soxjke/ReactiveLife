//
//  Signal+Extensions.swift
//  ReactiveLife
//
//  Created by petr on 3/4/17.
//  Copyright © 2017 CocoaHeadsUkraine. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public extension SignalProtocol {
    public func skipError() -> Signal<Value, NoError> {
        return Signal { observer in
            return self.observe { event in
                switch(event) {
                case .value(let v): observer.send(value: v)
                case .failed(_): break
                case .interrupted: observer.sendInterrupted()
                case .completed: observer.sendCompleted()
                }
            }
        }
    }
}
