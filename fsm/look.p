load progs/bugfind.p

vars net, plist;
pdp3_getweights('~/fsm/networks/fsm35','~/fsm/weights/303a-13') -> net;

pdp3_getpatterns('~/fsm/patterns/mult13.pat',237,net) -> pat;

pat-> pdp3_performance(net, 0.2) ->
    (tss, percentage, errorlist, psslist);

percentage =>
pdp3_patternnumber(errorlist(1),pat) =>

0.9 -> pdp3_tmax(net);




vars plist = [ [+ 1 1] [+ 1 1 1] [+ 11 11] [+ 11 1] [+ 1 9] [+ 1 19]
[+ 100 100] [+ 101 109] [+ 101 99] [+ 101 899] [x 1 1] [x 2 5] [x 11 1]
];

[x 111  1] [x 12 5] [x 12 9] [x 1  11] [x 11 11] [x 1 111]  [x 12 15]
[x 12 19] [x  12 50] [x 12 55] [x  12 59] [x 12 90]  [x 12 95] [x 12 99]
[x 111 11] [x  111 111] ];


bugfind(net,plist,0.25);
