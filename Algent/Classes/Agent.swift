//
//  Algent.swift
//  Algent
//
//  Created by miup on 2017/10/12.
//

import AlgoliaSearch
import Result

public typealias AlgentQuery = Query

public class Algent {
    public private(set) static var shared: Algent!

    private let client = Client(appID: Algent.appID, apiKey: Algent.apiKey)
    private static var appID: String!
    private static var apiKey: String!

    public class func initialize(appID: String, apiKey: String) {
        self.appID = appID
        self.apiKey = apiKey
        self.shared = Algent()
    }

    private init() { }

    func index(name: String) -> Index {
        return client.index(withName: name)
    }

    public func search
        <AlgoliaRequest: AlgoliaRequestProtocol>
        (request: AlgoliaRequest, completion: ((Result<AlgoliaResponse<AlgoliaRequest.HitType>, AlgoliaResponseError>) -> Void)?) {
        let index = client.index(withName: request.indexName)
        index.search(request.query) { (json, error) in
            if let error = error { print(error); return }
            guard let json: [String: Any] = json else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                print(String(data: data, encoding: .utf8)!)
                let response = try JSONDecoder().decode(AlgoliaResponse<AlgoliaRequest.HitType>.self, from: data)
                completion?(.success(response))
            } catch {
                completion?(.failure(.cannnotDecodeResponse))
            }
        }
    }

    public func searchForFacetValues(request: FacetValuesRequestProtocol, completion: ((Result<FacetValuesResponse, AlgoliaResponseError>) -> Void)?) {
        let index = client.index(withName: request.indexName)
        if let query = request.query {
            index.z_objc_searchForFacetValues(of: request.key, matching: request.keyword, query: query) { (json, error) in
                if let error = error { print(error); return }
                guard let json: [String: Any] = json else { return }
                do {
                    let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    print(String(data: data, encoding: .utf8)!)
                    let response = try JSONDecoder().decode(FacetValuesResponse.self, from: data)
                    completion?(.success(response))
                } catch {
                    completion?(.failure(.cannnotDecodeResponse))
                }
            }
        } else {
            index.searchForFacetValues(of: request.key, matching: request.keyword) { (json, error) in
                if let error = error { print(error); return }
                guard let json: [String: Any] = json else { return }
                do {
                    let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    print(String(data: data, encoding: .utf8)!)
                    let response = try JSONDecoder().decode(FacetValuesResponse.self, from: data)
                    completion?(.success(response))
                } catch {
                    completion?(.failure(.cannnotDecodeResponse))
                }
            }
        }
    }

}
