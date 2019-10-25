//
//  API.swift
//  DiffableDemo
//
//  Created by Ben Scheirman on 10/22/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

struct Episode : Decodable {
    let id: Int
    let title: String
    let tags: [String]
}

private struct EpisodesWrapper : Decodable {
    let episodes: [Episode]
}

struct API {
    
    private static var baseURL = URL(string: "https://nsscreencast.com/api/")!
    
    static func fetchEpisodes(completion: @escaping ([Episode])->Void) {
        let session = URLSession.shared
        let dispatchCompletion: ([Episode]) -> Void = { episodes in
            DispatchQueue.main.async {
                completion(episodes)
            }
        }
        let task = session.dataTask(with: baseURL.appendingPathComponent("episodes")) { data, response, error in
            guard let http = response as? HTTPURLResponse else {
                dispatchCompletion([])
                return
            }
            guard http.statusCode == 200 else {
                dispatchCompletion([])
                print("HTTP \(http.statusCode) received")
                return
            }
            
            guard let data = data else {
                print("HTTP \(http.statusCode) received")
                dispatchCompletion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let wrapper = try decoder.decode(EpisodesWrapper.self, from: data)
                dispatchCompletion(wrapper.episodes)
            } catch let e as DecodingError {
                print("Decoding Error: \(e)")
                dispatchCompletion([])
            } catch {
                print("ERROR: \(error.localizedDescription)")
                dispatchCompletion([])
            }
        }
        
        task.resume()
    }
}
