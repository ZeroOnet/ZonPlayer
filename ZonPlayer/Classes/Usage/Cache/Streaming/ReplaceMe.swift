//
//  ReplaceMe.swift
//  BaySwiftyPlayer
//
//  Created by 李文康 on 2023/11/7.
//

/**

 AVAssetResourceLoader 技术笔记

 AVURLAsset(url: XXX).resourceLoader.setDelegate(self)

 1. 实现 AVAssetResourceLoaderDelegate 之前，需要使用自定义 URLScheme，让系统无法识别，此时才会进行代理协议调用

 2. 实现代理协议方法：
    - 1. shouldWaitForLoadingOfRequestedResource 表示是否可以处理此请求，我们在这里捕获原始请求，并创建自定义网络请求
    - 2. didCancel loadingRequest 主动取消请求，此时需要将原始请求删除并取消自定义网络请求。

 3. 由于分片策略，需要在自定义请求的 HTTP Header 中进行设置

 4. 分片请求数据与本地缓存关系：缺失、全部包含、部分包含。

 5. 服务器信任证书验证

 */
