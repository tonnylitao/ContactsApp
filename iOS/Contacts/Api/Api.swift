//
//  API.swift
//  Contacts
//
//  Created by TonnySunm on 21/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

protocol ApiResource {}

typealias ResultCompletion<T> = (Result<T, ApiError>) -> Void


