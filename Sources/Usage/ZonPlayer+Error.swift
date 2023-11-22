//
//  ZonPlayer+Error.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

extension ZonPlayer {
    public enum Error: Swift.Error {
        /// The reason for player terminated.
        ///
        /// - Important: Play cannot resume and should be recreated at the moment.
        public enum TerminationReason {
            case mediaServicesWereReset
            /// The status of AVPlayer is failed with an error.
            case playerError(Swift.Error)
            /// The status of AVPlayer is failed without any error.
            case unknownError
        }

        public enum CacheFailureReason {
            case downloadFailed(URL, Swift.Error)
            case createCacheDirectoryFailed(URL)
            case fileStoreFailed(URL, Swift.Error)
            case downloadExplicitlyCancelled(URL)
            case streamingRequestCancelled(URL?)
            case streamingStorageCreateFileHandleFailed(URL, Swift.Error)
            case streamingStorageWriteFailed(URL, Data, NSRange, Swift.Error)
            case streamingStorageReadFailed(URL, NSRange, Swift.Error)
            case streamingStorageSaveMetaDataFailed(URL, ZPC.MetaData, Swift.Error)
            case streamingStorageReleaseFailed(URL, Swift.Error)
            case streamingStorageCleanFailed(URL, Swift.Error)
            case invalidDataFromStreamingStorage(URL, NSRange)
            case streamingRequestFailed(URLSessionTask, Swift.Error)
            case invalidStreamingResponse(URLResponse)
        }

        case invalidURL(URLConvertible)
        case sessionError(ZPSessionable, Swift.Error)
        case playerTerminated(TerminationReason)
        case cacheFailed(CacheFailureReason)

        public var isTerminated: Bool {
            guard case .playerTerminated = self else { return false }
            return true
        }

        public var isCancelled: Bool {
            guard case .cacheFailed(let reason) = self else {
                return false
            }

            switch reason {
            case .downloadExplicitlyCancelled, .streamingRequestCancelled:
                return true
            default: return false
            }
        }
    }
}

extension ZonPlayer.Error: CustomNSError {
    public static var errorDomain: String { "com.zonplayer.error" }

    public var errorCode: Int {
        switch self {
        case .invalidURL:
            return 20091
        case .sessionError:
            return 20092
        case .playerTerminated(let reason):
            switch reason {
            case .mediaServicesWereReset:
                return 200931
            case .playerError(let error):
                return (error as NSError).code
            case .unknownError:
                return 200932
            }
        case .cacheFailed(let reason):
            switch reason {
            case .downloadFailed(_, let error),
                 .fileStoreFailed(_, let error),
                 .streamingStorageCreateFileHandleFailed(_, let error),
                 .streamingStorageWriteFailed(_, _, _, let error),
                 .streamingStorageReadFailed(_, _, let error),
                 .streamingStorageSaveMetaDataFailed(_, _, let error),
                 .streamingStorageReleaseFailed( _, let error),
                 .streamingStorageCleanFailed(_, let error),
                 .streamingRequestFailed(_, let error):
                return (error as NSError).code
            case .downloadExplicitlyCancelled,
                    .streamingRequestCancelled:
                return NSURLErrorCancelled
            case .createCacheDirectoryFailed:
                return 200941
            case .invalidDataFromStreamingStorage:
                return 200942
            case .invalidStreamingResponse:
                return NSURLErrorResourceUnavailable
            }
        }
    }

    public var errorUserInfo: [String: Any] {
        [NSLocalizedDescriptionKey: errorDescription.unsafelyUnwrapped]
    }
}

extension ZonPlayer.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let uct):
            return "\(uct) cannot convert to URL."
        case let .sessionError(session, error):
            return "Audio session \(session) apply failed: \(error)."
        case .cacheFailed(let reason):
            return "\(reason)"
        case .playerTerminated(let reason):
            return "Swifty player terminated: \(reason)"
        }
    }
}

extension ZonPlayer.Error.TerminationReason: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mediaServicesWereReset:
            return "System media services were reset."
        case .playerError(let error):
            return "A player error occurred: \(error)."
        case .unknownError:
            return "Unknown error occurred."
        }
    }
}

extension ZonPlayer.Error.CacheFailureReason: CustomStringConvertible {
    public var description: String {
        switch self {
        case .downloadFailed(let url, let error):
            return "\(url) download failed: \(error.localizedDescription)."
        case .createCacheDirectoryFailed(let url):
            return "\(url) directory create failed."
        case .fileStoreFailed(let url, let error):
            return "\(url) store failed: \(error.localizedDescription)."
        case .downloadExplicitlyCancelled(let url):
            return "\(url) download explicitly cancelled."
        case .streamingRequestCancelled(let url):
            return "The request for \(url as Any) cancelled."
        case let .streamingStorageCreateFileHandleFailed(url, error):
            return "Streaming storage create file handle to \(url) failed: \(error.localizedDescription)"
        case let .streamingStorageWriteFailed(url, data, range, error):
            return "Streaming storage write \(data) to \(range) failed at \(url): \(error.localizedDescription)"
        case let .streamingStorageReadFailed(url, range, error):
            return "Streaming storage read data from \(range) failed at \(url): \(error.localizedDescription)"
        case let .streamingStorageSaveMetaDataFailed(url, metaData, error):
            return "Streaming storage save \(metaData) for \(url) failed: \(error.localizedDescription)"
        case let .streamingStorageReleaseFailed(url, error):
            return "Streaming storage release failed for \(url): \(error.localizedDescription)"
        case let .streamingStorageCleanFailed(url, error):
            return "Streaming storage clean failed for \(url): \(error.localizedDescription)"
        case let .streamingRequestFailed(task, error):
            return "Streaming request failed for \(task.originalRequest?.url as Any): \(error.localizedDescription)"
        case .invalidStreamingResponse(let response):
            return "Invalid streaming response: \(response)"
        case let .invalidDataFromStreamingStorage(url, range):
            return "There is invalid data for \(url) from \(range)"
        }
    }
}
