//
//  ZPFileStorable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

public typealias FileURL = URL
public typealias RemoteURL = URL

public struct File {
    public let location: FileURL
    public init(location: FileURL) {
        self.location = location
    }
}

public protocol ZPFileStorable {
    func create(file: File, with url: RemoteURL, completion: @escaping (Result<File, ZonPlayer.Error>) -> Void)
    func read(with url: RemoteURL) -> Result<File?, ZonPlayer.Error>
    func fileURL(url: RemoteURL) -> Result<FileURL, ZonPlayer.Error>
    func delete(with url: RemoteURL, completion: (() -> Void)?)
    func deleteAll(completion: (() -> Void)?)
}

extension ZPFileStorable {
    public func delete(with url: RemoteURL) {
        delete(with: url, completion: nil)
    }

    public func deleteAll() {
        deleteAll(completion: nil)
    }
}
