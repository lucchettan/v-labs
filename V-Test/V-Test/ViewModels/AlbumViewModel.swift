//
//  AlbumViewModel.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation
import Combine
import OWOWKit

final class AlbumViewModel: ObservableObject {
    
    // MARK: State
    
    /// 🌌🔭 The album to start our researches on.
    let album: Album
    
    /// 🗑 Combine cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// The album's photos.
    var photos: [Photo] { photosFetchState.result ?? [] }
    
    /// The progress of fetching the photos.
    @Published var photosFetchState: OperationState<[Photo], Error>

    // MARK: Init
    
    /// 🌷
    init(album: Album) {
        self.album = album
        self.photosFetchState = .normal
        fetchPhotos()
    }
    
    // MARK: Preview content
    
    /// 👀
    init(forPreviews: ()) {
        self.album = .example
        self.photosFetchState = .normal
        self.fetchPhotos()
    }
    
    func fetchPhotos() {
        NetWorkManager().getPhotosFromAlbum(album: self.album)
            .convertToOperationState()
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.photosFetchState, on: self)
            .store(in: &cancellables)
    }
}
