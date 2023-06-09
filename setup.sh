#!/usr/bin/env bash
# Packages setup for Sublime Text 4 on MacOSX
# Go to System > Preferences > Security & Privacy > Full Disk Access > [X] Terminal
# Usage: bash setup.sh

APPLICATION="Sublime Text";
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="${HOME}/Library/Application Support/Sublime Text"
PACKAGED_DIR="${ROOT_DIR}/Installed Packages"
LOCAL_DIR="${ROOT_DIR}/Local"
PACKAGES_DIR="${ROOT_DIR}/Packages"
USER_DIR="${PACKAGES_DIR}/User"
ASSETS_DIR="${USER_DIR}/formatter.assets"
CFG_REPO="https://github.com/mi-sublime/dot"
CFG_DIR="${CFG_REPO##*/}-master"

# Pretty print
print () {
    if [ "$2" == "error" ] ; then
        COLOR="7;91m" # light red
    elif [ "$2" == "success" ] ; then
        COLOR="7;92m" # light green
    elif [ "$2" == "warning" ] ; then
        COLOR="7;33m" # yellow
    elif [ "$2" == "info" ] ; then
        COLOR="7;96m" # light cyan
    else
        COLOR="0m" # colorless
    fi

    START="\\e[$COLOR"
    END="\\e[0m"
    TYPE="$(tr '[:lower:]' '[:upper:]' <<< ${2:0:1})${2:1}" # capitalizing word

    printf "$START[$TYPE] %b$END" "$1\\n"
}

# Check system
OS=$(uname -s)
if [ "${OS}" != "Darwin" ]; then
    print "${OS} is not supported.\\nExit." "error" >&2
    exit 1
fi

# Logout sudo
print "Logout sudo" "success"
sudo -k

# Check dependencies
declare -a bin=(
    "node"
    "npm"
    "php"
    "git"
    "python3"
    "ruby"
)

for i in "${bin[@]}"; do
    if ! [ -x "$(command -v ${i})" ]; then
        case "${i}" in
            node | npm)
                print "Please download ${i} from https://nodejs.org and install it." "info"
                ;;
            php)
                print "Please install ${i}:\\n\$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\\n\$ brew install php\\n\$ brew link php\\n\$ echo 'export PATH=\"/usr/local/opt/php/bin:\$PATH\"' >> ~/.zshrc" "info"
                ;;
            python3)
                print "Please install ${i}:\\n\$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\\n\$ brew install python3\\n\$ brew link python3\\n\$ echo 'export PATH=\"/usr/local/opt/python3/bin:\$PATH\"' >> ~/.zshrc" "info"
                ;;
            ruby)
                print "Please install ${i}:\\n\$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\\n\$ brew install ruby\\n\$ brew link ruby\\n\$ echo 'export PATH=\"/usr/local/opt/ruby/bin:\$PATH\"' >> ~/.zshrc" "info"
                ;;
            *)
                ;;
        esac
        print "${i} does not exist in this system.\\nExit." "error" >&2
        exit 1
    fi
done

# Check PHP requirements
function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
curphp="$(php -v | sed -n '/PHP/s/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/p')"
minphp=7.4.0 # Formatter (PHP-CS-Fixer)
if ! version_gt "$curphp" "$minphp"; then
    print "Please install the lastest PHP:\\n\$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\\n\$ brew install php\\n\$ brew link php\\n\$ echo 'export PATH=\"/usr/local/opt/php/bin:\$PATH\"' >> ~/.zshrc" "info"
    print "The installed PHP ($curphp) version is lower than the minimum required version of $minphp\\nExit." "error" >&2
    exit 1
fi

# Check python3 requirements
curpython3="$(python3 -V | sed -n '/Python/s/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/p')"
minpython3=3.10.0 # Formatter (All)
if ! version_gt "$curpython3" "$minpython3"; then
    print "Please install the lastest python3:\\n\$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\\n\$ brew install python3\\n\$ brew link python3\\n\$ echo 'export PATH=\"/usr/local/opt/python3/bin:\$PATH\"' >> ~/.zshrc" "info"
    print "The installed python3 ($curpython3) version is lower than the minimum required version of $minpython3\\nExit." "error" >&2
    exit 1
fi

