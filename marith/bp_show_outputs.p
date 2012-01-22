
define bp_show_outputs(network,stims,stimnames);
vars e = 0, c;
    vars outputs nout npat p o;
    bp_response(stims,network) -> outputs;
    pdpdata_data(outputs) -> outputs;
    boundslist(outputs) --> [1 ?nout 1 ?npat];
    fast_for p from 1 to npat do
        if islist(stimnames) then
            pr(stimnames(p)); pr(' ');
        else pr_field(''><p,4,' ',false);
        endif;
        fast_for o from 1 to nout do
            prnum(outputs(o,p),2,3); pr(' ');
        endfast_for;
        false -> c;
        if nout = 1 then
            if outputs(1,p) > 0.5 then pr(' *');
            true -> c;
            endif;
                vars a = strnumber(substring(1,1,stimnames(p))),
                    b = strnumber(substring(3,1,stimnames(p)));
            if f(a,b)= 1 then pr('*');
                if c = false then e+1->e; endif;
            else pr('x');if c=true then e+1->e; endif; endif;

        endif;
        nl(1);
    endfast_for;
[error count = ^e] =>
enddefine;
