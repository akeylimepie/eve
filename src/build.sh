#!/usr/bin/env bash

shebang="#!/usr/bin/env bash"

eveScript=./eve.sh
printScript=./print.sh
setupScript=../build/setup.sh

echo "$shebang" >$setupScript

cat $printScript >>$setupScript
cat $eveScript >>$setupScript
cat ./tune/ssh.sh >>$setupScript
cat ./tune/user.sh >>$setupScript
cat ./setup.sh >>$setupScript
