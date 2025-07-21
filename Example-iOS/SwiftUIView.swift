//
//  SwiftUIView.swift
//  Example-iOS
//
//  Created by 李文康 on 2025/7/15.
//  Copyright © 2025 Shanbay iOS. All rights reserved.
//

import SwiftUI
import ZonPlayer
import AVKit

struct SwiftUIView: View {
    @State private var scale: ZonPlayerView.Scale = .resizeAspectFill
    @ObservedObject var player: ZonPlayer.SwiftUI
    init(url: URLConvertible) {
        self.player = .init(url: url)
    }

    var body: some View {
        let videoView = ZonPlayerViewSwiftUI(scale: $scale)
        VStack {
            videoView
                .onAppear {
                    player.activate(in: videoView)
                }
            Text("Progress：\(timeString(value: player.progress.current))/\(timeString(value: player.progress.total))")
            Button {
                if player.isPlaying {
                    player.player?.pause()
                    // scale = .resizeAspectFill
                } else {
                    player.player?.play()
                    // scale = .resizeAspect
                }
            } label: {
                player.isPlaying ? Text("Pause") : Text("Play")
            }
        }
    }
}

#Preview {
    SwiftUIView(url: "https://media-video1.baydn.com/tpfoundation/video-center/9a6725b69a67fa4296c5881017a44866.f68a88fd644ece717d28b1abebec370e.mp4")
        .frame(width: 300, height: 300)
        .background(Color.pink)
}
