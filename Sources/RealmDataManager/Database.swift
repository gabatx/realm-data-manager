//
//  Database.swift
//  Movies
//
//  Created by gabatx on 7/9/23.
//

import RealmSwift
import struct RealmSwift.SortDescriptor

public protocol Database: AnyObject {

    var database: Realm? { get } // Nuestra bd
    var configuration: DatabaseConfiguration { get } // Archivo de configuración

    // Función get que devolverá un listado. Utilizamos genéricos para que devuelva cualquier tipo
    // Result es una estructura que proporciona Realm. Es una especia de array supervitaminado con muchas más funciones.
    func get<T: Object>(type: T.Type) throws -> Results<T>
    func get<T: Object>(type: T.Type, query: ((Query<T>) -> Query<Bool>)) throws -> Results<T>

    // Se invoca de la misma manera que el get pero no devuelve nada
    func delete<T: Object>(type: T.Type) throws // Eliminar una colección entera
    func delete<T: Object>(type: T.Type, query: ((Query<T>) -> Query<Bool>)) throws // Elimina un elemento pasado por query

    // Recibirá una secuencia de objetos que deben implementar object
    func save<S: Sequence>(objects: S) throws where S.Iterator.Element: Object

    // Dos funciones de debug y un reset
    func debug(error: String)
    func debug(data: String)

    func reset()
}

// GET
public extension Database {

    // Obtiene todos los objetos de la colección
    func get<T:Object>(type: T.Type) throws -> Results<T> {
        // Verificamos que la bd no es nula.
        guard let database = database else {
            debug(error: DatabaseError.instanceNotAvailable.localizedDescription) // Indicamos que la instancia no está disponible
            throw DatabaseError.instanceNotAvailable // Si es nula lanzamos un error
        }
        // Para obtener todos los objetos utilizamos el método objects:
        // objects recibe un tipo y lo que va a hacer es obtener todos los objetos de una colección (en nuestro caso todas las películas)
        return database.objects(type)
    }

    // Función nos va a permitir hacer cualquier tipo de consultas. Toma una query para hacer una busqueda personalizada mediante un closure
    func get<T: Object>(type: T.Type, query: ((Query<T>) -> Query<Bool>)) throws -> Results<T> {
        guard let database = database else {
            debug(error: DatabaseError.instanceNotAvailable.localizedDescription)
            throw DatabaseError.instanceNotAvailable
        }
        // .where -> Método de objects que va a recibir una cosulta: (Query<T>) -> Query<Bool>)
        return database.objects(type).where(query)
    }
}

// DELETE
public extension Database {
     func delete<T: Object>(type: T.Type) throws {
        guard let database = database else {
            debug(error: DatabaseError.instanceNotAvailable.localizedDescription)
            throw DatabaseError.instanceNotAvailable
        }

        do {
            // Primero leemos los elementos que queremos eliminar
            try database.write {
                let results = database.objects(type)
                database.delete(results) // Una vez leidos los borramos todos
            }
        } catch(let e) {
            debug(error: e.localizedDescription)
            throw DatabaseError.cannotDeleteError
        }
    }

    func delete<T: Object>(type: T.Type, query: ((Query<T>) -> Query<Bool>)) throws {
        guard let database = database else {
            debug(error: DatabaseError.instanceNotAvailable.localizedDescription)
            throw DatabaseError.instanceNotAvailable
        }

        do {
            try database.write { // Leemos toda la bd
                let results = database.objects(type).where(query) // Borramos donde se cumpla la condición
                database.delete(results)
            }
        } catch(let e) {
            debug(error: e.localizedDescription)
            throw DatabaseError.cannotDeleteError
        }

    }
}

// SAVE
public extension Database {

    func save<S: Sequence>(objects: S) throws where S.Iterator.Element: Object {
        guard let database = database else {
            debug(error: DatabaseError.instanceNotAvailable.localizedDescription)
            throw DatabaseError.instanceNotAvailable

        }
        // .write: Lo que va a hacer es abrir un hilo seguro en el cual se va a poder realizar operaciones de escritura
        do {
            try database.write {
                debug(data: Array(objects).description)
                // .add: Aquí añadimos los objetos (objects)
                // update: .modified -> Cuando vengan registros con una primarykey repetida y se encuentre ids repetidos, lo que hará es sobreescribir la información de los repetidos
                database.add(objects, update: .modified)
            }
        } catch(let e) {
            debug(error: e.localizedDescription)
            throw DatabaseError.cannotSaveError
        }
    }
}

public extension Database {

    // Solo muestra con print la información de error que le entra

    // Error debug log wrapper para db
    func debug(error: String) {
        if configuration.debug == .all || configuration.debug == .error {
            print("Database Error> " + error)
        }
    }

    // Action debug log wrapper for db
    func debug(data: String) {
        if configuration.debug == .all || configuration.debug == .message {
            print("Database > " + data)
        }
    }

}
