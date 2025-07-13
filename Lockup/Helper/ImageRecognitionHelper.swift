import UIKit
import Vision

class ImageRecognitionHelper {
    static func recognizeObjectName(from imageData: Data, completion: @escaping (String?) -> Void) {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            completion(nil)
            return
        }

        let request = VNClassifyImageRequest { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first, topResult.confidence > 0.3 {
                completion(topResult.identifier.capitalized)
            } else {
                completion(nil)
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }
}
