vars cumulative = true;

uses sysio;

vars t = [
    [start 12 57]
    [1 12 58]
    [2 12 58]
    [3 13 02]
    [4 13 02]
    [5 13 08]
    [6 13 14]
    [7 13 19]
    [8 13 24]
    [9 13 45]
    [10 14 01]
    [start 14 36]
    [11 15 51]
    [12 16 13]
];

[
[start 22 06]
[1 22 07]
[2 22 12]
[3 22 18]
[4 22 29]
[5 22 33]
[6 23 23]
[7 23 37]
[8 24 00]
[9 24 30]
[10 24 51]
[11 24 51]
[12 27 22]
[13 27 22]
[14 27 22]
] -> t;

/*
sysobey('xgraph time.xy &');
*/

vars x,h,m,sm, mins;


vars dev = fopen('time.xy',"w");

fputstring(dev,'\"Learning time (mins) 25 hidden\"');

foreach [?x ?h ?m] in t do

    if x = "start" then
        (h*60)+m -> sm;
    else
        (h*60.0)+m -> mins;
        finsertstring(dev,x><' ');
        finsertstring(dev,mins-sm);
        fnewline(dev);
        if cumulative = false then
            mins -> sm;
        endif;
    endif;
endforeach;

fclose(dev);
