//
//  ZonPlayer+Error.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/2.
//

extension ZonPlayer {
    public enum Error: Swift.Error, LocalizedError {
        /// The reason for player terminated.
        ///
        /// - Important: Play cannot resume and should be recreated at the moment.
        public enum TerminationReason: CustomStringConvertible {
            case mediaServicesWereReset
            /// The status of AVPlayer is failed with an error.
            case playerError(Swift.Error)
            /// The status of AVPlayer is failed without any error.
            case unknownError

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

        public enum CacheFailureReason: CustomStringConvertible {
            case downloadFailed(URL, Swift.Error)
            case createCacheDirectoryFailed(URL)
            case fileStoreFailed(URL, Swift.Error)
            case downloadExplicitlyCancelled(URL)

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
                }
            }
        }

        case invalidURL(URLConvertible)
        case sessionError(ZPSessionable, Swift.Error)
        case playerTerminated(TerminationReason)
        case cacheFailed(CacheFailureReason)

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

        public var isTerminated: Bool {
            guard case .playerTerminated = self else { return false }
            return true
        }
    }
}
