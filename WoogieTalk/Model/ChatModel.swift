//
//  ChatModel.swift
//  WoogieTalk
//
//  Created by woogie on 2020/08/30.
//  Copyright © 2020 woogie. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {
    public var users: Dictionary<String, Bool> = [:] //채팅방 참여 인원
    public var comments: Dictionary<String, Comment> = [:] //채팅방의 대화 내용
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    public class Comment: Mappable {
        public var uid: String?
        public var message: String?
        public required init?(map: Map) {
            
        }
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
        }
    }
}
