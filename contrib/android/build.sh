#!/bin/bash
set -e

PROJECT_ROOT="$(dirname "$(readlink -e "$0")")/../.."
PROJECT_ROOT_OR_FRESHCLONE_ROOT="$PROJECT_ROOT"
CONTRIB="$PROJECT_ROOT/contrib"
CONTRIB_ANDROID="$CONTRIB/android"
DISTDIR="$PROJECT_ROOT/dist"

# [핵심] root 빌드 시 UID 0 에러 방지 로직
BUILD_UID=$(/usr/bin/stat -c %u "$PROJECT_ROOT")
if [ "$BUILD_UID" == "0" ]; then
    BUILD_UID=1000
fi

. "$CONTRIB"/build_tools_util.sh

# check arguments
if [[ -n "$3" \
          && ( "$1" == "qml" ) \
          && ( "$2" == "all"  || "$2" == "armeabi-v7a" || "$2" == "arm64-v8a" || "$2" == "x86" || "$2" == "x86_64" ) \
          && ( "$3" == "debug"  || "$3" == "release" || "$3" == "release-unsigned" ) ]] ; then
    info "arguments $1 $2 $3"
else
    fail "usage: build.sh <qml|...> <arm64-v8a|armeabi-v7a|x86|x86_64|all> <debug|release|release-unsigned>"
    exit 1
fi

rm -f ${PROJECT_ROOT}/.buildozer
mkdir -p "${PROJECT_ROOT}/.buildozer_$1"
ln -s ".buildozer_$1" ${PROJECT_ROOT}/.buildozer

DOCKER_BUILD_FLAGS=""
if [ -z "$ELECBUILD_COMMIT" ] ; then
    DOCKER_BUILD_FLAGS="$DOCKER_BUILD_FLAGS --build-arg UID=$BUILD_UID"
fi

info "building docker image."
docker build $DOCKER_BUILD_FLAGS -t electrum-android-builder-img --file "$CONTRIB_ANDROID/Dockerfile" "$PROJECT_ROOT"

info "building binary..."
mkdir --parents "$PROJECT_ROOT_OR_FRESHCLONE_ROOT"/.buildozer/.gradle
chown -R $BUILD_UID:$BUILD_UID "$PROJECT_ROOT_OR_FRESHCLONE_ROOT"

docker run -it --rm \
    --name electrum-android-builder-cont \
    -v "$PROJECT_ROOT_OR_FRESHCLONE_ROOT":/home/user/wspace/electrum \
    -v "$PROJECT_ROOT_OR_FRESHCLONE_ROOT"/.buildozer/.gradle:/home/user/.gradle \
    --workdir /home/user/wspace/electrum \
    electrum-android-builder-img \
    ./contrib/android/make_apk.sh "$@"
