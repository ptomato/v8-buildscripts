#!/bin/bash -e
source "$(dirname "$0")/env.sh"

function normalize_env() {
  case "$1" in
    device)
      echo "iphoneos"
      ;;
    simulator)
      echo "iphonesimulator"
      ;;
    catalyst)
      echo "maccatalyst"
      ;;
    *)
      echo "Invalid iOS environment - $1" >&2
      exit 1
      ;;
  esac
}

function normalize_arch_for_platform() {
  if [[ $PLATFORM = "ios" ]]; then
    case "$1" in
      arm64)
        echo "arm64-$(normalize_env "$IOS_TARGET_ENV")"
        ;;
      x64)
        echo "x86_64-$(normalize_env "$IOS_TARGET_ENV")"
        ;;
      *)
        echo "Invalid arch - $1" >&2
        exit 1
        ;;
    esac
    return
  fi

  case "$1" in
    arm)
      echo "armeabi-v7a"
      ;;
    x86)
      echo "x86"
      ;;
    arm64)
      echo "arm64-v8a"
      ;;
    x64)
      echo "x86_64"
      ;;
    *)
      echo "Invalid arch - $1" >&2
      exit 1
      ;;
  esac
}

ARCH="$2"
WHAT_TO_COPY="$3"

NORMALIZED_ARCH=$(normalize_arch_for_platform "$ARCH")

DIST_PACKAGE_DIR="${DIST_DIR}/packages/v8-${PLATFORM}"
mkdir -p "$DIST_PACKAGE_DIR"

BUILD_ARCH_OUTPUT="$V8_DIR/out.v8.$ARCH"
ANDROID_DIST_PATH="$DIST_PACKAGE_DIR/test-app/runtime/src/main"
IOS_DIST_PATH="$DIST_PACKAGE_DIR/NativeScript"

function copyEverything() {
  mkdir -p "$DIST_PACKAGE_DIR/$NORMALIZED_ARCH"
  cp -Rf "$V8_DIR/out.v8.$ARCH" "$DIST_PACKAGE_DIR/$NORMALIZED_ARCH/"
}

function copyDylibAndroid() {
  printf "\n\n\t\t===================== copy dylib =====================\n\n"
  mkdir -p "$ANDROID_DIST_PATH/libs/$NORMALIZED_ARCH/"
  cp -f "$BUILD_ARCH_OUTPUT/obj/libv8_monolith.a" "$ANDROID_DIST_PATH/libs/$NORMALIZED_ARCH/"
}

function copyDylibIOS() {
  printf "\n\n\t\t===================== copy dylib =====================\n\n"
  LIBDIR="$IOS_DIST_PATH/lib/$NORMALIZED_ARCH/"
  mkdir -p "$LIBDIR"
  pushd "$BUILD_ARCH_OUTPUT/obj/" >/dev/null
  # libv8_heap_base_headers.a only present in debug builds
  cp -f libcppgc_base.a libtorque_generated_definitions.a \
    libtorque_generated_initializers.a libv8_base_without_compiler.a \
    libv8_bigint.a libv8_compiler.a libv8_heap_base*.a \
    libv8_libbase.a libv8_libplatform.a libv8_snapshot.a \
    "$LIBDIR"
  popd >/dev/null
  pushd "$BUILD_ARCH_OUTPUT/obj/third_party/inspector_protocol/" >/dev/null
  cp -f libcrdtp.a libcrdtp_platform.a "$LIBDIR"
  popd >/dev/null
  pushd "$BUILD_ARCH_OUTPUT/obj/src/inspector/" >/dev/null
  cp -f libinspector.a libinspector_string_conversions.a "$LIBDIR"
  popd >/dev/null
  unset LIBDIR
}

