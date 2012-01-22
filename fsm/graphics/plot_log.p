uses rcg;
uses sysio;

define rcg_plot_pdp3_log(titlex,titley,logfile,v1);
    lvars dev,v1,v2,logfile,line,titlex,titley,counter=0,previous_line,xydata;

    false->v2;

    if not(isstring(logfile)) then
        (titlex,titley,logfile,v1) -> (titlex,titley,logfile,v1,v2);
    endif;

    fopen(logfile,"r") -> dev;

    [% repeat

            fgetstring(dev) -> line;
        quitif(line=termin);
            stringtolist(line) -> line;

            unless line = previous_line and line(1) /= 0 then

                if v2 = false then
                    counter;
                    counter + 1 -> counter;
                elseif islist(v2) then
                    hd(v2);
                    tl(v2) -> v2;
                else
                    line(v2);
                endif;

                line(v1);

                line -> previous_line;
            endunless;

        endrepeat; %] -> xydata;
    fclose(dev);

    rc_graphplot2(xydata,titlex,titley) ->;
    rc_print_here(sys_fname_nam(logfile));

enddefine;

;;;rcg_plot_pdp3_log('Pattern','Epochs','~/fsm/output/281.log',1);

newgraph();
[0 1000 0 50000] -> rcg_usr_reg;

rcg_plot_pdp3_log('Patterns','Epochs','~/fsm/output/285c.log',1,
[9 20 38 55 67 86 113 142 172 206 213 223 237 258 274 293 326 382 438
496 558 616 676 740 809 882 957 1036 1156]);

samegraph();

rcg_plot_pdp3_log('Patterns','Epochs','~/fsm/output/281.log',1,
[9 20 38 55 67 86 113 142 172 206 213 223 237 258 274 293 326 382 438
496 558 616 676 740 809 882 957 1036 1156]);

rcg_plot_pdp3_log('Patterns','Epochs','~/fsm/output/285a.log',1,
[9 20 38 55 67 86 113 142 172 206 213 223 237 258 274 293 326 382 438
496 558 616 676 740 809 882 957 1036 1156]);

rcg_plot_pdp3_log('Patterns','Epochs','~/fsm/output/285b.log',1,
[9 20 38 55 67 86 113 142 172 206 213 223 237 258 274 293 326 382 438
496 558 616 676 740 809 882 957 1036 1156]);

rcg_plot_pdp3_log('Patterns','Epochs','~/fsm/output/282.log',1,
[9 20 38 55 67 86 113 142 172 206 213 223 237 258 274 293 326 382 438
496 558 616 676 740 809 882 957 1036 1156]);

newgraph();
