//
//  ZPFileStorable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

public struct File {
    public let location: URL
    public init(location: URL) {
        self.location = location
    }
}

public protocol ZPFileStorable {
    func create(file: File, with url: URL, completion: @escaping (Result<File, ZonPlayer.Error>) -> Void)
    func read(with url: URL) -> Result<File?, ZonPlayer.Error>
    func fileURL(url: URL) -> Result<URL, ZonPlayer.Error>
    func delete(with url: URL, completion: (() -> Void)?)
    func deleteAll(completion: (() -> Void)?)
}

extension ZPFileStorable {
    public func delete(with url: URL) {
        delete(with: url, completion: nil)
    }

    public func deleteAll() {
        deleteAll(completion: nil)
    }
}
