# xcbeautify

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcpisciotta%2Fxcbeautify%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/cpisciotta/xcbeautify)
[![CI](https://github.com/cpisciotta/xcbeautify/actions/workflows/ci.yml/badge.svg)](https://github.com/cpisciotta/xcbeautify/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/release/cpisciotta/xcbeautify.svg)](https://github.com/cpisciotta/xcbeautify/releases/latest)
[![License](https://img.shields.io/github/license/cpisciotta/xcbeautify.svg)](LICENSE.md)

![Example Screenshot](.readme-images/example.png)

**`xcbeautify` is a little beautifier tool for `xcodebuild`.**

A faster alternative to `xcpretty` written in Swift.

## Features

- [x] Human-friendly and colored output.
- [x] Supports the new build system's output.
- [x] Supports Xcode's parallel testing output.
- [x] Supports formatting Swift Package Manager output.
- [x] Supports generating JUnit reports.
- [x] Supports macOS & Linux.
- [x] Written in Swift: `xcbeautify` compiles to a static binary which you can
  bring anywhere. This also means less Ruby-dependant in your development
  environment and CI.

## Installation

### Homebrew

```bash
brew install xcbeautify
```

### [Mint](https://github.com/yonaskolb/mint)

```bash
mint install cpisciotta/xcbeautify
```

### Swift Package Manager

Create a directory in the same location as the `xcodeproj` file, for example `BuildTools`.  
In that directory, create a `Package.swift` file with the following contents.  
In addition, add an empty file named `Empty.swift` to the same location.

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_11)],
    dependencies: [
      .package(url: "https://github.com/cpisciotta/xcbeautify", from: "2.11.0"),
    ],
    targets: [
        .target(
            name: "BuildTools",
            dependencies: [
                .product(name: "xcbeautify", package: "xcbeautify"),
            ],
            path: ""
        )
    ]
)
```

Enter this command to execute.  
```
swift run -c release --package-path ./BuildTools xcbeautify
```

### Build from source

```bash
git clone https://github.com/cpisciotta/xcbeautify.git
cd xcbeautify
make install
```

## Usage

```bash
xcodebuild [flags] | xcbeautify
```

If you want `xcbeautify` to exit with the same status code as `xcodebuild`
(e.g. on a CI):

```bash
set -o pipefail && xcodebuild [flags] | xcbeautify
```

For parallel and concurrent destination testing, it helps to use unbuffered I/O for _stdout_ and to redirect _stderr_ to _stdout_.

```bash
NSUnbufferedIO=YES xcodebuild [flags] 2>&1 | xcbeautify
```

```bash
swift test [flags] 2>&1 | xcbeautify
```

### GitHub Actions

| ![GitHub Actions Summary](.readme-images/gh-summary.png) |
|:--:|
| *GitHub Actions Summary* |

| ![GitHub Actions Comment](.readme-images/gh-comment.png) |
|:--:|
| *GitHub Actions Comment* |

`xcbeautify` features an integrated GitHub Actions renderer that harnesses [workflow commands](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions) to highlight warnings, errors, and results directly within the GitHub user interface. To utilize this function, simply run `xcbeautify` and add the `--renderer github-actions` flag during execution:

```
set -o pipefail && xcodebuild [flags] | xcbeautify --renderer github-actions
```

### TeamCity

`xcbeautify` features an integrated TeamCity renderer that harnesses [service messages](https://www.jetbrains.com/help/teamcity/service-messages.html) to highlight warnings, errors, and results directly within the TeamCity user interface. To utilize this function, simply run `xcbeautify` and add the `--renderer teamcity` flag during execution:

```
set -o pipefail && xcodebuild [flags] | xcbeautify --renderer teamcity
```

### Azure DevOps Pipeline

`xcbeautify` features an integrated Azure DevOps Pipeline renderer that harnesses [logging commands](https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands) to highlight warnings, errors and results directly within the Azure DevOps Pipeline user interface. To utilize this function, simply run `xcbeautify` and add the `--renderer azure-devops-pipelines` flag during execution:

```
set -o pipefail && xcodebuild [flags] | xcbeautify --renderer azure-devops-pipelines
```

## Development

Generate Xcode project:

```sh
make xcode
```

Release a new version, e.g. `x.y.z`:

```bash
make release version=x.y.z
```

## Contributing

Please send a PR!
