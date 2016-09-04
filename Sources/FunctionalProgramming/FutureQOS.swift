//
//  FutureQOS.swift
//  Blitter
//
//  Created by David Ungar on 8/31/16.
//
//

import Foundation

public enum FutureQOS {
    case main
    case userInteractive
    case userInitiated
    case `default`
    case utility
    case background
    
    
    public var queue: DispatchQueue {
        switch self {
        case .main:              return  DispatchQueue.main
        case .userInteractive:   return  DispatchQueue.global(qos: .userInteractive)
        case .userInitiated:     return  DispatchQueue.global(qos: .userInitiated  )
        case .default:           return  DispatchQueue.global(qos: .default        )
        case .utility:           return  DispatchQueue.global(qos: .utility        )
        case .background:        return  DispatchQueue.global(qos: .background     )
        }
    }
}
