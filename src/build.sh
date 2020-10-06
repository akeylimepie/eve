#!/usr/bin/env bash

shebang="#!/usr/bin/env bash"

evaScript=./eva.sh
printScript=./print.sh
setupScript=../build/setup.sh

echo "$shebang" >$setupScript

cat $printScript >>$setupScript
cat $evaScript >>$setupScript
cat ./tune/ssh.sh >>$setupScript
cat ./tune/user.sh >>$setupScript
cat ./setup.sh >>$setupScript
