//
//  DocumentsLoader.swift
//  nyt
//
//  Created by yva on 04/04/2017.
//  Copyright © 2017 yva. All rights reserved.
//

import Foundation

struct LoadError: Error {
    let message: String
}

typealias LoadResult = Result<[Document], LoadError>

enum DocumentsLoader {
    // just for test
    private static func testData() throws -> Data {
        return try Bundle.main.path(forResource: "October22", ofType: "json").map { filepath in
            FileManager.default.contents(atPath: filepath)!
        } ?? {
            throw LoadError(message: "not found")
        }()
    }

    public static func load(url: URL) -> LoadResult {
        return Result { try Data(contentsOf: url) }.mapError { error in
            // return Result { try testData() }.mapError { error in
            LoadError(message: error.localizedDescription)
        }.flatMap { data in
            parseJSON(data: data)
        }
    }

    private static func parseJSON(data: Data) -> LoadResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return (try? decoder.decode(Failure.self, from: data))
            .map { fail in
                LoadResult.failure(LoadError(message: fail.fault.faultstring))
            } ?? Result { try decoder.decode(Success.self, from: data) }
            .map { succ in
                succ.response.docs
            }.mapError { err in
                LoadError(message: err.localizedDescription)
            }
    }
}
