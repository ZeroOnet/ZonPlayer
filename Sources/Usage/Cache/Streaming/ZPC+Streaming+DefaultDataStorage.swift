//
//  ZPC+Streaming+DefaultDataStorage.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/8.
//

extension ZPC.Streaming {
    public final class DefaultDataStorage: DataStorable, @unchecked Sendable {
        public let url: URL
        public let config: ZPC.Config
        public let onError: ZonPlayer.Delegate<ZonPlayer.Error, Void>
        public init(url: URL, config: ZPC.Config) {
            self.url = url
            self.config = config
            self.onError = .init()
            self._fileURL = config.fileURL(with: url)
            self._recordURL = config.recordURL(with: url)

            config.ioQueue.async { self._prepare() }
        }

        deinit {
            do {
                try _writeFileHandle?.closeHandle()
                try _readFileHandle?.closeHandle()
            } catch {
                onError.call(.cacheFailed(.streamingStorageReleaseFailed(url, error)))
            }
        }

        public func getCacheFragments(completion: @escaping @Sendable ([NSRange]) -> Void) {
            config.ioQueue.async { completion(self._record?.fragments ?? []) }
        }

        public func setMetaData(_ metaData: ZPC.Streaming.MetaData) {
            config.ioQueue.async {
                do {
                    guard self._record?.metaData != metaData else { return }
                    self._record?.metaData = metaData
                    try self._writeFileHandle?.truncate(at: metaData.contentLength)
                    try self._writeFileHandle?.save()
                    guard let record = self._record else { return }
                    let recordData = try JSONEncoder().encode(record)
                    try recordData.write(to: self._recordURL)
                } catch {
                    self.onError.call(.cacheFailed(.streamingStorageSaveMetaDataFailed(self.url, metaData, error)))
                }
            }
        }

        public func getMetaData(completion: @escaping @Sendable (ZPC.Streaming.MetaData?) -> Void) {
            config.ioQueue.async { completion(self._record?.metaData) }
        }

        public func writeData(_ data: Data, to range: NSRange) {
            config.ioQueue.async {
                do {
                    self._record?.addFragment(range)
                    try self._writeFileHandle?.writeData(data, to: range)
                    try self._writeFileHandle?.save()
                    guard let record = self._record else { return }
                    let recordData = try JSONEncoder().encode(record)
                    try recordData.write(to: self._recordURL)
                } catch {
                    self.onError.call(.cacheFailed(.streamingStorageWriteFailed(self.url, data, range, error)))
                }
            }
        }

        public func readData(from range: NSRange, completion: @escaping @Sendable (Data?) -> Void) {
            config.ioQueue.async {
                do {
                    completion(try self._readFileHandle?.readData(from: range))
                } catch {
                    self.onError.call(.cacheFailed(.streamingStorageReadFailed(self.url, range, error)))
                }
            }
        }

        /// Clean data storage.
        ///
        /// - Important: Storage is unavailable after cleanning.
        public func clean(completion: (@Sendable () -> Void)?) {
            config.ioQueue.async {
                self._record?.reset()
                let fileManager = FileManager.default
                do {
                    try fileManager.removeItem(at: self._fileURL)
                    try fileManager.removeItem(at: self._recordURL)
                    try self._writeFileHandle?.closeHandle()
                    try self._readFileHandle?.closeHandle()
                    self._writeFileHandle = nil
                    self._readFileHandle = nil
                } catch {
                    self.onError.call(.cacheFailed(.streamingStorageCleanFailed(self.url, error)))
                }
                completion?()
            }
        }

        private let _fileURL: URL
        private let _recordURL: URL

        private var _record: Record?
        private var _readFileHandle: _FileHandleable?
        private var _writeFileHandle: _FileHandleable?
    }
}

extension ZPC.Streaming.DefaultDataStorage {
    private func _prepare() {
        let filePath = _fileURL.path
        let recordPath = _recordURL.path
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: nil)
        }
        if !fileManager.fileExists(atPath: recordPath) {
            fileManager.createFile(atPath: recordPath, contents: nil)
        }

        let recordData = (try? Data(contentsOf: _recordURL)) ?? Data()
        _record = (try? JSONDecoder().decode(Record.self, from: recordData)) ?? Record()
        _record?.url = url

        do {
            _readFileHandle = try FileHandle(forReadingFrom: _fileURL)
            _writeFileHandle = try FileHandle(forWritingTo: _fileURL)
        } catch {
            onError.call(.cacheFailed(.streamingStorageCreateFileHandleFailed(url, error)))
        }
    }
}

private protocol _FileHandleable {
    func seek(to fileOffset: Int) throws
    func writeData(_ data: Data, to range: NSRange) throws
    func readData(from range: NSRange) throws -> Data?
    func truncate(at fileOffset: Int) throws
    func save() throws
    func closeHandle() throws
}

extension FileHandle: _FileHandleable {
    func seek(to fileOffset: Int) throws {
        let offset = UInt64(fileOffset)
        if #available(iOS 13.0, *) {
            try seek(toOffset: offset)
        } else {
            seek(toFileOffset: offset)
        }
    }

    func writeData(_ data: Data, to range: NSRange) throws {
        try seek(to: range.location)
        if #available(iOS 13.4, *) {
            try write(contentsOf: data)
        } else {
            write(data)
        }
    }

    func readData(from range: NSRange) throws -> Data? {
        try seek(to: range.location)
        let length = range.length
        if #available(iOS 13.4, *) {
            return try read(upToCount: length)
        } else {
            return readData(ofLength: length)
        }
    }

    func truncate(at fileOffset: Int) throws {
        let offset = UInt64(fileOffset)
        if #available(iOS 13.0, *) {
            try truncate(atOffset: offset)
        } else {
            truncateFile(atOffset: offset)
        }
    }

    func save() throws {
        if #available(iOS 13.0, *) {
            try synchronize()
        } else {
            synchronizeFile()
        }
    }

    func closeHandle() throws {
        if #available(iOS 13.0, *) {
            try close()
        } else {
            closeFile()
        }
    }
}
