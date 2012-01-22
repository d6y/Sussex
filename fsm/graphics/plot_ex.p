uses sysio;
vars dev,m,l,tss,e,pc,o,ne,ep;

100 -> ne;

fopen('weights/lrate.log',"r") -> dev;
fopen('lrate.dat',"w") -> o;

vars elr = [], tsl = [], best = [], best_tss = 10000;

[% for m in [0 0.1 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.6 0.7 0.8 0.9 1.0] do
for l in [0.001 0.01 0.05 0.1 0.2 0.25 0.3 0.35 0.4 0.5 0.6 0.7 0.8 0.9 1.0] do

        0 -> ep;
        while ep = 0 do
        stringtolist(fgetstring(dev)) --> [?ep ?tss ?pc];
        endwhile;

if m = 1 then l->ef; else
        l/(1.0-m) ->ef;
endif;

        if tss < 0.5 then ;;; change this line to scale
            fputstring(o,l><' '><m><' '><tss);
            ef :: elr -> elr;
            tss :: tsl -> tsl;
        endif;


        if tss < best_tss then ;;; /* and pc = 100*/ then
            tss  -> best_tss;
            [lr ^l mom ^m elr ^ef tss ^tss ep ^ep pc ^pc] -> best;
        endif;

    [^tss ^l ^m ^ef];

    endfor;


endfor; %] -> all;

fgetstring(dev)=>
fclose(o);
fclose(dev);

[Best parameters] =>
best =>


uses rcg;
uses rc_graphplot;
"cross" -> rcg_pt_type;
rc_graphplot(elr, 'Effective learning rate' ,tsl, 'TSS')->;
