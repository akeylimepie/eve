OS=$(uname)
USER_ID=$(id -u)

function isLinux() {
  if [ "$OS" != 'Linux' ]; then
    printError "It's only for Linux, sorry"
    exit 1
  fi
}