function copyHeadersAndroid() {
  printf "\n\n\t\t===================== adding headers to %s =====================\n\n" "$ANDROID_DIST_PATH"
  mkdir -p "$ANDROID_DIST_PATH/cpp/"
  cp -Rf "$V8_DIR/include" "$ANDROID_DIST_PATH/cpp/"
  cp -Rf "$BUILD_ARCH_OUTPUT/gen/include" "$ANDROID_DIST_PATH/cpp/"
  mkdir -p "$ANDROID_DIST_PATH/cpp/v8_inspector/src/base/platform/"
  cp -f "$V8_DIR/src/base/"*.h "$ANDROID_DIST_PATH/cpp/v8_inspector/src/base/"
  cp -f "$V8_DIR/src/base/platform/"*.h "$ANDROID_DIST_PATH/cpp/v8_inspector/src/base/platform/"
  mkdir -p "$ANDROID_DIST_PATH/cpp/v8_inspector/src/common/"
  cp -f "$V8_DIR/src/common/"*.h "$ANDROID_DIST_PATH/cpp/v8_inspector/src/common/"
  mkdir -p "$ANDROID_DIST_PATH/cpp/v8_inspector/src/debug/"
  cp -f "$V8_DIR/src/debug/"*.h "$ANDROID_DIST_PATH/cpp/v8_inspector/src/debug/"
  mkdir -p "$ANDROID_DIST_PATH/cpp/v8_inspector/src/inspector/protocol/"
  cp -f "$V8_DIR/src/inspector/"*.{h,json} "$ANDROID_DIST_PATH/cpp/v8_inspector/src/inspector/"
  cp -f "$BUILD_ARCH_OUTPUT/gen/src/inspector/protocol/"*.h \
    "$ANDROID_DIST_PATH/cpp/v8_inspector/src/inspector/protocol"
  mkdir -p "$ANDROID_DIST_PATH/cpp/v8_inspector/third_party/inspector_protocol/crdtp/"
  cp -f "$V8_DIR/third_party/inspector_protocol/crdtp/"*.h \
    "$ANDROID_DIST_PATH/cpp/v8_inspector/third_party/inspector_protocol/crdtp/"
}

function copyHeadersIOS() {
  printf "\n\n\t\t===================== adding headers to %s =====================\n\n" "$IOS_DIST_PATH"
  mkdir -p "$IOS_DIST_PATH/"
  cp -Rf "$V8_DIR/include" "$IOS_DIST_PATH/"
  cp -Rf "$BUILD_ARCH_OUTPUT/gen/include" "$IOS_DIST_PATH/"
  mkdir -p "$IOS_DIST_PATH/inspector/src/base/platform/"
  cp -f "$V8_DIR/src/base/"*.h "$IOS_DIST_PATH/inspector/src/base/"
  cp -f "$V8_DIR/src/base/platform/"*.h "$IOS_DIST_PATH/inspector/src/base/platform/"
  mkdir -p "$IOS_DIST_PATH/inspector/src/common/"
  cp -f "$V8_DIR/src/common/"*.h "$IOS_DIST_PATH/inspector/src/common/"
  mkdir -p "$IOS_DIST_PATH/inspector/src/debug/"
  cp -f "$V8_DIR/src/debug/"*.h "$IOS_DIST_PATH/inspector/src/debug/"
  mkdir -p "$IOS_DIST_PATH/inspector/src/inspector/protocol/"
  cp -f "$V8_DIR/src/inspector/"*.h "$IOS_DIST_PATH/inspector/src/inspector/"
  cp -f "$BUILD_ARCH_OUTPUT/gen/src/inspector/protocol/"*.h \
    "$IOS_DIST_PATH/inspector/src/inspector/protocol"
  mkdir -p "$IOS_DIST_PATH/inspector/third_party/inspector_protocol/crdtp/"
  cp -f "$V8_DIR/third_party/inspector_protocol/crdtp/"*.h \
    "$IOS_DIST_PATH/inspector/third_party/inspector_protocol/crdtp/"
}

if [[ "$WHAT_TO_COPY" == "all_build_products" ]]; then
  copyEverything
  exit 0
fi

if [[ ${PLATFORM} = "android" ]]; then
  copyDylibAndroid
  if [[ "$WHAT_TO_COPY" == *"headers"* ]]; then
    copyHeadersAndroid
  fi
elif [[ ${PLATFORM} = "ios" ]]; then
  copyDylibIOS
  if [[ "$WHAT_TO_COPY" == *"headers"* ]]; then
    copyHeadersIOS
  fi
fi
