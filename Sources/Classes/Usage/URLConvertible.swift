//
//  URLConvertible.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

public protocol URLConvertible {
    func asURL() throws -> URL
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw ZonPlayer.Error.invalidURL(self) }
        return url
    }
}

extension URL: URLConvertible {
    public func asURL() throws -> URL { self }
}

extension URLComponents: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = url else { throw ZonPlayer.Error.invalidURL(self) }
        return url
    }
}
