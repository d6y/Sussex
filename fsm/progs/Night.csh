#!/bin/csh

cd fsm

if (-e weights/278a-17.wts) then
    nohup nice bp networks/fsm.tem mscript3 >& 278c.out &
else
    at -c now + 2 hours ~/fsm/Night.csh
endif
