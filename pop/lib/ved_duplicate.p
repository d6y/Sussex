uses stringtolist;


define vdup_leadzeros(n,m) -> s;
    n><'' -> s;
    while length(s) < m do
        '0'><s -> s;
    endwhile;
enddefine;

define find_dollars;
    vars p,ip,s,string;
    [%     for p from vvedmarklo to vvedmarkhi do
            subscrv(p,vedbuffer) -> string;
            if string = '' then
                [];
            else
                1 -> s;
                [% repeat
                        issubstring('$',s,string) -> ip;
                        if ip = false then
                            substring(s,1+length(string)-s,string);
                            quitloop();
                        endif;
                        substring(s,ip-s,string);
                        0;
                        ip+1 -> s;
                    endrepeat; %];
            endif;
        endfor; %];
enddefine;

define insert_duplicate(v,dollars);
    vars p,i,line;

    for p in dollars do
        for i in p do
            if i = 0 then
                vedinsertstring(''><v);
            else
                vedinsertstring(i);
            endif;
        endfor;
        vedinsertstring('\n');
    endfor;

enddefine;

define ved_duplicate;
    vars start,finish,hop,dupstep,dollars;

    if vedargument = '' then
        vederror('NO DUPLICATION VARIABLE');
    endif;

    ;;; read marked range, looking for $ signs
    vedpositionpush();
    find_dollars()->dollars;

    ;;; insert
    stringtolist(vedargument) -> dupstep;

    if dupstep matches [?start to ?finish] then
        for v from start to finish do
            insert_duplicate(v,dollars);
        endfor;
    elseif dupstep matches [?start by ?hop to ?finish] do
        for v from start by hop to finish do
            insert_duplicate(v,dollars);
       endfor;
    elseif dupstep matches [?hop zeros ?start to ?finish] then
        for v from start to finish do
            insert_duplicate(vdup_leadzeros(v,hop),dollars);
        endfor;
    else
        for v in dupstep do
            insert_duplicate(v,dollars);
        endfor;
    endif;

    vedpositionpop();
    ;;; vedrefresh();

enddefine;
