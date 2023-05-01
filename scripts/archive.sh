#!/bin/bash -e
source $(dirname $0)/env.sh

DIST_PACKAGE_DIR="${DIST_DIR}/packages/v8-${PLATFORM}"

function copyDylib() {
  printf "\n\n\t\t===================== copy dylib =====================\n\n"
  mkdir -p "${DIST_PACKAGE_DIR}"
  cp -Rf "${BUILD_DIR}/lib" "${DIST_PACKAGE_DIR}/"
}

function copyHeaders() {
  printf "\n\n\t\t===================== adding headers to ${DIST_PACKAGE_DIR}/include =====================\n\n"
  cp -Rf "${V8_DIR}/include" "${DIST_PACKAGE_DIR}/include"
}

if [[ ${PLATFORM} = "android" ]]; then
  # export ANDROID_HOME="${V8_DIR}/third_party/android_sdk/public"
  # export ANDROID_NDK="${V8_DIR}/third_party/android_ndk"
  # export PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}
  # yes | sdkmanager --licenses

  mkdir -p "${DIST_PACKAGE_DIR}"
  copyDylib
  # copyHeaders
elif [[ ${PLATFORM} = "ios" ]]; then
  copyDylib
  # copyHeaders
fi
