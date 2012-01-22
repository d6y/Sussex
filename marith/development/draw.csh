#!/bin/csh
xgraph -x "Performance %" -y "Error %" -t "$*" -bb -tk ode.plt oe.plt omit.plt err.plt
