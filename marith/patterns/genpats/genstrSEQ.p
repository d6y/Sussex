
load instabp.p

define genSEQ;
    vars base t s dev n;

    for base in ['for'] do

;;;        for s in [cl emcl emrp clrp emclrp rp] do
        for s in [rp emrp] do

            fopen(base><s><'SEQ.str',"w") -> dev;

            fast_for n from 1 to 8 do
                fputstring(dev,'get pat '><base><s><n><'.pat');
                fputstring(dev,'ptrain');
            endfor;
            fclose(dev);

            for n in [5 6 7 8 9 10 15 20] do

                fopen(base><s><n><'.str',"w") -> dev;

                fputstring(dev,'do arith'><n><'.str 1');

                for t from 1 to 5 do
                    fputstring(dev,'do '><base><s><'SEQ.str 1');
                    fputstring(dev,'save w '><base><s><n><'-'><t><'.wts');
                    fputstring(dev,'newstart');
                endfor;

                fputstring(dev,'q');
                fputstring(dev,'y');

                fclose(dev);

            endfor;

        endfor;
    endfor;
enddefine;

define genNETandTEM;
    vars n;
    for n in [5 8 10 15 20] do
        instabp(16,n,31,'arith'><n);

        fopen('arith'><n><'.str',"w") -> dev;

        fputstring(dev,'get network arith'><n><'.net');
        fputstring(dev,'set lflag 1');
        fputstring(dev,'set mode lgrain epoch');
        fputstring(dev,'set dlevel 1');
        fputstring(dev,'set slevel 3');
        fputstring(dev,'set param momentum 0.9');
        fputstring(dev,'set param lrate 0.01');
        fputstring(dev,'set nepochs 2000');
        fputstring(dev,'set ecrit 3.0');

        fclose(dev);

    endfor;

enddefine;

genNETandTEM();

genSEQ();
