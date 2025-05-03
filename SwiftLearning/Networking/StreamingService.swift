// Services/StreamingService.swift

import Foundation

class StreamingService {
    func streamPOST(to url: URL, body: [String: Any]) async throws -> AsyncThrowingStream<String, Error> {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20 // seconds
        let session = URLSession(configuration: config)
        let (stream, _) = try await session.bytes(for: request)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await line in stream.lines {
                        continuation.yield(line)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
