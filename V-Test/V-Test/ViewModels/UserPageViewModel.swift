//
//  UserPageViewModel.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation
import Combine
import OWOWKit

final class UserPageViewModel: ObservableObject {
    
    // MARK: State
     
    /// 🌌🔭 The user to start our researches on.
    let user: User
    
    /// 🗑 Combine cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// The user's albums.
    var albums : [Album] { albumsFetchState.result ?? [] }
    
    /// The progress of fetching the albums.
    @Published var albumsFetchState: OperationState<[Album], Error>
    
    /// The user's posts
    var posts : [Post] { postFetchState.result ?? [] }
    
    /// The progress of fetching the post.
    @Published var postFetchState: OperationState<[Post], Error>
    
    // MARK: Init
    
    /// 🌷
    init(user: User) {
        self.user = user
        self.albumsFetchState = .normal
        self.postFetchState = .normal
        
        fetchPosts(user: self.user)
        fetchAlbums(user: self.user)
    }
    
    // MARK: Preview content
    
    /// 👀
    init(forPreviews: ()) {
        self.user = User.example
        self.albumsFetchState = .normal
        self.postFetchState = .normal
        
        fetchPosts(user: self.user)
        fetchAlbums(user: self.user)
    }
    
    func fetchPosts(user: User) {
        NetWorkManager().getPostsFromUser(user: user)
            .convertToOperationState()
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.postFetchState, on: self)
            .store(in: &cancellables)
    }
    
    func fetchAlbums(user: User) {
        NetWorkManager().getAlbumFromUser(user: user)
            .convertToOperationState()
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.albumsFetchState, on: self)
            .store(in: &cancellables)
    }
}
