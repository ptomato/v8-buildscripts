#!/bin/bash -e

GCLIENT_SYNC_ARGS=(--reset --with_branch_head)
while getopts 'r:s' opt; do
  case ${opt} in
    r)
      GCLIENT_SYNC_ARGS=("${GCLIENT_SYNC_ARGS[@]}" --revision "$OPTARG")
      ;;
    s)
      GCLIENT_SYNC_ARGS=("${GCLIENT_SYNC_ARGS[@]}" --no-history)
      ;;
    *)
      echo "ignored option '$opt'"
      ;;
  esac
done
shift $((OPTIND - 1))

source "$(dirname "$0")/env.sh"

# Install NDK
function installNDK() {
  local ndk_filename="android-ndk-${NDK_VERSION}-linux-x86_64.zip"
  pushd .
  cd "${V8_DIR}"
  wget -q "https://dl.google.com/android/repository/${ndk_filename}"
  unzip -q "$ndk_filename"
  rm -f "$ndk_filename"
  popd
}

if [[ ! -d "${DEPOT_TOOLS_DIR}" || ! -f "${DEPOT_TOOLS_DIR}/gclient" ]]; then
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "${DEPOT_TOOLS_DIR}"
fi

echo Running: gclient config --name v8 --unmanaged "https://chromium.googlesource.com/v8/v8.git"
gclient config --name v8 --unmanaged "https://chromium.googlesource.com/v8/v8.git"

if [[ ${PLATFORM} = "ios" ]]; then
  echo Running: gclient sync --deps=ios "${GCLIENT_SYNC_ARGS[@]}"
  gclient sync --deps=ios "${GCLIENT_SYNC_ARGS[@]}"
  exit 0
fi

if [[ ${PLATFORM} = "android" ]]; then
  gclient sync --deps=android "${GCLIENT_SYNC_ARGS[@]}"

  # Patch build-deps installer to install fewer dependencies
  patch -d "${V8_DIR}" -p1 < "${PATCHES_DIR}/fewer_deps.patch"

  sudo bash -c 'v8/build/install-build-deps.py --android --arm --no-backwards-compatible'
  sudo apt-get -y install \
      lib32stdc++-9-dev \
      libx32stdc++-9-dev

  # Reset changes after installation
  patch -d "${V8_DIR}" -p1 -R < "${PATCHES_DIR}/fewer_deps.patch"

  # # Workaround to install missing sysroot
  # gclient sync

  # # Workaround to install missing android_sdk tools
  # gclient sync --deps=android

  installNDK
  exit 0
fi