# Check ruby requirements
curruby="$(ruby -v | sed -n '/ruby/s/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/p')"
minruby=3.2.0 # Formatter (RuboCop)
if ! version_gt "$curruby" "$minruby"; then
    print "Please install the lastest ruby:\\n\$ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\\n\$ brew install ruby\\n\$ brew link ruby\\n\$ echo 'export PATH=\"/usr/local/opt/ruby/bin:\$PATH\"' >> ~/.zshrc" "info"
    print "The installed ruby ($curruby) version is lower than the minimum required version of $minruby\\nExit." "error" >&2
    exit 1
fi

# Update pip3
sudo -H pip3 install --upgrade pip

# Update all npm global packages
print "Updating npm global packages" "info"
sudo npm update -g

# Accept Xcode license
if [ "$(command -v xcodebuild)" ]; then
    print "Accept Xcode license" "info"
    sudo xcodebuild -license accept
fi

# Create default folders
if open -Ra "${APPLICATION}"; then
    print "Creating ${APPLICATION} default folders" "success"
    open -a "${APPLICATION}"
    path=$(mdfind -name "kMDItemFSName=='${APPLICATION}.app'")
    "${path}"/Contents/SharedSupport/bin/subl --command exit
else
    print "${APPLICATION} does not exist.\\nExit." "error" >&2
    exit 1
fi

# Install binaries
mkdir -p "${ASSETS_DIR}/bin"

print "Installing php-cs-fixer" "info" # Formatter
# curl -Lk "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/download/v3.17.0/php-cs-fixer.phar" --create-dirs -o "${ASSETS_DIR}/bin/php-cs-fixer.phar"
mv ./bin/php-cs-fixer.phar "${ASSETS_DIR}/bin/php-cs-fixer.phar"
sudo chmod a+x "${ASSETS_DIR}/bin/php-cs-fixer.phar"

print "Installing clang-format" "info" # Formatter
# curl -Lk "https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz" -o "clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz"
# tar -xzvf clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz
# mv ./clang+llvm-15.0.7-x86_64-apple-darwin21.0/bin/clang-format "${ASSETS_DIR}/bin/clang-format"
# rm -rf clang+llvm-15.0.7-x86_64-apple-darwin21.0 && rm clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz
mv ./bin/clang-format "${ASSETS_DIR}/bin/clang-format"
sudo chmod a+x "${ASSETS_DIR}/bin/clang-format"

print "Installing uncrustify" "info" # Formatter
# curl -Lk "https://github.com/uncrustify/uncrustify/archive/refs/heads/master.zip" -o "uncrustify-master.zip"
# tar -xzvf uncrustify-master.zip
# cd uncrustify-master
# mkdir build
# cd build
# /Applications/CMake.app/Contents/bin/cmake -DCMAKE_BUILD_TYPE=Release ..
# make
# mv ./uncrustify "${ASSETS_DIR}/bin/uncrustify"
# cd ..
# cd ..
# rm -rf uncrustify-master && rm uncrustify-master.zip
mv ./bin/uncrustify "${ASSETS_DIR}/bin/uncrustify"
sudo chmod a+x "${ASSETS_DIR}/bin/uncrustify"

print "Installing perltidy" "info" # Formatter
# curl -Lk "https://github.com/perltidy/perltidy/archive/refs/heads/master.zip" -o "perltidy-master.zip"
# tar -xzvf perltidy-master.zip
# cd perltidy-master
# perl pm2pl
# mv perltidy-20230309.02.pl "${ASSETS_DIR}/bin/perltidy"
# cd "${SCRIPT_DIR}"
# rm -rf perltidy-master && rm perltidy-master.zip
mv ./bin/perltidy "${ASSETS_DIR}/bin/perltidy"
sudo chmod a+x "${ASSETS_DIR}/bin/perltidy"

print "Installing shellcheck" "info" # SublimeLinter-shellcheck
# curl -Lk "https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.darwin.x86_64.tar.xz" -o "shellcheck-v0.9.0.darwin.x86_64.tar.xz"
# tar -xzvf shellcheck-v0.9.0.darwin.x86_64.tar.xz
# mv ./shellcheck-v0.9.0/shellcheck "${ASSETS_DIR}/bin/shellcheck"
# rm -rf shellcheck-v0.9.0 && rm shellcheck-v0.9.0.darwin.x86_64.tar.xz
mv ./bin/shellcheck "${ASSETS_DIR}/bin/shellcheck"
sudo chmod a+x "${ASSETS_DIR}/bin/shellcheck"

