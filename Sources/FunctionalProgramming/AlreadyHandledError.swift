//
//  AlreadyHandledError.swift
//  Blitter
//
//  Created by David Ungar on 8/31/16.
//
//

import Foundation

public struct AlreadyHandledError: LocalizedError {
    public let error: Error
    public var errorDescription: String? {
        return "AlreadyHandledError \(error.localizedDescription)"
    }
}
