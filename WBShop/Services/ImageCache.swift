import SwiftUI

actor ImageCache {
    static let shared = ImageCache()

    private let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        return cache
    }()

    private var inFlightTasks: [URL: Task<UIImage?, Never>] = [:]

    private init() {}

    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        if let existingTask = inFlightTasks[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode,
                      let image = UIImage(data: data) else {
                    return nil
                }
                return image
            } catch {
                return nil
            }
        }

        inFlightTasks[url] = task
        let result = await task.value
        inFlightTasks[url] = nil

        if let result {
            memoryCache.setObject(result, forKey: key)
        }

        return result
    }
}

enum CachedImagePhase {
    case empty
    case success(Image)
    case failure
}

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (CachedImagePhase) -> Content

    @State private var phase: CachedImagePhase = .empty

    init(url: URL?, @ViewBuilder content: @escaping (CachedImagePhase) -> Content) {
        self.url = url
        self.content = content
    }

    var body: some View {
        content(phase)
            .task(id: url) {
                guard let url else {
                    phase = .failure
                    return
                }
                phase = .empty
                if let uiImage = await ImageCache.shared.image(for: url) {
                    phase = .success(Image(uiImage: uiImage))
                } else {
                    phase = .failure
                }
            }
    }
}
