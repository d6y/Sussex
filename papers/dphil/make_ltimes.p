uses sysio

vars f = ffile('~/fsm/output/303a.xy');

vars p=0,c=1,x,y,z = [%
    foreach [?x ?y] in f do
        [% c; (y-p); %];
        c+1->c;
        y -> p;
    endforeach;
%];

z -> ffile('~/fsm/output/303a.gr');

sysobey('xgraph -t \"Training times\" -bar -nl -brw 1 -x \"Problem set\" '
    >< ' -y \"I/O pairs\" < /csuna/home/richardd/fsm/output/303a.gr &');
