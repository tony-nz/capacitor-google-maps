import SDWebImage
import SVGKit

final class NativeImageCache: ImageURLLoadable {
    static let shared: ImageURLLoadable = NativeImageCache()

    
    private lazy var cache: NSCache<AnyObject, AnyObject> = {
        NSCache<AnyObject, AnyObject>()
    }()

    private init(){}

    func image(at urlString: String, resizeWidth: Int, resizeHeight: Int, completion: @escaping VoidReturnClosure<UIImage?>) {
        // Check if the provided string is a data URL.
        if urlString.starts(with: "http:") || urlString.starts(with: "https:") {
            if let url = URL(string: urlString) {
                // If urlString starts with "http:" or "https:" and can be converted to a valid URL, download and process the image.
                downloadImage(fromURL: url, resizeWidth: resizeWidth, resizeHeight: resizeHeight, completion: completion)
            } else {
                // Handle the case where urlString is not a valid URL.
                completion(nil)
            }
        } else {
            if let svgData = Data(base64Encoded: urlString, options: Data.Base64DecodingOptions(rawValue: 0)) {
                processSVGImage(svgData, resizeWidth: resizeWidth, resizeHeight: resizeHeight, completion: completion)
            } else {
                // Handle the case where the input is not valid SVG data.
                completion(nil)
            }
        }
        // Handle the case where the input is neither a data URL nor a valid URL.
        // print("Invalid image")
        // completion(nil)
    }

    private func downloadImage(fromURL url: URL, resizeWidth: Int, resizeHeight: Int, completion: @escaping VoidReturnClosure<UIImage?>) {
        // Generate custom key based on the size,
        // so we can cache the resized variant of the image as well.
        let key = "\(url.absoluteString)\(resizeWidth)\(resizeHeight)"

        if let image = cache.object(forKey: key as AnyObject) as? UIImage {
            // If the resized image is found in the cache, return it.
            completion(image)
        } else {
            // Otherwise, download the original image.
            SDWebImageDownloader.shared.downloadImage(with: url, options: [], context: nil, progress: nil) { image, _, _, _ in
                // Resize the downloaded image to the preferred size.
                guard let resizedImage = image?.resize(targetSize: CGSize(width: resizeWidth, height: resizeHeight)) else {
                    completion(nil)
                    return
                }
                // Save the resized image in the cache.
                self.cache.setObject(resizedImage, forKey: key as AnyObject)
                // Return the resized image.
                completion(resizedImage)
            }
        }
    }

    private func processSVGImage(_ svgData: Data, resizeWidth: Int, resizeHeight: Int, completion: @escaping VoidReturnClosure<UIImage?>) {
        // Generate a custom key based on the size and SVG data.
        let key = "\(svgData.count)\(resizeWidth)\(resizeHeight)"

        if let image = cache.object(forKey: key as AnyObject) as? UIImage {
            // If the resized image is found in the cache, return it.
            completion(image)
        } else {
            guard let svgImage = SVGKImage(data: svgData) else {
                completion(nil)
                return
            }

            // Resize the SVG image
            svgImage.size = CGSize(width: CGFloat(resizeWidth), height: CGFloat(resizeHeight))

            // Convert the SVG image to a UIImage
            let uiImage = svgImage.uiImage

            // Return the resized UIImage
            completion(uiImage)
        }
    }

    func clear(completion: @escaping NoArgsClosure) {
        cache.removeAllObjects()
        completion()
    }
}
