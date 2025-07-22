//
//  DataSessionDelegate.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/15.
//

import CoreServices

final class DataSessionDelegate: NSObject, @unchecked Sendable {
    let onMetaData = ZonPlayer.Delegate<(URLSessionTask, ZPC.Streaming.MetaData), Void>()
    let onData = ZonPlayer.Delegate<(URLSessionTask, Data), Void>()
    let onFinished = ZonPlayer.Delegate<URLSessionTask, Void>()
    let onFailed = ZonPlayer.Delegate<(URLSessionTask, ZonPlayer.Error), Void>()
}

extension DataSessionDelegate: URLSessionDataDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                credential = URLCredential(trust: serverTrust)
                disposition = .useCredential
            }
        } else {
            disposition = .cancelAuthenticationChallenge
        }

        completionHandler(disposition, credential)
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if let metaData = response.__zon_metaData {
            onMetaData((dataTask, metaData))
            completionHandler(.allow)
        } else {
            onFailed((dataTask, .cacheFailed(.invalidStreamingResponse(response))))
            completionHandler(.cancel)
        }
    }

    /// We should not response segmented data like this:
    /// 
    /// ```swift
    /// if $0.count > _bufferSize {
    ///        onData.call((dataTask, $0))
    ///       $0 = Data()
    /// }
    /// ```
    ///
    /// Especially in poor network conditions, the video display may exhibit strange artifacts or corruption. 
    /// Additionally, even under normal network conditions, cached files may become damaged.
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) { onData((dataTask, data)) }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let originalError = error {
            let error = ZonPlayer.Error.cacheFailed(.streamingRequestFailed(task, originalError))
            onFailed((task, error))
        } else {
            onFinished(task)
        }
    }
}

extension URLResponse {
    fileprivate var __zon_metaData: ZPC.Streaming.MetaData? {
        let mimeType = mimeType ?? ""
        var isSupported = false
        for type in ["video/", "audio/", "application"] where mimeType.range(of: type) != nil {
            isSupported = true; break
        }

        let contentType = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassMIMEType,
            mimeType as CFString,
            nil
        )?.takeRetainedValue() as? String
        guard isSupported, let contentType else { return nil }

        var isByteRangeAccessSupported: Bool = false
        var contentLength: Int64 = expectedContentLength
        if let httpResponse = self as? HTTPURLResponse {
            let arKeys = ["Accept-Ranges", "accept-ranges", "Accept-ranges", "accept-Ranges"]
            let crKeys = ["Content-Range", "content-range", "Content-range", "content-Range"]
            for arKey in arKeys where (httpResponse.allHeaderFields[arKey] as? String) == "bytes" {
                isByteRangeAccessSupported = true
            }
            for crKey in crKeys {
                if let value = httpResponse.allHeaderFields[crKey] as? String,
                   let bytesInInt64 = Int64(value.split(separator: "/").last ?? "") {
                    contentLength = bytesInInt64
                }
            }
        }

        return .init(
            contentType: contentType,
            isByteRangeAccessSupported: isByteRangeAccessSupported,
            contentLength: Int(contentLength)
        )
    }
}
