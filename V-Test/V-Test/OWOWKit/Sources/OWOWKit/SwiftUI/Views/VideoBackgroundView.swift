//
//  VideoBackgroundView.swift
//  Duco
//
//  Created by Robbert Brandsma on 07/10/2019.
//  Copyright © 2019 OWOW. All rights reserved.
//

import SwiftUI

/// A view that plays a video in a loop.
@available(iOS 13.0, *)
public struct VideoBackgroundView: View {
    
    /// The URL of the video being played.
    let videoURL: URL
    
    /// 🌷
    /// - parameter videoURL: The URL of the video being played.
    public init(videoURL: URL) {
        self.videoURL = videoURL
    }
    
    public var body: some View {
        VideoBackgroundViewControllerRepresentable(videoURL: videoURL)
    }
    
}

/// An implementation detail of `VideoBackgroundView`.
@available(iOS 13.0, *)
fileprivate struct VideoBackgroundViewControllerRepresentable: UIViewControllerRepresentable {
    
    /// The URL of the video being played.
    let videoURL: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoBackgroundViewControllerRepresentable>) -> VideoBackgroundViewController {
        return VideoBackgroundViewController(videoURL: videoURL)
    }
    
    func updateUIViewController(_ uiViewController: VideoBackgroundViewController, context: UIViewControllerRepresentableContext<VideoBackgroundViewControllerRepresentable>) {}
    
}

@available(iOS 13.0, *)
struct VideoBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        VideoBackgroundViewControllerRepresentable(
            videoURL: Bundle.main.url(forResource: "Landing", withExtension: "mp4")!
        )
    }
}
