#!/usr/bin/env bash
# Installs the Choose AI terminal agent.
#
#   curl -fsSL https://raw.githubusercontent.com/markisthebest1234567-ctrl/Choose-AI-CLI/main/install.sh | bash
#
# Settings (all optional):
#   CHOOSEAI_REPO=owner/name      GitHub repository whose releases hold the binaries
#   CHOOSEAI_VERSION=v1.0.0       a specific release instead of the latest
#   CHOOSEAI_INSTALL_DIR=/path    where to put it (default /usr/local/bin)
#   CHOOSEAI_DOWNLOAD_BASE=URL    download from a mirror instead of GitHub
#
# Everything is inside main(), which runs only on the last line: if the
# download of this script is cut short, nothing half-written ever executes.

set -euo pipefail

# The one line to change before publishing: the repository with the releases.
DEFAULT_REPO="markisthebest1234567-ctrl/Choose-AI-CLI"

main() {
    local repo="${CHOOSEAI_REPO:-$DEFAULT_REPO}"
    local version="${CHOOSEAI_VERSION:-latest}"
    local install_dir="${CHOOSEAI_INSTALL_DIR:-/usr/local/bin}"
    local name="choose-ai"

    setup_colors
    say "${BOLD}${CYAN}Choose AI Terminal Agent${RESET} installer"

    # ── Where is this running? ──────────────────────────────────────
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"
    case "$os" in
        Darwin) ;;
        Linux) fail "The Choose AI CLI runs on macOS 13 or later. Linux is not supported yet." ;;
        *) fail "The Choose AI CLI runs on macOS 13 or later; this system is $os." ;;
    esac

    local macos major
    macos="$(sw_vers -productVersion 2>/dev/null || echo 0)"
    major="${macos%%.*}"
    if [ "${major:-0}" -lt 13 ]; then
        fail "macOS 13 or later is needed; this Mac has $macos."
    fi

    case "$arch" in
        arm64|aarch64) arch="arm64" ;;
        x86_64)
            # A shell running under Rosetta reports x86_64 on Apple silicon.
            if [ "$(sysctl -in sysctl.proc_translated 2>/dev/null || echo 0)" = "1" ]; then
                arch="arm64"
            fi
            ;;
        *) fail "Unsupported processor: $arch." ;;
    esac
    say "  ${GRAY}macOS $macos · $arch${RESET}"

    # ── Where to download from ──────────────────────────────────────
    local base
    if [ -n "${CHOOSEAI_DOWNLOAD_BASE:-}" ]; then
        base="${CHOOSEAI_DOWNLOAD_BASE%/}"
    else
        if [ "$repo" = "YOUR-GITHUB-USER/choose-ai" ]; then
            fail "This installer does not know which GitHub repository to download from yet. Set DEFAULT_REPO at the top of install.sh (or run with CHOOSEAI_REPO=owner/name)."
        fi
        case "$repo" in
            */*) ;;
            *) fail "CHOOSEAI_REPO must look like owner/name, not \"$repo\"." ;;
        esac
        if [ "$version" = "latest" ]; then
            base="https://github.com/$repo/releases/latest/download"
        else
            base="https://github.com/$repo/releases/download/$version"
        fi
    fi

    local asset="$name-macos-$arch.tar.gz"
    # Global, not local: the EXIT trap runs after main has returned.
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT

    # ── Download and check ──────────────────────────────────────────
    say "  Downloading ${asset}…"
    curl -fsSL --retry 3 --proto '=https,http' -o "$tmp/$asset" "$base/$asset" \
        || fail "Could not download $asset from $base. Check the release exists and has that file."
    curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "$base/SHA256SUMS" \
        || fail "Could not download SHA256SUMS from $base, so the download cannot be verified. Not installing."

    local expected actual
    expected="$(awk -v f="$asset" '$2 == f || $2 == "*"f { print $1 }' "$tmp/SHA256SUMS")"
    [ -n "$expected" ] || fail "SHA256SUMS has no entry for $asset. Not installing."
    actual="$(shasum -a 256 "$tmp/$asset" | awk '{ print $1 }')"
    [ "$expected" = "$actual" ] || fail "The download does not match its checksum (expected $expected, got $actual). Not installing."
    say "  ${GREEN}✔${RESET} Checksum verified"

    tar -xzf "$tmp/$asset" -C "$tmp"
    [ -f "$tmp/$name" ] || fail "The archive does not contain $name."
    chmod +x "$tmp/$name"
    "$tmp/$name" --version >/dev/null 2>&1 || fail "The downloaded binary does not run on this Mac."

    # ── Install ─────────────────────────────────────────────────────
    local sudo=""
    if [ ! -d "$install_dir" ]; then
        mkdir -p "$install_dir" 2>/dev/null || sudo="sudo"
    fi
    if [ -z "$sudo" ] && [ ! -w "$install_dir" ]; then
        sudo="sudo"
    fi
    if [ -n "$sudo" ]; then
        say "  Installing to $install_dir needs your password."
        sudo mkdir -p "$install_dir"
    fi
    $sudo install -m 0755 "$tmp/$name" "$install_dir/$name"
    $sudo chmod +x "$install_dir/$name"

    local installed
    installed="$("$install_dir/$name" --version 2>/dev/null || echo "?")"
    say ""
    say "${GREEN}${BOLD}✔ Choose AI $installed installed to $install_dir/$name${RESET}"

    case ":$PATH:" in
        *":$install_dir:"*) say "  Start it in a project folder: ${BOLD}$name${RESET}, then ${BOLD}/login${RESET}." ;;
        *) say "  ${YELLOW}$install_dir is not on your PATH.${RESET} Add it, or run ${BOLD}$install_dir/$name${RESET}." ;;
    esac
}

setup_colors() {
    if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
        BOLD=$'\033[1m'; CYAN=$'\033[36m'; GREEN=$'\033[32m'; RED=$'\033[31m'
        YELLOW=$'\033[33m'; GRAY=$'\033[90m'; RESET=$'\033[0m'
    else
        BOLD=""; CYAN=""; GREEN=""; RED=""; YELLOW=""; GRAY=""; RESET=""
    fi
}

say() { printf '%s\n' "$*"; }

fail() {
    printf '%s\n' "${RED}✖ $*${RESET}" >&2
    exit 1
}

main "$@"
