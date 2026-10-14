import CoreGraphics

/// The pixels of a rendered image, as straight (not premultiplied) RGBA values from 0 to 1.
struct PixelBuffer {
    let width: Int
    let height: Int
    private let bytes: [UInt8]

    init(_ image: CGImage) {
        width = image.width
        height = image.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { buffer in
            let context = CGContext(
                data: buffer.baseAddress,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
            context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        }
        self.bytes = bytes
    }

    /// The pixel at `x`, `y`, with `y` growing downward.
    func pixel(x: Int, y: Int) -> (red: Double, green: Double, blue: Double, alpha: Double) {
        let index = (y * width + x) * 4
        let alpha = Double(bytes[index + 3]) / 255
        guard alpha > 0 else { return (0, 0, 0, 0) }
        return (
            Double(bytes[index]) / 255 / alpha,
            Double(bytes[index + 1]) / 255 / alpha,
            Double(bytes[index + 2]) / 255 / alpha,
            alpha
        )
    }

    /// Share of pixels that are more than half opaque.
    var coverage: Double {
        var covered = 0
        for index in stride(from: 3, to: bytes.count, by: 4) where bytes[index] > 127 {
            covered += 1
        }
        return Double(covered) / Double(width * height)
    }
}
