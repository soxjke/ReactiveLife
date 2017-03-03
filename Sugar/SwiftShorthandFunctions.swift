//
//  File.swift
//  SuavooClient
//
//  Created by petr on 12/24/16.
//  Copyright © 2016 Suavoo. All rights reserved.
//

public func unwrap<T>(_ value: T?, onSuccess: ((T) -> Void)? = nil) {
    if let value = value { if let onSuccess = onSuccess { onSuccess(value) }}
}

public func failableUnwrap<T>(_ value: T?) -> T {
    return value!
}

@discardableResult public func cast<From, To>(_ value: From?, targetType: To.Type? = nil, onSuccess: ((To) -> Void)? = nil) -> To? {
    guard let value = value as? To else { return nil}
    unwrap(onSuccess) { $0(value) }
    return value
}

public func failableCast<From, To>(_ value: From?, targetType: To.Type? = nil) -> To {
    return value as! To
}

enum TypeDispatcher<ValueType> {
    case value(ValueType)
    
    @discardableResult func dispatch<Subject>(_ closure: (Subject) -> ()) -> TypeDispatcher<ValueType> {
        switch self {
        case .value(let value):
            cast(value).map(closure)
            return .value(value)
        }
    }
    
    func extract() -> ValueType {
        switch self {
        case .value(let value):
            return value
        }
    }
}
