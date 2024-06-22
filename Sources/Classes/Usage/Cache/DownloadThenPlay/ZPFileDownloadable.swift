//
//  ZPFileDownloadable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

public protocol ZPFileDownloadable {
    var timeout: TimeInterval { get set }

    @discardableResult
    func download(
        with url: URL,
        destination: URL,
        completion: @escaping (Result<Void, ZonPlayer.Error>) -> Void
    ) -> ZPCCancellable
}
