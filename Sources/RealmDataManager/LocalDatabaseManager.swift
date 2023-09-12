//
//  LocalDatabaseManager.swift
//  Movies
//
//  Created by gabatx on 7/9/23.
//

import Foundation
import RealmSwift
import Realm

// LocalDatabaseManager es la clase que sabe como instanciar una clase en local. En un futuro si se dice de hacer una para guardar en un servidor remoto con RealmSync ambos compartirán los mismos del protocolo.

// Clase que va a manejar nuestra db. Va a manejar tanto datos en disco como en memoria
public class LocalDatabaseManager: Database {
    
    //Las hago internas para que no estén disponibles hacia a fuera
    public var configuration: DatabaseConfiguration
    var _database: Realm?

    public init(configuration: DatabaseConfiguration) {
        self.configuration = configuration
    }

    // Definimos database con un getter
    public var database: Realm? {
        get {
            // Si database no existe la crea
            if _database == nil {
                do {
                    try self.configure()
                } catch(let e) {
                    debug(error: e.localizedDescription)
                }
            }
            return _database
        }
    }

    private func configure() throws {
        // ---- CONFIGURAMOS ----
        // Creamos el archivo de configuración (no es un objeto de DatabaseConfiguration).
        var dbConfiguration = Realm.Configuration()
        // Configuramos los casos que la escritura es en disco o en memoria
        switch configuration.writeType {
        case .disk:
            // Por defecto al instancia Configuration() (arriba: var dbConfiguration = Realm.Configuration()) la url ya se está seteando con un valor por defecto -> RLMRealmPathForFile("default.realm")
            // En nuestro caso le vamos a dar un nombre propio.
            // deletingLastPathComponent() -> Borra la ruta
            // appendingPathComponent -> Le indicamos el nombre de la bd
            guard let fileUrl = dbConfiguration.fileURL?.deletingLastPathComponent().appendingPathComponent(configuration.databaseName) else {
                // Si no se puede devolvemos un error de nuestro enum DatabaseError
                throw DatabaseError.databaseNameError
            }
            dbConfiguration.fileURL = fileUrl
        case .memory:
            // Solamente tenemos que indicar que la url será nulo. Al no tener url interpretará que es una base de datos con almacenado en memoria
            dbConfiguration.fileURL = nil
            // Le indicamos en el identificador el nombre de la bd
            dbConfiguration.inMemoryIdentifier = configuration.databaseName
        }

        dbConfiguration.objectTypes = configuration.objectTypes // Cuales son las entidades del modelo
        dbConfiguration.readOnly = false // Le decimos que no va a ser de solo lectura ya que queremos almacenar datos en nuestra bd
        dbConfiguration.schemaVersion = configuration.schemaVersion // La vesión del esquema

        // ---- AÑADIMOS ----
        do {
            // Creamos una instancia de Realm. Tiene varios constructores pero nosotros vamos a utilizar el que nos pide la configuración
            _database = try Realm(configuration: dbConfiguration)
        } catch (let e) {
            // En caso de error
            debug(error: e.localizedDescription)
        }
    }

    public func reset() {
        // Seteamos a nulo la bd
        _database = nil
    }
}
