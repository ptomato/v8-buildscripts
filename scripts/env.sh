#!/bin/bash -e

function abs_path()
{
  readlink="readlink -f"
  if [[ "$(uname)" == "Darwin" ]]; then
    if [[ ! "$(command -v greadlink)" ]]; then
      echo "greadlink not found. Please install greadlink by \`brew install coreutils\`" >&2
      exit 1
    fi
    readlink="greadlink -f"
  fi

  $readlink "$1"
}

function verify_platform()
{
  local arg=$1
  SUPPORTED_PLATFORMS=(android ios)
  local valid_platform=
  for platform in "${SUPPORTED_PLATFORMS[@]}"
  do
    if [[ ${arg} = "$platform" ]]; then
      valid_platform=${platform}
    fi
  done
  if [[ -z ${valid_platform} ]]; then
    echo "Invalid platform: ${arg}" >&2
    exit 1
  fi
  echo "$valid_platform"
}

CURR_DIR=$(dirname "$(abs_path "$0")")
ROOT_DIR=$(dirname "$CURR_DIR")
export ROOT_DIR
unset CURR_DIR

export DEPOT_TOOLS_DIR="$ROOT_DIR/scripts/depot_tools"
export BUILD_DIR="$ROOT_DIR/build"
export V8_DIR="$ROOT_DIR/v8"
export DIST_DIR="$ROOT_DIR/dist"
export PATCHES_DIR="$ROOT_DIR/patches"

export NDK_VERSION="r21e"
export IOS_DEPLOYMENT_TARGET="12"
# "simulator", "device", "catalyst"
export IOS_TARGET_ENV=${IOS_TARGET_ENV:-simulator}

export PATH="$DEPOT_TOOLS_DIR:$PATH"
PLATFORM=$(verify_platform "$1")
export PLATFORM

export IOS_MODULES=(
  cppgc_base
  torque_generated_definitions
  torque_generated_initializers
  v8_base_without_compiler
  v8_bigint
  v8_compiler
  v8_heap_base
  v8_heap_base_headers
  v8_libbase
  v8_libplatform
  v8_snapshot
)
