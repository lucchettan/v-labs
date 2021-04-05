//
//  User.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation

struct User: Codable, Hashable {
    let id                      : Int
    let name, username, email   : String
    let address                 : Address
    let phone, website          : String
    let company                 : Company
}

struct Address: Codable, Hashable {
    let street, suite, city, zipcode: String
    let geo: Geo
}

struct Geo: Codable, Hashable {
    let lat, lng: String
}

struct Company: Codable, Hashable {
    let name, catchPhrase, bs: String
}

extension User {
    static let example = User(
        id: 2,
        name: "Ervin Howell",
        username: "Antonette",
        email: "Shanna@melissa.tv",
        address: Address(
            street: "Victor Plains",
            suite: "Suite 879",
            city: "Wisokyburgh",
            zipcode: "90566-7771",
            geo: Geo(lat: "-43.9509", lng: "-34.4618")),
        phone: "010-692-6593 x09125",
        website: "anastasia.net",
        company: Company(
            name: "Deckow-Crist",
            catchPhrase: "Proactive didactic contingency",
            bs: "synergize scalable supply-chains"
        )
    )
}
