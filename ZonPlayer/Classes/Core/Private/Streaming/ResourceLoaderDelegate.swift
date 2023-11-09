//
//  ResourceLoaderDelegate.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/7.
//

//final class ResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
//    let addedSchemePrefix: String
//    init(addedSchemePrefix: String) {
//        self.addedSchemePrefix = addedSchemePrefix
//    }
//
//    func resourceLoader(
//        _ resourceLoader: AVAssetResourceLoader,
//        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
//    ) -> Bool {
//        guard
//            let url = loadingRequest.request.url,
//            url.scheme?.hasPrefix(addedSchemePrefix) == true
//        else { return false }
//
//        return true
//    }
//
//    func resourceLoader(
//        _ resourceLoader: AVAssetResourceLoader,
//        didCancel loadingRequest: AVAssetResourceLoadingRequest
//    ) {
//
//    }
//}

/**

 Downloader 负责下载

 Cacher 负责缓存，需要包含分片信息

 一个 URL 对应一个 DataManager，DataManager 负责管理数据，是从 Remote 请求还是请本地读取


 */

/**

 VIMediaCache Arch

 loadingRequest -> VIResourceLoader -> VIResourceLoadingRequestWorker -> VIMediaDownloader -> VIMediaCacheWorker ---> VICacheAction
                                                |                                                   |
                                                |                                                   |
                                                |                                                   |
                                                |                                                   V
                                                |                                            VICacheConfiguration ----> VIContentInfo
                                                V
                                 AVAssetResourceLoadingRequest


 */
