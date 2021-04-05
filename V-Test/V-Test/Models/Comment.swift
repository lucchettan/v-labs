//
//  Comment.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation

struct Comment: Codable, Hashable {
    let postId  :Int
    let id      : Int
    let name    : String
    let email   : String
    let body    : String
}

extension Comment {
    static let example = Comment(
        postId: 1,
        id: 1,
        name: "id labore ex et quam laborum",
        email: "Eliseo@gardner.biz",
        body: "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium"
    )
}
