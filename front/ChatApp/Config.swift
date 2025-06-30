//
//  Config.swift
//  ChatApp
//
//  Configuration for different environments
//

import Foundation

struct Config {
    static let isProduction = true
    
    static var baseURL: String {
        if isProduction {
            return "https://chat.team-milestone.click"
        } else {
            return "http://localhost:8080"
        }
    }
    
    static var wsURL: String {
        if isProduction {
            return "wss://chat.team-milestone.click/chat"
        } else {
            return "ws://localhost:8080/chat"
        }
    }
}
