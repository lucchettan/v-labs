//
//  PhotoCellView.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI
import URLImage

/// The view to display an image from a URL.
struct PhotoCellView: View {
    let photo: Photo
    
    var body: some View {
        if let url = URL(string: photo.url) {
            URLImageView(url: url)
                .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

struct URLImageView: View {
    let url: URL
    let id = UUID()

    init(url: URL) {
        self.url = url

        formatter = NumberFormatter()
        formatter.numberStyle = .percent
    }
    
    private let formatter: NumberFormatter // Used to format download progress as percentage. Note: this is only for example, better use shared formatter to avoid creating it for every view.
    
    var body: some View {
        URLImage(url: url,
                 options: URLImageOptions(
                    identifier: id.uuidString,      // Custom identifier
                    expireAfter: 300.0,             // Expire after 5 minutes
                    cachePolicy: .returnCacheElseLoad(cacheDelay: nil, downloadDelay: 0.5) // Return cached image or download after delay
                 ),
                 empty: {
                    Text("Nothing here")            // This view is displayed before download starts
                 },
                 inProgress: { progress -> Text in  // Display progress
                    if let progress = progress {
                        return Text(formatter.string(from: progress as NSNumber) ?? "Loading...")
                    }
                    else {
                        return Text("Loading...")
                    }
                 },
                 failure: { error, retry in         // Display error and retry button
                    VStack {
                        Text(error.localizedDescription)
                        Button("Retry", action: retry)
                    }
                 },
                 content: { image in                // Content view
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                 }
        )
    }
}

struct PhotoCellView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCellView(photo: .example)
    }
}
