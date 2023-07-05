//
//  SocketModel.swift
//  WebSocketPractice
//
//  Created by 이명진 on 2023/07/05.
//

import Foundation

// MARK: - Response
struct SocketModel: Codable {
    let op: String
    let msg: Msg
    
    enum CodingKeys: String, CodingKey {
        case op
        case msg = "x"
    }
}

// MARK: - X
struct Msg: Codable {
    let type, value, exchangeName, priceBase: String?

    enum CodingKeys: String, CodingKey {
        case type, value
        case exchangeName = "exchange_name"
        case priceBase = "price_base"
    }
}
