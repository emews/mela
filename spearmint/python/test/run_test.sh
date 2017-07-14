#! /usr/bin/env bash
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 )/../.. ; /bin/pwd )
export PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$EMEWS_PROJECT_ROOT/ext/EQ-Py
python $EMEWS_PROJECT_ROOT/python/test/test.py
