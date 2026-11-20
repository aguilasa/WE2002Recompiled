# Winning Eleven 2002 Recompiled

Unofficial static recompilation of Winning Eleven 2002 for Windows and Linux, originally released for the Sony PlayStation in 2002.

This project translates the original MIPS machine code into C and compiles it into a native Windows x64 or Linux x64 executable, preserving the original gameplay, graphics, audio and game mechanics through the PSXRecomp runtime.

## Game Information

| | |
|---|---|
| Developer | Konami |
| Release Year | 2002 |
| Original Platform | PlayStation |
| Target Platform | Windows x64 / Linux x64 |
| Game ID | SLPM-87056 |
| Region | NTSC-J |
| Players | 1–2 |
| Languages | C / C++ |
| Version | 0.1.0 |

## Features

- Static MIPS to C recompilation.
- Native Windows x64 and Linux x64 executables.
- OpenGL rendering.
- SDL3 integration.
- 60 FPS operation observed during testing.
- Configurable resolution.
- Keyboard and controller support.
- OpenBIOS support.
- Local multiplayer.
- Portable disc directory.

## Installation (Windows)

1. Download the repository using Code → Download ZIP.
2. Extract the downloaded archive.
3. Place your own compatible game disc image inside the Windows/disc directory.
4. Make sure the BIN and CUE files are named WE2002.bin and WE2002.cue.
5. Run WE2002Recompiled.exe inside the Windows directory.

Additional setup may be required on first launch.

The Download ZIP archive does not include the git submodules (`psxrecomp/`, `recomp-ui/`). It is enough to run the prebuilt Windows executable, but not to build the game: for that, clone the repository as shown below.

## Building on Linux

Tested on Ubuntu 24.04 (Zorin OS 18.1) x64, X11 session, with Intel and NVIDIA GPUs.

### Requirements

- GCC (`build-essential`), CMake 3.20 or newer, Ninja, pkg-config and Python 3. GCC is required: it compiles the disc overlays at run time. Clang is optional; when installed, the game build uses it.
- SDL3 3.4 or newer is used when the system has it, with its development files. Otherwise the build downloads the pinned SDL3 release, which needs network access.
- OpenGL and windowing development packages, for example on Ubuntu:

  ```sh
  sudo apt install build-essential cmake ninja-build pkg-config python3 \
      libgl-dev libx11-dev libxext-dev libwayland-dev libxkbcommon-dev libdecor-0-dev
  ```

- Optional: `ccache`, which speeds up rebuilds of the large generated sources.
- To package the optimized release (`scripts/package_release.sh`), a CMake newer than the 3.28 shipped by Ubuntu 24.04: its runtime configure passes an empty `CMAKE_PROJECT_INCLUDE`, which CMake 3.28.3 rejects. CMake 4.4.5 from PyPI works, for example `python3 -m venv ~/cmake-venv && ~/cmake-venv/bin/pip install cmake`, then put `~/cmake-venv/bin` first on `PATH`. The game build itself works with 3.28.

### Build

Clone with the submodules; the build needs them at their pinned commits:

```sh
git clone --recurse-submodules https://github.com/aguilasa/WE2002Recompiled.git
cd WE2002Recompiled
scripts/build_linux.sh
```

`scripts/build_linux.sh` initializes the submodules, builds the recompiler and builds the game in `build-linux/`, including the toolchain that compiles disc overlays at run time. It can be run again at any time. Options: `-j N` (parallel jobs), `--build-dir DIR` and `--regen-bios` (regenerate the OpenBIOS backend instead of using the versioned one).

The result is `build-linux/WE2002Recompiled`. No game disc is needed to build.

### Game disc

Put your own disc image in `build-linux/disc/`, as a cue sheet named `WE2002.cue` next to the `.bin` files it lists (a multi-track image keeps one `.bin` per track). To check and normalize a dump first:

```sh
python3 psxrecomp/tools/prepare_disc.py --config game.toml --project-root . \
    --out-dir build-linux/disc --skip-hash-check "/path/to/your/image.cue"
```

`--skip-hash-check` is needed because the digests in `game.toml` describe a different dump of the game.

### Run

```sh
cd build-linux
./WE2002Recompiled --no-launcher --disc disc/WE2002.cue
```

On a hybrid Intel/NVIDIA laptop, run it on the NVIDIA GPU with `__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia`. Memory card saves are written to `saves/` at the repository root.

## Project Goals

- Improve game compatibility and performance.
- Enhance graphics and rendering.
- Implement widescreen improvements.
- Expand customization and modding capabilities.
- Reverse engineer original game mechanics.
- Preserve classic football gameplay on modern computers.

## Project Status

Experimental and under development. The game has been successfully recompiled and tested on Windows and Linux.

## Credits

- Konami: Original game.
- PSXRecomp: Static recompilation framework.
- OpenBIOS: Open-source PlayStation BIOS.
- SDL3: Multimedia library.

## Disclaimer

This is an unofficial, non-commercial project focused on game preservation, reverse engineering and technical research.

This repository does not include the original game disc image. Users must provide their own legally obtained copy of Winning Eleven 2002.

All original game rights belong to their respective owners.
