# Contributing to SwiftUI Animation Masterclass

Thank you for your interest in contributing to SwiftUI Animation Masterclass! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

- Use the GitHub issue tracker
- Include detailed reproduction steps
- Provide device and iOS version information
- Include crash logs if applicable

### Suggesting Enhancements

- Use the GitHub issue tracker
- Describe the enhancement clearly
- Explain the use case and benefits
- Provide mockups or examples if possible

### Pull Requests

- Fork the repository
- Create a feature branch
- Make your changes
- Add tests for new functionality
- Update documentation
- Submit a pull request

## Development Setup

### Prerequisites

- Xcode 15.0 or later
- iOS 15.0+ deployment target
- Swift 5.9 or later

### Getting Started

1. Clone the repository:
```bash
git clone https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git
cd SwiftUI-Animation-Masterclass
```

2. Open the project in Xcode:
```bash
open Package.swift
```

3. Build the project:
```bash
swift build
```

4. Run tests:
```bash
swift test
```

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4-space indentation
- Maximum line length: 120 characters
- Use meaningful variable and function names
- Add documentation comments for public APIs

### Animation Guidelines

- Ensure 60fps minimum performance
- Test on multiple device types
- Consider accessibility implications
- Provide smooth fallbacks for older devices

### Code Organization

- Keep files focused and single-purpose
- Use appropriate access control levels
- Group related functionality together
- Follow the existing project structure

## Testing

### Test Requirements

- All new features must include tests
- Maintain 90%+ code coverage
- Test on multiple iOS versions
- Include performance tests for animations

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter TestAnimationPerformance

# Run with coverage
swift test --enable-code-coverage
```

### Test Structure

- Unit tests for individual components
- Integration tests for animation flows
- Performance tests for complex animations
- UI tests for user interactions

## Pull Request Process

### Before Submitting

1. Ensure all tests pass
2. Update documentation if needed
3. Add examples for new features
4. Check code coverage
5. Review for performance implications

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Performance tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Examples added/updated
```

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality
- PATCH version for backwards-compatible bug fixes

### Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version tags created
- [ ] Release notes prepared
- [ ] Examples tested

## Getting Help

- Create an issue for bugs or feature requests
- Join our discussions for questions
- Review existing issues and pull requests
- Check the documentation for common solutions

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to SwiftUI Animation Masterclass! 