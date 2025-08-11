# API Reference

## Core Classes

### Main Framework

The main entry point for the SwiftUI-Animation-Masterclass framework.

```swift
public class SwiftUI-Animation-Masterclass {
    public init()
    public func configure()
    public func reset()
}
```

## Configuration

### Options

```swift
public struct Configuration {
    public var debugMode: Bool
    public var logLevel: LogLevel
    public var cacheEnabled: Bool
}
```

## Error Handling

```swift
public enum SwiftUI-Animation-MasterclassError: Error {
    case configurationFailed
    case initializationError
    case runtimeError(String)
}
