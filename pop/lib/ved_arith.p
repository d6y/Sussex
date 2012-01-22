uses sysio;
uses stringtolist;
vars ltt_center = true;

uses ved_qmr;   ;;; I can uqmr if I need to


define spew_line(dev,string,fproc,sproc,vproc);
    if dev = false then
        pr(string); sproc();
    elseif isword(dev) then
        vproc(dev,string);
    else
        fproc(dev,string);
    endif;
enddefine;

define va_var_line(v,string);
    popval([ ^v >< string >< '\n' -> ^v ; ]);
enddefine;

define va_var_insert(v,string);
    popval([ ^v >< string  -> ^v ; ]);
enddefine;

define insert_line(dev,string);
    spew_line(dev,string,finsertstring,identfn,va_var_insert);
enddefine;

define put_line(dev,string);
    spew_line(dev,string,fputstring,nl(%1%),va_var_line);
enddefine;

define list_to_tabular(task,list);
    vars dev = false, file, ncols, nros, c, r, item, lower_item, over_rule,
        more, leftmost=1000000, nrows, row, op_sign, do_close=true;

    if isstring(list) or isdevice(list) then
        if isdevice(list) then false -> do_close; endif;
        (task,list) -> (task,list,file);
        fopen(file,"w") -> dev;

    elseif isword(list) then
        (task,list) -> (task,list,dev);
    endif;

    if task = "+" then
        '$+$' -> op_sign;
    else
        '$\\times$' -> op_sign;
    endif;

    length(list) -> nrows;
    length(list(1)) -> ncols;

    '' -> line;
    repeat ncols times line >< 'p{1em}' -> line; endrepeat;

    put_line(dev,'\\begin{arithprob}{'><line><'}');

    for r from 1 by 2 to nrows do

        list(r) -> row;

        if member("=",row) = true then

            insert_line(dev,'\\cline{'><max(1,(leftmost-1))><'-'><ncols><'}');

        else
            ((r+1) <= nrows) -> more;

            if (r+2) <= nrows then
                member("=",list(r+2)) -> over_rule;
            else
                false -> over_rule;
            endif;

            for c from 1 to ncols do ;;; find leftmost column
                row(c) -> item;
                if isnumber(item) and item /= "-"  then
                    min(c,leftmost) -> leftmost;
                    quitloop;
                endif;
            endfor;



            for c from 1 to ncols do

                if more then
                    list(r+1)(c) -> lower_item;
                    if lower_item = "-" then  false -> lower_item; endif;
                    if over_rule and (c+1 = leftmost) then
                        ;;;if list(r)(c+1) = "-" then
                        ;;;insert_line(dev,'&');
                        ;;;c+1->c;
                        ;;;endif;
                        insert_line(dev,op_sign);
                        '$+$' -> op_sign;
                    endif;
                else
                    false -> lower_item;
                endif;

                row(c) -> item;

                if isnumber(item) and item /= "-" then
                    if isnumber(lower_item) then
                        insert_line(dev,'$'><item><'_{'><lower_item><'}$');
                    else
                        insert_line(dev,'$'><item><'_{\\ }$');
                    endif;
                else
                    if isnumber(lower_item) then
                        insert_line(dev,'$\\ _{'><lower_item><'}$');
                    else
                        insert_line(dev,'$\\ _{\\ }$');
                    endif;
                endif;

                if c /= ncols then
                    insert_line(dev,'&');
                else
                    insert_line(dev,'\\\\');
                endif;

            endfor;
            insert_line(dev,'\n');
        endif;
    endfor;

    put_line(dev,'\\end{arithprob}');

    if isdevice(dev) and do_close then
        fclose(dev);
    endif;
enddefine;

define ved_arith;

    lvars
        line,
        lines,
        start_range,
        end_range,
        l;

    vars tex_string = '';

    while (vedthisline() ->> line) = '' do
        vedcharup();
    endwhile;

    vedline -> end_range;

    [%  stringtolist(line); vedcharup();
        while (vedthisline() ->> line) /= '' do
            stringtolist(line);
            vedcharup();
        endwhile;
    %] -> lines;

    vedline -> start_range;

    if length(lines)/2 /= intof(length(lines)/2) then
        vederror('Line missing in problem');
    endif;

    rev(lines) -> lines;

    if vedargument = '' then 'x' -> vedargument; endif;

    list_to_tabular(consword(vedargument),lines,"tex_string");

    vedinsertstring(tex_string);

    vedline-start_range -> l;
    start_range + l -> start_range;
    end_range + l -> end_range;

    for l from start_range to end_range do
        vedjumpto(l,1);
        '% ' >< vedthisline() -> vedthisline();
    endfor;

    vedrefresh();
enddefine;

define test;
    list_to_tabular("x",[
            [- 1 1 1]
            [- - - -]
            [- - 1 1]
            [- - - -]
            [= = = =]
            [= = = =]
            [- - 1 1]
            [- - - -]
            [- - - 1]
            [- - - -]
            [= = = =]
            [= = = =]
            [- - 1 2]
            [- - - -]],'foo.tex');
enddefine;
/*
test();
*/
