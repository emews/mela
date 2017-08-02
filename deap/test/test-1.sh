#!/bin/zsh -f
set -eu

# TEST 1

THIS=$( dirname $0 )
MELA=$( cd $THIS/../.. ; /bin/pwd )

source $MELA/test-util/util.sh

cd $MELA/deap

LOG=$( mktemp )

# The final X,Y coordinates sampled by DEAP
XY=$( mktemp )

echo LOG=$LOG

swift/run --settings=swift/settings.json > $LOG

# Pull out final TASK messages with function call parameters
grep "TASK:" $LOG | tail -5 | cut -d ' ' -f 2,3 > $XY

# Math functions for average, range checking
source $MELA/test-util/math.sh

# Average the function call parameters
X=$( cut -d ' ' -f 1 $XY | avg )
Y=$( cut -d ' ' -f 2 $XY | avg )

# (X,Y) should be close to (1.1,1.1) on average
within 0.1 1.1 $X || abort "deap: X not in range!"
within 0.001 1.1 $Y || abort "deap: Y not in range!"

rm $LOG $XY

echo "SUCCESS"
