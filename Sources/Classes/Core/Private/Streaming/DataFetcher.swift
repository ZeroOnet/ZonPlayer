//
//  DataFetcher.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/15.
//

final class DataFetcher {
    let onCompleted = ZPDelegate<(DataFetcher, Result<Void, ZonPlayer.Error>), Void>()
    let storage: ZPCDataStorable
    let requester: ZPCDataRequestable
    let loadingRequest: ZPCLoadingRequestable
    init(storage: ZPCDataStorable, requester: ZPCDataRequestable, loadingRequest: ZPCLoadingRequestable) {
        self.storage = storage
        self.requester = requester
        self.loadingRequest = loadingRequest

        _fullfillMetaDataIfNeeded()
    }

    deinit {
        if !loadingRequest.isFinished {
            let error = ZonPlayer.Error.cacheFailed(.streamingRequestCancelled(requester.url))
            loadingRequest.finishLoading(with: error)
        }
    }

    func fetch() {
        guard let dataRequest = loadingRequest.theDataRequest else { return }
        var offset = Int(dataRequest.requestedOffset)
        var length = dataRequest.requestedLength
        if dataRequest.currentOffset != 0 {
            offset = Int(dataRequest.currentOffset)
        }
        let toEnd = dataRequest.requestsAllDataToEndOfResource

        if toEnd {
            storage.getMetaData { [weak self] metaData in
                guard let self, let metaData else { return }
                length = metaData.contentLength - offset
                let range = NSRange(location: offset, length: length)
                self._checkSource(for: range)
            }
        } else {
            _checkSource(for: NSRange(location: offset, length: length))
        }
    }

    private let _miniumPieceLength = 204800 // 200 Kb
}

extension DataFetcher {
    private func _fullfillMetaDataIfNeeded() {
        storage.getMetaData { [weak self] metaData in
            guard
                let self,
                let metaData,
                let contentRequest = self.loadingRequest.theMetaDataRequest
            else { return }
            contentRequest.metaData = metaData
            self.requester.plugins.forEach {
                $0.didReceive(metaData, forURL: self.requester.url, fromRemote: false)
            }
        }
    }

    private func _checkSource(for range: NSRange) {
        storage.getCacheFragments { [weak self] fragments in
            guard let self else { return }
            let dataTasks = self._dataTasks(for: range, with: fragments)
            self._executeDataTasks(dataTasks)
        }
    }

    private func _executeDataTasks(_ dataTasks: [ZPCDataTaskable]) {
        guard let firstTask = dataTasks.first else { return }
        let dataTasks = Array(dataTasks.dropFirst())
        firstTask.requestData { [weak self] result in
            switch result {
            case .success:
                if dataTasks.isEmpty {
                    if let self {
                        if !self.loadingRequest.isFinished {
                            self.loadingRequest.finishLoading()
                        }
                        self.onCompleted.call((self, .success(())))
                    }
                } else {
                    self?._executeDataTasks(dataTasks)
                }
            case .failure(let error):
                if let self {
                    if !self.loadingRequest.isFinished {
                        self.loadingRequest.finishLoading(with: error)
                    }
                    self.onCompleted.call((self, .failure(error)))
                }
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func _dataTasks(for range: NSRange, with fragments: [NSRange]) -> [ZPCDataTaskable] {
        var result: [ZPCDataTaskable] = []
        let endOffset = range.location + range.length
        for cft in fragments {
            let intersectionRange = NSIntersectionRange(range, cft)
            if intersectionRange.length > 0 {
                let piecesCount = intersectionRange.length / _miniumPieceLength
                for idx in 0...piecesCount {
                    let offset = idx * _miniumPieceLength
                    let offsetLocation = intersectionRange.location + offset
                    let maxLocation = intersectionRange.location + intersectionRange.length
                    let length = (offsetLocation + _miniumPieceLength) > maxLocation
                        ? maxLocation - offsetLocation : _miniumPieceLength
                    result.append(_localTask(for: NSRange(location: offsetLocation, length: length)))
                }
            } else if cft.location >= endOffset { break }
        }

        if result.isEmpty {
            // There is no cache.
            result.append(_remoteTask(for: range))
        } else {
            var localAndRemoteSources: [ZPCDataTaskable] = []
            for (idx, element) in result.enumerated() {
                let sourceRangeLocation = element.range.location
                let rangeLocation = range.location
                if idx == 0 {
                    if rangeLocation < sourceRangeLocation {
                        let newRange = NSRange(location: rangeLocation, length: rangeLocation - sourceRangeLocation)
                        localAndRemoteSources.append(_remoteTask(for: newRange))
                    }
                } else {
                    if let lastSource = localAndRemoteSources.last {
                        let lastOffset = lastSource.range.location + lastSource.range.length
                        if sourceRangeLocation > lastOffset {
                            let newRange = NSRange(location: lastOffset, length: sourceRangeLocation - lastOffset)
                            localAndRemoteSources.append(_remoteTask(for: newRange))
                        }
                    }
                }
                localAndRemoteSources.append(element)

                if idx == result.count - 1 {
                    let localEndOffset = sourceRangeLocation + element.range.length
                    if endOffset > localEndOffset {
                        let newRange: NSRange = .init(location: localEndOffset, length: endOffset - localEndOffset)
                        localAndRemoteSources.append(_remoteTask(for: newRange))
                    }
                }
            }
            result = localAndRemoteSources
        }

        return result
    }

    private func _localTask(for range: NSRange) -> ZPCDataTaskable {
        DataFromStorage(
            storage: storage,
            range: range,
            loadingRequest: loadingRequest,
            plugins: requester.plugins
        )
    }

    private func _remoteTask(for range: NSRange) -> ZPCDataTaskable {
        requester.dataTask(forRange: range, withLoadingRequest: loadingRequest)
    }
}
