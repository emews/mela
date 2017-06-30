#! /usr/bin/env bash

CMAES_ROOT=$( cd $( dirname $0 )/.. ; /bin/pwd )
export PYTHONPATH=$CMAES_ROOT
python $CMAES_ROOT/test/test.py
