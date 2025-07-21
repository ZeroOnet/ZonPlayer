//
//  Record.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/9.
//

struct Record: Codable {
    var url: URL?
    var metaData: ZPC.Streaming.MetaData?
    private(set) var fragments: [NSRange]

    init(url: URL? = nil, metaData: ZPC.Streaming.MetaData? = nil, fragments: [NSRange] = []) {
        self.url = url
        self.metaData = metaData
        self.fragments = fragments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try? container.decodeIfPresent(URL.self, forKey: .url)
        self.metaData = try? container.decodeIfPresent(ZPC.Streaming.MetaData.self, forKey: .metaData)
        self.fragments = (try? container.decode([NSRange].self, forKey: .fragments)) ?? []
    }

    mutating func reset() {
        metaData = nil
        fragments = []
    }

    // swiftlint:disable:next cyclomatic_complexity
    mutating func addFragment(_ fragment: NSRange) {
        let fragmentOffset = fragment.location + fragment.length
        let count = fragments.count
        if count == 0 {
            fragments.append(fragment)
        } else {
            // Find indexes of intersectant fragments.
            var intersectantIdxes: IndexSet = []
            for (idx, element) in fragments.enumerated() {
                let rangeOffset = element.location + element.length
                if fragmentOffset <= element.location {
                    if intersectantIdxes.isEmpty { intersectantIdxes.insert(idx) }
                    break
                } else if fragment.location <= rangeOffset && fragmentOffset > element.location {
                    intersectantIdxes.insert(idx)
                } else if fragment.location >= rangeOffset {
                    if idx == count - 1 { intersectantIdxes.insert(idx) }
                }
            }

            guard let firstIdx = intersectantIdxes.first else { return }
            let firstRange = fragments[firstIdx]

            // The added fragment crossed with multiple fragments.
            if intersectantIdxes.count > 1 {
                guard let lastIdx = intersectantIdxes.last else { return }
                let lastRange = fragments[lastIdx]
                let location = min(firstRange.location, fragment.location)
                let endOffset = max(lastRange.location + lastRange.length, fragmentOffset)
                let combineRange = NSRange(location: location, length: endOffset - location)
                var tmp = Array(fragments.enumerated())
                tmp.removeAll { intersectantIdxes.contains($0.offset) }
                fragments = tmp.map { $0.element }
                fragments.insert(combineRange, at: firstIdx)
            } else if intersectantIdxes.count == 1 {
                let expandFirstRange = NSRange(location: firstRange.location, length: firstRange.length + 1)
                let expandFragmentRange = NSRange(location: fragment.location, length: fragment.length + 1)
                let intersectionRange = NSIntersectionRange(expandFirstRange, expandFragmentRange)

                // Merge added fragment into first fragment
                if intersectionRange.length > 0 {
                    let location = min(firstRange.location, fragment.location)
                    let endOffset = max(firstRange.location + firstRange.length, fragmentOffset)
                    let combineRange = NSRange(location: location, length: endOffset - location)
                    fragments.remove(at: firstIdx)
                    fragments.insert(combineRange, at: firstIdx)
                } else { // Add fragment to specified index in arrary.
                    let newIdx = firstRange.location > fragment.location ? firstIdx : firstIdx + 1
                    fragments.insert(fragment, at: newIdx)
                }
            }
        }
    }
}
