//
//  Decodable.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

typealias Parameters = [String: String]

typealias ResultCompletion<T> = (Result<T, AppError>) -> Void

extension RemoteResource where Self: Decodable {
    
    /*
     a simple demo
     alternatively using alamofire in profuction
     */
    static func get(_ path: ApiPath = path, parameters: Parameters? = nil, completion: @escaping ResultCompletion<Self>) {
        
        guard let url = URL(string: path.rawValue, relativeTo: URL(string: ApiConfig.apiHost)),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(.invalidApiPath))
            return
        }

        components.queryItems = parameters?.map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: value)
        })
        
        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "accept")

        print("\napi: \(url.absoluteString)", parameters?.map { "\($0)=\($1)" } .joined(separator: "&") ?? "")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            let dealWithResultInMain = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                dealWithResultInMain(.failure(.networking(error.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                200 ... 299 ~= response.statusCode else {
                dealWithResultInMain(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                dealWithResultInMain(.failure(.invalidData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(Self.self, from: data)
                dealWithResultInMain(.success(decodedData))
            } catch {
                dealWithResultInMain(.failure(.decoding))
            }
        }.resume()
    }
}
