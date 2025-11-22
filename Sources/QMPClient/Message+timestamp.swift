//
//  Message+timestamp.swift
//  QMPClient
//
//  Created by Oliver Epper on 22.11.25.
//


import Foundation
import Network

extension NWProtocolFramer.Message {
    private static let timestampKey = "timestamp"

    var timestamp: Date? {
        get { self[Self.timestampKey] as? Date }
        set { self[Self.timestampKey] = newValue }
    }
}
