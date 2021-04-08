//  Decodable+Networking.swift
//  Contacts
//
//  Created by TonnyLi on 4/04/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

import Foundation
import Alamofire

extension Decodable {
    
    static func request(
        _ convertible: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil,
        requestModifier: Session.RequestModifier? = nil,
        completion: @escaping (Result<Self, AppError>) -> ()
    ) {
        AF.request(
            convertible,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            interceptor: interceptor,
            requestModifier: requestModifier
        )
        .validate()
        .responseDecodable(of: Self.self, queue: DispatchQueue.global()) { data in
            let result = data.result.mapError { AppError.networking($0.localizedDescription) }
            
            #if DEBUG
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                completion(result)
            }
            #else
            DispatchQueue.main.async {
                completion(result)
            }
            #endif
        }
    }
}

