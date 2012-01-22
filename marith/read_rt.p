
define flatten(d);
    vars i;
    [% for i in d do
            last(i);
        endfor;%];
enddefine;

define raw_read_rt(net) -> (tables, data);

    vars p,file,tables;

    if isstring(net) then ;;; it's a filename
        net -> file
    else ;;; assume it's a pdp3_network_record
        net.pdp3_wtsfile -> file;
    endif;

    issubstring('.',file) -> p;
    if p = false then
        file >< '.rt' -> file;
    endif;

    vars dev = fopen(file,"r");

    if dev == false then
        mishap('READ_RT: Could not open file',[^file]);
    endif;

    vars data = [% ;;; ASSUME NO ZERO MEASURE IN RT FILE
;;;repeat 64 times fgetstring(dev)->doo; endrepeat;

    repeat N_problems-1 times
            stringtolist(fgetstring(dev));
    endrepeat; %];

    fclose(dev);

    vars a,b,p=1;

    [%
        fast_for a from First_multiplier to Last_multiplier do
            [% fast_for b from First_multiplier to Last_multiplier do
                if length(data(p))>1 then
                    data(p)(2);
                else
                    data(p)(1);
                endif;
                p+1->p;
            endfast_for; %];
    endfast_for;
    %] -> tables;


enddefine;


define read_rt(net) -> tables;
    vars tables, data;
    raw_read_rt(net) -> (tables, data);
enddefine;

define read_collapsed(file);
    vars dev = fopen(file,"r");
    [% repeat 36 times strnumber(fgetstring(dev)); endrepeat; %];
    fclose(dev);
enddefine;
