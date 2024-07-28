//
//  PoiView.swift
//  ElecKickBoard
//
//  Created by t2023-m0019 on 7/26/24.
//

import UIKit
import KakaoMapsSDK

class PoiView: Map2ViewController {
    override func addViews() {
        
        let defaultPosition: MapPoint = MapPoint(longitude: 37.498277, latitude: 127.026918)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
        mapController?.addView(mapviewInfo)
    }
    
    override func viewInit(viewName: String) {
        createLabelLayer(viewName: viewName)
        createPoiStyle(viewName: viewName)
    }
}
