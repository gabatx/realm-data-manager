//
//  DatabaseWriteType.swift
//  Movies
//
//  Created by gabatx on 7/9/23.
//

import Foundation

// Puede haber dos tipos de escritura en la bd. En disco es lo normal, y en memoria se puede utilizar para tests
public enum DatabaseWriteType: String {
    case memory = "inMemory"
    case disk = "onDisk"
}
