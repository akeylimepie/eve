function printLogo() {
  for i in $(seq 87 -1 82); do printf "\e[48;5;%sm \e[0m" "$i"; done
  printf "\e[38;5;8;48;5;82m eva \e[0m"
  for i in $(seq 82 87); do printf "\e[48;5;%sm \e[0m" "$i"; done
  echo
}

function printProcess() {
  printf "%s ∴" "$1"
}

function printProcessSuccess() {
  printf "\b\e[38;5;2m✔\e[0m\n"
}

function printProcessFail() {
  printf "\b\e[38;5;1m✘︎\e[0m\n"
}

function printSuccess() {
  printf "\e[38;5;2m%s\e[0m\n" "$1"
}

function printWarning() {
  printf "\e[38;5;3m%s\e[0m\n" "$1"
}

function printError() {
  printf "\e[38;5;1m%s\e[0m\n" "$1"
}
