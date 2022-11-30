import Foundation

struct Document: Decodable {
    struct Headline: Decodable {
        let main: String
    }

    struct Byline: Decodable {
        let original: String
    }

    let abstract: String?
    let headline: Headline?
    let byline: Byline?
    let pubDate: Date?
    let snippet: String?
    let source: String?
    let webUrl: URL?
}

struct Success: Decodable {
    struct Response: Decodable {
        let docs: [Document]
    }

    let copyright: String
    let response: Response
}

struct Failure: Decodable {
    struct Fault: Decodable {
        let faultstring: String
    }

    let fault: Fault
}
