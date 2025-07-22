//
//  ZonPlayerView+SwiftUI.swift
//  ZonPlayer
//
//  Created by 李文康 on 2025/7/15.
//

import SwiftUI

public struct ZonPlayerViewSwiftUI: View {
    @Binding public var scale: ZonPlayerView.Scale
    let view: ZonPlayerView
    public init(scale: Binding<ZonPlayerView.Scale> = .constant(.resizeAspectFill)) {
        self._scale = scale
        self.view = ZonPlayerView()
    }

    public var playerLayer: AVPlayerLayer { view.playerLayer }

    public var body: some View {
        _Builder(scale: $scale, view: view)
    }

    private struct _Builder: UIViewRepresentable {
        @Binding var scale: ZonPlayerView.Scale
        let view: ZonPlayerView

        public func makeUIView(context: UIViewRepresentableContext<Self>) -> ZonPlayerView { view }

        public func updateUIView(_ uiView: ZonPlayerView, context: UIViewRepresentableContext<Self>) {
            uiView.scale = scale
        }
    }
}
