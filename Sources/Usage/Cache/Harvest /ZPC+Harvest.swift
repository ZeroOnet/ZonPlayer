//
//  ZPC+Harvest.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/6.
//

extension ZPC {
    /// Download then play.
    public final class Harvest: ZonPlayer.Cacheable {
        public protocol Cancellable {
            var isCancelled: Bool { get }

            /// Cancel an in-process operation.
            func cancel()
        }

        public protocol FileDownloadable {
            var timeout: TimeInterval { get set }

            @discardableResult
            func download(
                with url: URL,
                destination: URL,
                completion: @escaping (Result<Void, ZonPlayer.Error>) -> Void
            ) -> Cancellable
        }

        public typealias FileURL = URL
        public typealias RemoteURL = URL

        public struct File {
            public let location: FileURL
            public init(location: FileURL) {
                self.location = location
            }
        }

        public protocol FileStorable {
            func create(file: File, with url: RemoteURL, completion: @escaping (Result<File, ZonPlayer.Error>) -> Void)
            func read(with url: RemoteURL) -> Result<File?, ZonPlayer.Error>
            func fileURL(url: RemoteURL) -> Result<FileURL, ZonPlayer.Error>
            func delete(with url: RemoteURL, completion: (() -> Void)?)
            func deleteAll(completion: (() -> Void)?)
        }

        public let downloader: FileDownloadable
        public let storage: FileStorable
        public init(
            downloader: FileDownloadable = DefaultFileDownloader(timeout: 30),
            storage: FileStorable = DefaultFileStorage()
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
}

extension ZPC.Harvest.FileStorable {
    public func delete(with url: ZPC.Harvest.RemoteURL) {
        delete(with: url, completion: nil)
    }

    public func deleteAll() {
        deleteAll(completion: nil)
    }
}
