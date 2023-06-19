#!/bin/bash -e

NINJA_PARAMS=
while getopts 'j:' opt; do
  case ${opt} in
    j)
      NINJA_PARAMS="-j$OPTARG"
      ;;
    *)
      echo "ignored option '$opt'"
      ;;
  esac
done
shift $((OPTIND - 1))

source "$(dirname "$0")/env.sh"

# $1 is ${PLATFORM} which parse commonly from env.sh
ARCH=$2

GN_ARGS_BASE="
  is_component_build=false
  v8_monolithic=true
  v8_static_library=true
  use_custom_libcxx=false
  treat_warnings_as_errors=false
  v8_use_external_startup_data=false
  v8_enable_i18n_support=false
  target_os=\"${PLATFORM}\"
"

if [[ ${PLATFORM} = "ios" ]]; then
  GN_ARGS_BASE="
    ${GN_ARGS_BASE}
    ios_enable_code_signing=false
    v8_enable_pointer_compression=false
    v8_enable_lite_mode=true
    v8_control_flow_integrity=false
    v8_enable_sandbox=false
    ios_deployment_target=\"${IOS_DEPLOYMENT_TARGET}\"
    target_environment=\"${IOS_TARGET_ENV}\"
  "
  # Build certain components
  NINJA_TARGETS=(
    ${IOS_MODULES[@]}
    inspector
  )
elif [[ ${PLATFORM} = "android" ]]; then
  # Workaround v8 sysroot build issues with custom ndk
  GN_ARGS_BASE="${GN_ARGS_BASE} use_thin_lto=false use_sysroot=false"
  # WebAssembly not compatible with JITless lite mode
  GN_ARGS_BASE="$GN_ARGS_BASE
    v8_enable_webassembly=true
    default_min_sdk_version=17
  "
  # Default target
  NINJA_TARGETS=()
fi

if [[ "$BUILD_TYPE" = "debug" ]]
then
  GN_ARGS_BUILD_TYPE='
    is_debug=true
    v8_enable_v8_checks=true
    v8_enable_debugging_features=true
    v8_enable_object_print=true
    symbol_level=2
  '
else
  GN_ARGS_BUILD_TYPE='
    is_official_build=true
    is_debug=false
    v8_enable_v8_checks=false
    v8_enable_debugging_features=false
    symbol_level=0
  '
fi

if [[ "$PLATFORM" = ios && "$BUILD_TYPE" = debug ]]; then
  # iOS overrides is_component_build to be the value of is_debug, and component
  # build is incompatible with monolithic. Override monolithic in that case.
  GN_ARGS_BUILD_TYPE="$GN_ARGS_BUILD_TYPE v8_monolithic=false"
fi

cd "$V8_DIR"

function buildArch()
{
  local arch=$1

  echo "Build v8 ${arch}"
  gn gen --args="${GN_ARGS_BASE} ${GN_ARGS_BUILD_TYPE} v8_target_cpu=\"${arch}\" target_cpu=\"${arch}\"" "out.v8.${arch}"

  date ; ninja "$NINJA_PARAMS" -C "out.v8.$arch" "${NINJA_TARGETS[@]}" ; date
}

if [[ ${ARCH} ]]; then
  buildArch "${ARCH}"
elif [[ ${PLATFORM} = "android" ]]; then
  # buildArch "arm"
  # buildArch "x86"
  buildArch "arm64"
  # buildArch "x64"
elif [[ ${PLATFORM} = "ios" ]]; then
  buildArch "arm64"
  # buildArch "x64"
fi