print "Installing html-tidy" "info" # SublimeLinter-html-tidy + Formatter
# curl -Lk "https://github.com/htacg/tidy-html5/releases/download/5.8.0/tidy-5.8.0-macos-x86_64+arm64.pkg" -o "tidy-5.8.0-macos-x86_64+arm64.pkg"
# mkdir tmp
# mv tidy-5.8.0-macos-x86_64+arm64.pkg tmp
# cd tmp
# xar -xf tidy-5.8.0-macos-x86_64+arm64.pkg
# cd HTML_Tidy.pkg
# tar -xzvf Payload
# mv ./usr/local/bin/tidy "${ASSETS_DIR}/bin/tidy"
# cd ..
# cd ..
# rm -rf tmp
mv ./bin/tidy "${ASSETS_DIR}/bin/tidy"
sudo chmod a+x "${ASSETS_DIR}/bin/tidy"

# Install plugins
declare -a python=(
    "CodeIntel" # SublimeCodeIntel
    "pylint" # SublimeLinter-pylint
    "beautysh" # Formatter
    "black" # Formatter
    "python-minifier" # Formatter
    "yapf" # Formatter
)

declare -a ruby=(
    "rubocop" # Formatter
)

declare -a javascript=(
    "eslint" # SublimeLinter-eslint + Formatter
    "prettier" # SublimeLinter-eslint + SublimeLinter-stylelint + Formatter
    "stylelint" # SublimeLinter-stylelint + Formatter
    "csscomb" # Formatter
    "js-beautify" # Formatter
    "cleancss" # Formatter (clean-css-cli)
    "html-minifier" # Formatter
    "terser" # Formatter
    "prettydiff" # Formatter
    "sql-formatter" # Formatter
)


for i in "${python[@]}"; do
    print "Installing ${i}" "info"
    pip3 install --upgrade --pre --no-warn-script-location --prefix="${ASSETS_DIR}/python" "${i}"
done

for i in "${ruby[@]}"; do
    print "Installing ${i}" "info"
    gem install --install-dir "${ASSETS_DIR}/ruby" "${i}"
done

for i in "${javascript[@]}"; do
    print "Installing ${i}" "info"
    case "${i}" in
        "eslint")
            sudo npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "${i}" eslint-config-prettier eslint-config-airbnb-base eslint-plugin-prettier
            ;;
        "stylelint")
            sudo npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "${i}" stylelint-config-standard stylelint-config-recommended stylelint-prettier mi-stx/stylelint-group-selectors#master mi-stx/stylelint-no-indistinguishable-colors#master mi-stx/stylelint-a11y#master
            ;;
        "csscomb")
            sudo npm install --save-dev --prefix="${ASSETS_DIR}/javascript" mi-stx/csscomb.js#master
            ;;
        "cleancss")
            sudo npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "clean-css-cli"
            ;;
        "html-minifier")
            sudo npm install --save-dev --prefix="${ASSETS_DIR}/javascript" mi-stx/html-minifier
            ;;
        *)
            sudo npm install --save-dev --prefix="${ASSETS_DIR}/javascript" "${i}"
            ;;
    esac
done

# Clone config branch
print "Cloning config master branch" "info"
git clone "${CFG_REPO}.git" --branch "master" --single-branch "${CFG_DIR}"

# Install assets
print "Installing config files" "info"
cp -R "${CFG_DIR}/Packages/User" "${PACKAGES_DIR}"

# Update PYTHONPATH
py=$(ls "${ASSETS_DIR}/python/lib")
print "Update PYTHONPATH to ${py} in Formatter.sublime-settings" "info"
sed -i '' "s/___PYTHON___/$py/" "${USER_DIR}/Formatter.sublime-settings"

# Show hidden files for 'mv'
shopt -s dotglob

# Install lic files
for i in "${CFG_DIR}/Local/"*; do
    print "Installing ${i##*/}" "info"
    mv "${i}" "${LOCAL_DIR}"
done

# Install .sublime-package files
print "Installing Package Control.sublime-package" "info"
curl -Lk "https://packagecontrol.io/Package%20Control.sublime-package" --create-dirs -o "${PACKAGED_DIR}/Package Control.sublime-package"
print "Installing Sublimerge 3.sublime-package" "info"
curl -Lk "https://www.sublimerge.com/packages/ST3/latest/Sublimerge%203.sublime-package" --create-dirs -o "${PACKAGED_DIR}/Sublimerge 3.sublime-package"

# Remove config dir
print "Deleting ${CFG_DIR}" "info"
rm -rf "${CFG_DIR}"

print "${APPLICATION} needs a restart to finish installation.\\nDone." "success"
exit 1
