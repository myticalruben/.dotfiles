#!/usr/bin/env bash
#
# Install the dependencies these dotfiles need, then link the configs.
#
# Does nothing to the system unless you pass --install: the default is a
# read-only report of what is missing.

set -uo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pkg_dir="$repo_dir/packages"

mode="check"
case "${1:-}" in
    --install)      mode="install" ;;
    --verify-names) mode="verify-names" ;;
    --check|"")     mode="check" ;;
    -h|--help)
        cat <<EOF
Usage: install.sh [OPTION]

  --check          report which required commands are missing (default)
  --verify-names   check that the package names for this distro resolve
  --install        add repositories, install packages, link configs
  -h, --help       this message
EOF
        exit 0 ;;
    *)
        echo "Unknown option: $1 (try --help)" >&2
        exit 2 ;;
esac

# ---------------------------------------------------------------- distro ----

distro=""
distro_name=""
if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    distro_name="${PRETTY_NAME:-$ID}"
    case "$ID" in
        ubuntu)        distro="ubuntu" ;;
        debian)        distro="debian" ;;
        arch|endeavouros|cachyos|manjaro) distro="arch" ;;
        *)
            case "${ID_LIKE:-}" in
                *ubuntu*) distro="ubuntu" ;;
                *debian*) distro="debian" ;;
                *arch*)   distro="arch" ;;
            esac ;;
    esac
fi

if [[ -z "$distro" ]]; then
    echo "Could not identify the distro from /etc/os-release."
    echo "Supported: Ubuntu, Debian, Arch (and derivatives)."
    echo "The command check below still works everywhere."
    echo
fi

echo "Distro:  ${distro_name:-unknown}${distro:+  (using packages/$distro.txt)}"
echo "Repo:    $repo_dir"
echo

# --------------------------------------------------------------- helpers ----

# Strip comments and blank lines from a manifest.
read_list() {
    [[ -r "$1" ]] || return 0
    sed -e 's/#.*//' -e '/^[[:space:]]*$/d' -e 's/[[:space:]]*$//' "$1"
}

have() { command -v "$1" >/dev/null 2>&1; }

# A manifest entry may offer alternatives as "a/b": either satisfies it.
have_any() {
    local IFS=/ alt
    for alt in $1; do
        have "$alt" && return 0
    done
    return 1
}

# ----------------------------------------------------------- check mode -----

missing_commands=()
check_commands() {
    local line cmd purpose
    echo "Required commands:"
    while IFS= read -r line; do
        cmd="${line%%|*}";     cmd="${cmd//[[:space:]]/}"
        purpose="${line#*|}";  purpose="${purpose#"${purpose%%[![:space:]]*}"}"
        [[ -z "$cmd" ]] && continue
        if have_any "$cmd"; then
            printf '  ok      %s\n' "$cmd"
        else
            printf '  MISSING %-18s %s\n' "$cmd" "$purpose"
            missing_commands+=("$cmd")
        fi
    done < <(read_list "$pkg_dir/required-commands.txt")
    echo
    if (( ${#missing_commands[@]} == 0 )); then
        echo "Nothing missing."
    else
        echo "${#missing_commands[@]} missing. Run with --install, and see"
        echo "packages/manual.md for the ones no distro packages."
    fi
}

# ---------------------------------------------------- package-name check ----

verify_names() {
    [[ -n "$distro" ]] || { echo "Cannot verify names: unknown distro." >&2; return 1; }
    local pkg unresolved=()
    echo "Checking that every name in packages/$distro.txt resolves..."
    echo
    while IFS= read -r pkg; do
        case "$distro" in
            ubuntu|debian)
                if [[ "$(apt-cache policy "$pkg" 2>/dev/null | grep -c .)" -eq 0 ]]; then
                    unresolved+=("$pkg")
                fi ;;
            arch)
                pacman -Si "$pkg" >/dev/null 2>&1 || unresolved+=("$pkg") ;;
        esac
    done < <(read_list "$pkg_dir/$distro.txt")

    if (( ${#unresolved[@]} == 0 )); then
        echo "All names resolve."
    else
        echo "These names do not resolve on this machine:"
        printf '  %s\n' "${unresolved[@]}"
        echo
        echo "Either a repository is missing (see packages/$distro-ppa.txt if"
        echo "there is one) or the name is wrong - correct packages/$distro.txt."
    fi
}

# -------------------------------------------------------------- install -----

confirm() {
    local reply
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

install_ubuntu_ppas() {
    local ppa_file="$pkg_dir/ubuntu-ppa.txt" line ppa what
    [[ -r "$ppa_file" ]] || return 0
    echo "This config needs packages from third-party PPAs:"
    while IFS= read -r line; do
        ppa="${line%%|*}";  ppa="${ppa//[[:space:]]/}"
        what="${line#*|}"
        printf '  %-24s %s\n' "$ppa" "$what"
    done < <(read_list "$ppa_file")
    echo
    echo "A PPA is a third-party source of system packages. Skipping them means"
    echo "hyprland, hyprlock, waybar and alacritty stay at the (older) versions"
    echo "in the Ubuntu archive, or are unavailable."
    echo
    confirm "Add these PPAs?" || { echo "Skipped."; return 0; }

    while IFS= read -r line; do
        ppa="${line%%|*}"; ppa="${ppa//[[:space:]]/}"
        echo "==> add-apt-repository $ppa"
        sudo add-apt-repository -y "$ppa" || echo "  failed: $ppa"
    done < <(read_list "$ppa_file")
    sudo apt-get update
}

do_install() {
    [[ -n "$distro" ]] || { echo "Cannot install: unknown distro." >&2; return 1; }
    local -a pkgs
    mapfile -t pkgs < <(read_list "$pkg_dir/$distro.txt")
    (( ${#pkgs[@]} )) || { echo "packages/$distro.txt is empty." >&2; return 1; }

    case "$distro" in
        ubuntu)
            install_ubuntu_ppas
            echo "==> apt-get install (${#pkgs[@]} packages)"
            sudo apt-get install -y "${pkgs[@]}" ;;
        debian)
            echo "Note: Hyprland needs Debian trixie or sid; it is not in stable."
            echo "==> apt-get install (${#pkgs[@]} packages)"
            sudo apt-get install -y "${pkgs[@]}" ;;
        arch)
            echo "==> pacman -S --needed (${#pkgs[@]} packages)"
            sudo pacman -S --needed "${pkgs[@]}"
            if [[ -r "$pkg_dir/arch-aur.txt" ]]; then
                echo
                echo "Also needed from the AUR - install with your own helper,"
                echo "since an AUR helper builds and runs upstream PKGBUILDs:"
                read_list "$pkg_dir/arch-aur.txt" | sed 's/^/  /'
            fi ;;
    esac

    echo
    echo "==> linking configs (setup.py)"
    python3 "$repo_dir/setup.py"
}

# ------------------------------------------------------------------ main ----

case "$mode" in
    check)
        check_commands ;;
    verify-names)
        verify_names ;;
    install)
        do_install
        echo
        missing_commands=()
        check_commands
        echo
        echo "Anything still missing is in packages/manual.md - those have no"
        echo "distro package and must be installed by hand."
        ;;
esac
