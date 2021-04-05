//
//  PostsViewModel.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation
import Combine
import OWOWKit

final class PostViewModel: ObservableObject {
    
    // MARK: State
    
    /// 🌌🔭 The post to start our researches on.
    let post: Post
    
    /// 🗑 Combine cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// The post comments.
    var comments: [Comment] { commentsFetchState.result ?? [] }
    
    /// The progress of fetching the comments.
    @Published var commentsFetchState: OperationState<[Comment], Error>

    /// Bool Value to display the modal.
    @Published var isDisplayinComments = false
    
    // MARK: Init
    
    /// 🌷
    init(post: Post) {
        self.post = post
        self.commentsFetchState = .normal
        fetchComments()
    }
    
    // MARK: Preview content
    
    /// 👀
    init(forPreviews: ()) {
        self.post = .example
        self.commentsFetchState = .normal
        self.fetchComments()
    }
    
    func fetchComments() {
        NetWorkManager().getCommentsFromPost(post: self.post)
            .convertToOperationState()
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.commentsFetchState, on: self)
            .store(in: &cancellables)
    }
    
    func tapModal(){
        self.isDisplayinComments.toggle()
    }
    
    func sendComment(comment: Comment){
        NetWorkManager().sendComment(comment: comment)
    }
}
