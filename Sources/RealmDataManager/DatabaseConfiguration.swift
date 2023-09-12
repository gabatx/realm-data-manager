//
//  DatabaseConfiguration.swift
//  Movies
//
//  Created by gabatx on 7/9/23.
//

import Foundation
import RealmSwift

// Desde creamos la configuración desde AppInjection.swift que es la clase que gestiona las dependencias.
open class DatabaseConfiguration {
    private let _databaseName: String // Nombre que toma la base de datos
    let writeType : DatabaseWriteType // El tipo de escritura que vamos a tener
    let debug : DatabaseDebugVerbosity // El nivel de debug
    let schemaVersion : UInt64 // Versión del esquema
    // Array con las entidades que manejará una instancia concreta de base de datos. Cuando configuremos nuestra bd le diremos que tenemos una entidad movieDB. Si tuvieramos más entidades (tablas), deberiamos ir añadiendo en este array las entidades. Si tuviéramos una bd separada, con otras entidades, le podríamos indicar las otras entidades que tiene.
    let objectTypes: [ObjectBase.Type]?

    var databaseName: String {
        get {
            return "\(_databaseName).realm" // Asignamos desde aquí el nombre de la bd
        }
    }

    // Inicializamos el constructor que asignará los valores deseados
    public init(databaseName: String = "database",
                type: DatabaseWriteType = .disk,
                debug : DatabaseDebugVerbosity = .none,
                schemaVersion: UInt64 = 1,
                objectTypes: [ObjectBase.Type]? = nil
    ) {
        self._databaseName = databaseName
        self.writeType = type
        self.debug = debug
        self.schemaVersion = schemaVersion
        self.objectTypes = objectTypes
    }
}
