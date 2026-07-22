# docker-images-flutter

A self-hosted Flutter + multi-SDK Android Docker image, published to `ghcr.io/petrleocompel/docker-images-flutter`.

This repo supersedes:
- [`cirrus-docker-flutter-images`](https://github.com/petrleocompel/cirrus-docker-flutter-images) — a fork of the now-deprecated [`cirruslabs/docker-images-flutter`](https://github.com/cirruslabs/docker-images-flutter) (Cirrus Labs wound down operations after an acquisition; that image and its own base, `ghcr.io/cirruslabs/android-sdk`, stopped receiving updates in May 2026).
- `docker-flutter-android-multi-sdk` — its Android SDK platform/build-tools/NDK/cmake package list has been folded directly into this repo's `Dockerfile`.

Everything here is built from scratch (plain Ubuntu base, Android cmdline-tools installed directly from Google, Flutter cloned directly from `flutter/flutter`) — no dependency on any Cirrus Labs image.

## How it works

- `.github/workflows/check-flutter-release.yml` runs weekly (Monday 06:00 UTC), checks Flutter's official [release manifest](https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json) for the current stable version, and pushes a matching git tag if it's new.
- `.github/workflows/publish.yml` triggers on that tag push (or manually via `workflow_dispatch`), builds the image, pushes `:<version>` and `:latest` to GHCR, ensures the package is public, and creates a GitHub Release.

## Included Android SDK packages

Platforms 33–37, build-tools 35.0.0/36.0.0/37.0.0, NDK 28.2.13676358, CMake 3.22.1.
