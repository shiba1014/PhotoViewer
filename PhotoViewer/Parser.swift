//
//  Parser.swift
//  PhotoViewer
//
//  Created by Paul McCartney on 2017/12/14.
//  Copyright © 2017年 Satsuki Hashiba. All rights reserved.
//

import Foundation
import SWXMLHash

class Parser {
    static func getURLsAndSizes(from data: Data) -> ([URL], [CGSize]) {
        var urls: [URL] = []
        var sizes: [CGSize] = []
        let xml = SWXMLHash.parse(data)
        for photo in xml["rsp"]["photos"]["photo"].all {
            guard let attributeDict = photo.element?.allAttributes,
                let farmId = attributeDict["farm"]?.text,
                let serverId = attributeDict["server"]?.text,
                let id = attributeDict["id"]?.text,
                let secret = attributeDict["secret"]?.text,
                let width = Int(attributeDict["width_s"]?.text ?? ""),
                let height = Int(attributeDict["height_s"]?.text ?? "") else { return (urls, sizes) }
            let string = "http://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            if let url = URL(string: string) {
                urls.append(url)
            }
            sizes.append(CGSize(width: width, height: height))
        }
        return (urls,sizes)
    }
    
    static func getImageInfo(from data: Data) -> [(url: URL, size: CGSize)] {
        var infos:[(url: URL, size: CGSize)] = []
        let xml = SWXMLHash.parse(data)
        for photo in xml["rsp"]["photos"]["photo"].all {
            guard let attributeDict = photo.element?.allAttributes,
                let farmId = attributeDict["farm"]?.text,
                let serverId = attributeDict["server"]?.text,
                let id = attributeDict["id"]?.text,
                let secret = attributeDict["secret"]?.text,
                let width = Int(attributeDict["width_s"]?.text ?? ""),
                let height = Int(attributeDict["height_s"]?.text ?? "") else { continue }
            let string = "http://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            guard let url = URL(string: string) else { continue }
            let size = CGSize(width: width, height: height)
            infos.append((url,size))
        }
        return infos
    }
}
