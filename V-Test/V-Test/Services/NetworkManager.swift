//
//  NetworkManager.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation
import Combine
import OWOWKit

class NetWorkManager {
    /// The URL session used by the API client.
    var urlSession = URLSession.shared
    var apiUrl = "https://jsonplaceholder.typicode.com/"
    
    func tryFlatMap<P: Publisher>(_ transform: @escaping () throws -> P) -> AnyPublisher<P.Output, Error> {
        Just<Void>(())
            .setFailureType(to: Error.self)
            .flatMap { _ -> AnyPublisher<P.Output, Error> in
                do {
                    return try transform()
                        .mapError { $0 as Error }
                        .eraseToAnyPublisher()
                } catch {
                    return Fail<P.Output, Error>(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func getUsers() -> AnyPublisher<[User], Error> {
        return tryFlatMap { () -> AnyPublisher<[User], Error> in
            let request = try URLRequest(
                request: Get(),
                url: self.apiUrl + "users"
            )
            
            return self
                .urlSession.responsePublisher(for: request, responseBody: [User].self)
                .map { (response: Response<[User]>) -> [User] in response.body }
                .eraseToAnyPublisher()
        }
    }
    
    func getAlbumFromUser(user: User) -> AnyPublisher<[Album], Error> {
        return tryFlatMap { () -> AnyPublisher<[Album], Error> in
            let request = try URLRequest(
                request: Get(),
                url: self.apiUrl + "users/\(user.id)/Albums"
            )
            
            return self
                .urlSession.responsePublisher(for: request, responseBody: [Album].self)
                .map { (response: Response<[Album]>) -> [Album] in response.body }
                .eraseToAnyPublisher()
        }
    }
    
    func getPhotosFromAlbum(album: Album) -> AnyPublisher<[Photo], Error> {
        return tryFlatMap { () -> AnyPublisher<[Photo], Error> in
            let request = try URLRequest(
                request: Get(),
                url: self.apiUrl + "albums/\(album.id)/Photos"
            )
            
            return self
                .urlSession.responsePublisher(for: request, responseBody: [Photo].self)
                .map { (response: Response<[Photo]>) -> [Photo] in response.body }
                .eraseToAnyPublisher()
        }
    }
    
    func getPostsFromUser(user: User) -> AnyPublisher<[Post], Error> {
        return tryFlatMap { () -> AnyPublisher<[Post], Error> in
            let request = try URLRequest(
                request: Get(),
                url: self.apiUrl + "users/\(user.id)/Posts"
            )
            
            return self
                .urlSession.responsePublisher(for: request, responseBody: [Post].self)
                .map { (response: Response<[Post]>) -> [Post] in response.body }
                .eraseToAnyPublisher()
        }
    }
    
    func getCommentsFromPost(post: Post) -> AnyPublisher<[Comment], Error> {
        return tryFlatMap { () -> AnyPublisher<[Comment], Error> in
            let request = try URLRequest(
                request: Get(),
                url: self.apiUrl + "posts/\(post.id)/comments"
            )
            
            return self
                .urlSession.responsePublisher(for: request, responseBody: [Comment].self)
                .map { (response: Response<[Comment]>) -> [Comment] in response.body }
                .eraseToAnyPublisher()
        }
    }
    
    func sendComment(comment: Comment) {
        let url = URL(string: self.apiUrl + "/comments")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let commentString = "postId=\(comment.postId)&id=\(comment.id)&name=\(comment.name)&email=\(comment.email)&body=\(comment.body)"
        request.httpBody = commentString.data(using: String.Encoding.utf8)
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error posting comment \(comment)\n Error = \(error.localizedDescription)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
            
            if let response = response {
                print("Response:")
                print(response.suggestedFilename as Any)
            }
        }
        
        task.resume()
    }
}
