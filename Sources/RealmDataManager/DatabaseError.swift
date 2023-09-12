//
//  DatabaseError.swift
//  Movies
//
//  Created by gabatx on 7/9/23.
//

import Foundation

// Nos da  los distintos errores que podemos tener al manejar la bd
enum DatabaseError: Error {
    case databaseNameError
    case configurationError
    case instanceNotAvailable
    case cannotSaveError
    case cannotDeleteError
}
