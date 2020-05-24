//
//  RemoteUser.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import CoreData

struct RemoteUser: Decodable, CustomStringConvertible {
    /*
     important
     for local db be consistency with the remote server
     the results in api's order should be same as NSFetchedResultsController
     but unfortunately, the randomuser.me api does not support sort logic,
     so I create the fakeId locally only for demostration how to keep consistency
    */
    var fakeId: TypeOfId?
    
    let gender: Gender?
    let name: Name
    let location: Location
    let email: String?
    let login: Login
    let dob, registered: Dob
    let phone, cell: String?
    let id: ID
    let picture: Picture
    let nat: String?
    
    struct Dob: Decodable {
        let date: String?
        let age: Int?
    }

    struct ID: Decodable {
        let name, value: String?
    }

    struct Location: Decodable, CustomStringConvertible {
        let street: Street
        let city, state, country: String?
        let postcode: MetadataType?
        let coordinates: Coordinates
        let timezone: Timezone
        
        enum MetadataType: Codable {
          case int(Int)
          case string(String)

          init (from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                do {
                    self = try .int(container.decode(Int.self))
                } catch DecodingError.typeMismatch {
                    do {
                    self = try .string(container.decode(String.self))
                    } catch DecodingError.typeMismatch {
                    throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                    }
                }
          }

          func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .int(let int):
              try container.encode(int)
            case .string(let string):
              try container.encode(string)
            }
          }
        }

        var description: String {
            return ([street.number, street.name, city, state, country, postcode] as [Any?])
                .compactMap { $0 != nil ? "\($0 ?? "")" : nil }
                .joined(separator: " ")
        }
    }

    struct Coordinates: Decodable {
        let latitude, longitude: String?
    }

    struct Street: Decodable {
        let number: Int?
        let name: String?
    }

    struct Timezone: Decodable {
        let offset, timezoneDescription: String?

        enum CodingKeys: String, CodingKey {
            case offset
            case timezoneDescription = "description"
        }
    }

    struct Login: Decodable {
        let uuid: String
        let username, password, salt: String?
        let md5, sha1, sha256: String?
    }

    struct Name: Decodable {
        let title, first, last: String?
    }

    struct Picture: Decodable {
        let large, medium, thumbnail: String?
    }
    
    var description: String {
        return "{fakeId: \(fakeId ?? -1)}"
    }
}

extension RemoteUser: RemoteEntity {
    
    var uniqueId: TypeOfId {
        if let id = fakeId {
            return id
        }
        
        fatalError("id is nil")
    }
    
    func importInto<DBEntity>(_ entiry: DBEntity) where DBEntity : NSManagedObject {
        guard let user = entiry as? DBUser else { return }
        
        user.id = uniqueId
        
        user.title = name.title
        user.firstName = name.first
        user.lastName = name.last

        user.gender = gender?.rawValue
        user.dayOfBirth = dob.date

        user.pictureThumbnail = picture.thumbnail
        user.pictureLarge = picture.large

        user.cell = cell
        user.phone = phone
        user.email = email

        user.nationality = nat
        user.address = location.description
    }
}

enum Gender: String, Decodable {
    case female
    case male
}
