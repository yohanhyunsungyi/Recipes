//
//  RemoteImageLoader.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/2/25.
//

import Foundation
import UIKit

enum RemoteImageLoaderError: Error {
    case invalidImageData
    case networkError(Error)
}

actor RemoteImageLoader {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        do {
            let (data, _) = try await urlSession.data(from: url)
            
            guard let image = UIImage(data: data) else {
                throw RemoteImageLoaderError.invalidImageData
            }
            
            return image
        } catch {
            throw RemoteImageLoaderError.networkError(error)
        }
    }
}
