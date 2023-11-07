//
//  ZPDownloadBeforePlayback.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/6.
//

public final class ZPDownloadBeforePlayback: ZPCacheable {
    public let downloader: ZPURLDownloadable
    public let storage: ZPFileStorable
    public init(
        downloader: ZPURLDownloadable = ZPDefaultDownloader(timeout: 30),
        storage: ZPFileStorable = ZPDefaultStorage()
    ) {
        self.downloader = downloader
        self.storage = storage
    }

    public func prepare(url: URL, completion: @escaping (Result<AVURLAsset, ZonPlayer.Error>) -> Void) {
        if url.isFileURL { completion(.success(AVURLAsset(url: url))); return }

        switch storage.read(with: url) {
        case .success(let file):
            if let fileURL = file?.location {
                completion(.success(AVURLAsset(url: fileURL)))
            } else {
                switch storage.fileURL(url: url) {
                case .success(let destination):
                    downloader.download(
                        with: url,
                        destination: destination
                    ) {
                        switch $0 {
                        case .success:
                            completion(.success(AVURLAsset(url: destination)))
                        case .failure(let error):
                            // Error Domain=AVFoundationErrorDomain Code=-11849 "Operation Stopped"
                            // UserInfo={NSLocalizedFailureReason=This media may be damaged.
                            // NSLocalizedDescription=Operation Stopped
                            //
                            // Important: Remove item at destination if download failed.
                            try? FileManager.default.removeItem(at: destination)
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
