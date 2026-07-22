FROM ubuntu:24.04

ARG FLUTTER_VERSION
ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    FLUTTER_HOME=/opt/flutter
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip ca-certificates openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Android cmdline-tools build number — see https://developer.android.com/studio#command-line-tools-only
# for the current build; this is the one input in this Dockerfile that may need an occasional manual bump.
ARG CMDLINE_TOOLS_BUILD=15859902
RUN curl -sL -o /tmp/cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_BUILD}_latest.zip" \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# sdkmanager is deprecated in favor of the `android` CLI (bundled in cmdline-tools), used here
# for package installation. --sdk must be passed explicitly: unlike sdkmanager, this tool ignores
# ANDROID_SDK_ROOT and otherwise defaults to installing into ~/Android/Sdk.
RUN yes | android --sdk=${ANDROID_SDK_ROOT} sdk install \
      "platform-tools" \
      "platforms;android-33" \
      "platforms;android-34" \
      "platforms;android-35" \
      "platforms;android-36" \
      "platforms;android-37.0" \
      "build-tools;35.0.0" \
      "build-tools;36.0.0" \
      "build-tools;37.0.0" \
      "ndk;28.2.13676358" \
      "cmake;3.22.1"

# The `android` CLI has no license-acceptance mechanism at all (confirmed against Google's own
# docs) — its one-time Terms-of-Service prompt only covers the android-sdk-license, not the
# per-component licenses (preview, arm-dbt, googletv, googlexr, gdk, mips) that Gradle/Flutter
# builds actually check for. sdkmanager --licenses is still required for those.
RUN yes | sdkmanager --licenses

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter doctor \
    && flutter precache
