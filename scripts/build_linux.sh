#!/usr/bin/env bash
# Build WE2002Recompiled for Linux x64 from a fresh clone.
#
# Steps (each one is safe to run again):
#   1. initialize the submodules at their pinned commits
#   2. build the psxrecomp recompiler
#   3. regenerate the OpenBIOS backend (optional, --regen-bios; its C is
#      already versioned in the psxrecomp pin)
#   4. configure and build the game, staging the overlay toolchain
#
# The game disc is not needed to build. Packaging lives in package_*.sh.
#
# Usage: scripts/build_linux.sh [-j N] [--build-dir DIR] [--regen-bios]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="build-linux"
JOBS=""
REGEN_BIOS=0

usage() {
  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -j)
      [[ $# -ge 2 ]] || { echo "error: -j needs a number" >&2; exit 2; }
      JOBS="$2"; shift 2 ;;
    -j*) JOBS="${1#-j}"; shift ;;
    --build-dir)
      [[ $# -ge 2 ]] || { echo "error: --build-dir needs a path" >&2; exit 2; }
      BUILD_DIR="$2"; shift 2 ;;
    --regen-bios) REGEN_BIOS=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -n "${JOBS}" && ! "${JOBS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "error: -j expects a positive integer, got '${JOBS}'" >&2
  exit 2
fi
if [[ -n "${JOBS}" ]]; then
  export CMAKE_BUILD_PARALLEL_LEVEL="${JOBS}"
fi

for tool in git cmake ninja python3 gcc g++; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "error: '${tool}' not found on PATH" >&2
    exit 1
  fi
done

cd "${ROOT}"

echo "==> [1/4] submodules"
git submodule sync --recursive
git submodule update --init --recursive

echo "==> [2/4] recompiler"
cmake -S psxrecomp/recompiler -B psxrecomp/recompiler/build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release
cmake --build psxrecomp/recompiler/build

if [[ "${REGEN_BIOS}" -eq 1 ]]; then
  echo "==> [3/4] OpenBIOS backend"
  (cd psxrecomp && bash tools/regen_bios.sh --config bios/OpenBIOS.toml)
else
  echo "==> [3/4] OpenBIOS backend: using the versioned C (pass --regen-bios to regenerate)"
fi

echo "==> [4/4] game (${BUILD_DIR})"
python3 psxrecomp/psxrecomp_cli.py rebuild \
  --config game.toml \
  --project-root . \
  --build-dir "${BUILD_DIR}" \
  --no-pgo \
  --cmake-extra=-DPSX_SDL_BACKEND=SDL3 \
  --cmake-extra=-DPSX_PGXP_VARIANT=OFF \
  --cmake-extra=-DPSX_NETPLAY=OFF

exe="${BUILD_DIR}/WE2002Recompiled"
if [[ ! -x "${exe}" ]]; then
  echo "error: build finished but ${exe} is missing" >&2
  exit 1
fi
echo "==> done: ${ROOT}/${exe}"
