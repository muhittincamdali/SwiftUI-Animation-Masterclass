import SwiftUI

/// Draws particles into a `GraphicsContext`, one transformed copy of the context per particle.
enum ParticleRenderer {
    /// Font size text particles are laid out at before they are scaled to the particle size.
    static let textPointSize: CGFloat = 40

    static func draw(_ particles: [Particle], emitter: ParticleEmitter, in context: inout GraphicsContext) {
        guard !particles.isEmpty else { return }
        if emitter.blending == .additive {
            context.blendMode = .plusLighter
        }
        var images: [Int: GraphicsContext.ResolvedImage] = [:]
        var texts: [Int: GraphicsContext.ResolvedText] = [:]

        for particle in particles {
            let opacity = emitter.opacity(at: particle.progress)
            guard opacity > 0 else { continue }
            let size = particle.size * emitter.scale(at: particle.progress)
            guard size > 0 else { continue }

            var layer = context
            layer.opacity = opacity
            layer.translateBy(x: particle.x, y: particle.y)
            layer.rotate(by: .radians(particle.rotation))
            if particle.tumble != 0 {
                // Scaling one axis by a cosine reads as a flat piece flipping in 3D.
                let flip = cos(particle.tumble * particle.age)
                layer.scaleBy(x: 1, y: max(abs(flip), 0.08))
            }

            let color = emitter.colors[particle.colorIndex % emitter.colors.count]
            switch emitter.shapes[particle.shapeIndex % emitter.shapes.count] {
            case .circle:
                layer.fill(Path(ellipseIn: centeredRect(width: size, height: size)), with: .color(color))
            case .ring:
                let lineWidth = max(1, size * 0.12)
                let rect = centeredRect(width: size, height: size).insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
                layer.stroke(Path(ellipseIn: rect), with: .color(color), lineWidth: lineWidth)
            case let .rectangle(aspectRatio):
                layer.fill(Path(centeredRect(width: size, height: size * aspectRatio)), with: .color(color))
            case .triangle:
                layer.fill(triangle(size: size), with: .color(color))
            case .star:
                layer.fill(star(size: size), with: .color(color))
            case let .symbol(name):
                let key = particle.shapeIndex * 1024 + particle.colorIndex
                var image = images[key] ?? context.resolve(Image(systemName: name))
                image.shading = .color(color)
                images[key] = image
                layer.draw(image, in: centeredRect(width: size, height: size))
            case let .text(string):
                let text = texts[particle.shapeIndex] ?? context.resolve(
                    Text(string).font(.system(size: textPointSize))
                )
                texts[particle.shapeIndex] = text
                layer.scaleBy(x: size / textPointSize, y: size / textPointSize)
                layer.draw(text, at: .zero, anchor: .center)
            }
        }
    }

    static func centeredRect(width: Double, height: Double) -> CGRect {
        CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
    }

    static func triangle(size: Double) -> Path {
        let radius = size / 2
        var path = Path()
        for corner in 0..<3 {
            let angle = -Double.pi / 2 + Double(corner) * 2 * .pi / 3
            let point = CGPoint(x: radius * cos(angle), y: radius * sin(angle))
            corner == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    static func star(size: Double) -> Path {
        let outer = size / 2
        let inner = outer * 0.42
        var path = Path()
        for corner in 0..<10 {
            let radius = corner.isMultiple(of: 2) ? outer : inner
            let angle = -Double.pi / 2 + Double(corner) * .pi / 5
            let point = CGPoint(x: radius * cos(angle), y: radius * sin(angle))
            corner == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

/// Draws a fixed set of particles. Used for still frames and in tests.
struct ParticleSnapshot: View {
    let particles: [Particle]
    let emitter: ParticleEmitter

    var body: some View {
        Canvas { context, _ in
            ParticleRenderer.draw(particles, emitter: emitter, in: &context)
        }
    }
}
