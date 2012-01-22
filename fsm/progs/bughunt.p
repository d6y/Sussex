load ~/pop/init.p
load ~/pop/pdp3/pdp3.p

15000000 -> popmemlim;

extend_searchlist('~richardd/fsm/lib',popliblist) -> popliblist;
extend_searchlist('~richardd/fsm/lib',popuseslist) -> popuseslist;
extend_searchlist('~richardd/fsm/progs',popliblist) -> popliblist;
extend_searchlist('~richardd/fsm/progs',popuseslist) -> popuseslist;

uses maths_routines;
uses operations;
uses code_input;
uses symmap;
uses perform_action;
uses bugfind.p;

vars Problems = [
[x 12 5] [x 12 9] [x 1 11] [x 11 11] [x 1 111] [x 12 15]
[x 12 19] [x 12 50] [x 12 55] [x 12 59] [x 12 90] [x 12 95]
[x 12 99] [x 111 11] ];

[[+ 1 1]
[+ 1 1 1]
[+ 11 11]
[+ 11 1]
[+ 1 9]
[+ 1 19]
[+ 100 100]
[+ 101 109]
[+ 101 99]
[+ 101 899]
[x 1 1]
[x 2 5]
[x 11 1]
[x 111 1]
[x 12 5]
[x 12 9]
[x 1 11]
[x 11 11]
[x 1 111]
[x 12 15]
[x 12 19]
[x 12 50]
[x 12 55]
[x 12 59]
[x 12 90]
[x 12 95]
[x 12 99]
[x 111 11]
[x 111 111]] -> Problems;


vars net, i, problem_set;

[CHECKING 303a FILES] ==>
sysdaytime()=>

for i from 1 to 27 do
nl(2);
[303a - ^i -----------------------------------------------------------] ==>
    pdp3_getweights('~/fsm/networks/fsm35', '~/fsm/weights/303a-'><i) -> net;
    [% Problems(i+1); %] -> problem_set;
    bugfind(net,problem_set,0.0);
endfor;

sysdaytime()=>
