//
//  NASADataModel.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import Foundation

struct NASADataModel: Codable {
    let title: String?
    let explanation: String?
    let copyright: String?
    let date: String
    let url: String
}
