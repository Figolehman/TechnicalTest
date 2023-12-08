//
//  Post.swift
//  TechnicalTest
//
//  Created by Figo Alessandro Lehman on 07/12/23.
//

import Foundation

struct Post: Identifiable, Hashable, Codable {
    let createdAt: Date
    let image: String
    let caption: String
    let id: String
}
