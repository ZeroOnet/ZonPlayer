//
//  ZPCStreamingPluggable.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/15.
//

public protocol ZPCStreamingPluggable {
    func prepare(_ request: URLRequest, forRange range: NSRange) -> URLRequest
    func willSend(_ request: URLRequest, forRange range: NSRange)
    func didReceive(_ data: Data, forURL url: URL, withRange range: NSRange, fromRemote remoteFlag: Bool)
    func didReceive(_ metaData: ZPC.MetaData, forURL url: URL, fromRemote remoteFlag: Bool)
    func didComplete(
        _ result: Result<Void,
        ZonPlayer.Error>,
        forURL url: URL,
        withRange range: NSRange,
        fromRemote remoteFlag: Bool
    )
    func anErrorOccurred(in storage: ZPCDataStorable, _ error: ZonPlayer.Error)
}

extension ZPCStreamingPluggable {
    public func prepare(_ request: URLRequest, forRange range: NSRange) -> URLRequest { request }
    public func willSend(_ request: URLRequest, forRange range: NSRange) {}
    public func didReceive(_ data: Data, forURL url: URL, withRange range: NSRange, fromRemote remoteFlag: Bool) {}
    public func didReceive(_ metaData: ZPC.MetaData, forURL url: URL, fromRemote remoteFlag: Bool) {}
    public func didComplete(
        _ result: Result<Void,
        ZonPlayer.Error>,
        forURL url: URL,
        withRange range: NSRange,
        fromRemote remoteFlag: Bool
    ) {}
    public func anErrorOccurred(in storage: ZPCDataStorable, _ error: ZonPlayer.Error) {}
}
