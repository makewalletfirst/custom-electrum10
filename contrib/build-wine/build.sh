#!/bin/bash
#
# env vars:
# - ELECBUILD_NOCACHE: if set, forces rebuild of docker image
# - ELECBUILD_COMMIT: if set, do a fresh clone and git checkout

set -e

PROJECT_ROOT="$(dirname "$(readlink -e "$0")")/../.."
PROJECT_ROOT_OR_FRESHCLONE_ROOT="$PROJECT_ROOT"
CONTRIB="$PROJECT_ROOT/contrib"
CONTRIB_WINE="$CONTRIB/build-wine"

# [수정] 현재 폴더 소유자의 UID를 가져오되, 
# 만약 root(0)라면 빌드 중복 에러 방지를 위해 강제로 1000을 사용하도록 처리할 수 있습니다.
BUILD_UID=$(/usr/bin/stat -c %u "$PROJECT_ROOT")
if [ "$BUILD_UID" == "0" ]; then
    BUILD_UID=1000
fi

. "$CONTRIB"/build_tools_util.sh

info "Clearing $CONTRIB_WINE/dist..."
rm -rf "$CONTRIB_WINE"/dist/*


DOCKER_BUILD_FLAGS=""
if [ ! -z "$ELECBUILD_NOCACHE" ] ; then
    info "ELECBUILD_NOCACHE is set. forcing rebuild of docker image."
    DOCKER_BUILD_FLAGS="--pull --no-cache"
fi

if [ -z "$ELECBUILD_COMMIT" ] ; then  # local dev build
    DOCKER_BUILD_FLAGS="$DOCKER_BUILD_FLAGS --build-arg UID=$BUILD_UID"
fi

info "building docker image."
docker build \
    $DOCKER_BUILD_FLAGS \
    -t electrum-wine-builder-img \
    "$CONTRIB_WINE"

# maybe do fresh clone
if [ ! -z "$ELECBUILD_COMMIT" ] ; then
    info "ELECBUILD_COMMIT=$ELECBUILD_COMMIT. doing fresh clone and git checkout."
    FRESH_CLONE="/tmp/electrum_build/windows/fresh_clone/electrum"
    rm -rf "$FRESH_CLONE" 2>/dev/null || ( info "we need sudo to rm prev FRESH_CLONE." && sudo rm -rf "$FRESH_CLONE" )
    umask 0022
    git clone "$PROJECT_ROOT" "$FRESH_CLONE"
    cd "$FRESH_CLONE"
    git checkout "$ELECBUILD_COMMIT"
    PROJECT_ROOT_OR_FRESHCLONE_ROOT="$FRESH_CLONE"
else
    info "not doing fresh clone."
fi

info "building binary..."

# [추가] 빌드 직전 소유권을 다시 한번 확실히 정리 (서브모듈 생성 대비)
# 호스트가 root이므로 직접 실행 가능합니다.
chown -R $BUILD_UID:$BUILD_UID "$PROJECT_ROOT"

# [수정] docker run 옵션 강화
# --privileged: 타임스탬프 수정(touch) 및 하드웨어 접근 권한 허용
# --security-opt seccomp=unconfined: Wine의 네트워크 소켓 호출 차단 해제
docker run -it \
    --name electrum-wine-builder-cont \
    --privileged \
    --security-opt seccomp=unconfined \
    -v "$PROJECT_ROOT_OR_FRESHCLONE_ROOT":/opt/wine64/drive_c/electrum \
    --rm \
    --workdir /opt/wine64/drive_c/electrum/contrib/build-wine \
    electrum-wine-builder-img \
    ./make_win.sh

# make sure resulting binary location is independent of fresh_clone
if [ ! -z "$ELECBUILD_COMMIT" ] ; then
    mkdir --parents "$PROJECT_ROOT/contrib/build-wine/dist/"
    cp -f "$FRESH_CLONE/contrib/build-wine/dist"/*.exe "$PROJECT_ROOT/contrib/build-wine/dist/"
fi
