OS=$(uname)
USER_ID=$(id -u)

function isLinux() {
  if [ "$OS" != 'Linux' ]; then
    printError "It's only for Linux, sorry"
    exit 1
  fi
}

function binExists() {
  if command -v "$1" &>/dev/null; then
    echo 1
  else
    echo 0
  fi
}
