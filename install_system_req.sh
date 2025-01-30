#!/usr/bin/env bash

# POSIX-compliant sanity check
if [ -z "$BASH" ] || [ "$BASH" = "/bin/sh" ]; then
    echo "Please use the bash interpreter to run this script"
    exit 1
fi

error() {
    printf '\E[31m'; echo "$@"; printf '\E[0m'  # Print in red
}

output() {
    printf '\E[36m'; echo "$@"; printf '\E[0m'  # Print in cyan
}

### START

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BREW_FILE="$DIR/brew-formulas.txt"
APT_PKGS_FILE="$DIR/apt-packages.txt"

case "$(uname -s)" in
    [Ll]inux)
        if ! command -v lsb_release &>/dev/null; then
            error "Please install lsb-release."
            exit 1
        fi

        output "Installing Ubuntu requirements"
        export DEBIAN_FRONTEND=noninteractive

        if [[ -r "$APT_PKGS_FILE" ]]; then
            cat "$APT_PKGS_FILE" | xargs sudo apt-get -y install
        else
            error "APT package list file not found: $APT_PKGS_FILE"
            exit 1
        fi
        ;;
    Darwin)
        if [[ ! -w /usr/local ]]; then
            cat <<EO

You need to be able to write to /usr/local for
the installation of brew and brew packages.

Either ensure the group you are in (most likely 'staff')
can write to that directory or execute:

    sudo chown -R \$USER /usr/local

EO
            exit 1
        fi

        output "Installing macOS requirements"
        if [[ ! -r "$BREW_FILE" ]]; then
            error "$BREW_FILE does not exist, needed to install brew packages."
            exit 1
        fi

        for pkg in $(cat "$BREW_FILE"); do
            if ! brew list | grep -q "$pkg"; then
                output "Installing $pkg"
                brew install "$pkg"
            fi
        done

        PATH="/usr/local/share/python:/usr/local/bin:$PATH"

        if ! command -v pip &>/dev/null; then
            output "Installing pip"
            easy_install pip
        fi

        if ! virtualenv --version 2>/dev/null | grep -Eq '^1\.7'; then
            output "Installing virtualenv >1.7"
            pip install 'virtualenv>1.7' virtualenvwrapper
        fi

        if ! command -v coffee &>/dev/null; then
            output "Installing CoffeeScript"
            curl --insecure https://npmjs.org/install.sh | sh
            npm install -g coffee-script
        fi
        ;;
    *)
        error "Unsupported platform"
        exit 1
        ;;
esac
