//
//  AlbumView.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI

/// The view to display all photos from an album.
struct AlbumView: View {
    @ObservedObject var viewModel: AlbumViewModel
    let gridRows = [GridItem(), GridItem(),GridItem(),GridItem()]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridRows) {
                ForEach(viewModel.photos, id: \.self) { photo in
                    PhotoCellView(photo: photo)
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(viewModel.album.title)
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(viewModel: AlbumViewModel(forPreviews: ()))
    }
}
