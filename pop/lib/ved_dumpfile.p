

uses sysio;

define ved_dumpfile;

    if vedargument = '' then
        vederror('Specify a filename');
    endif;

    vars dev = fopen(vedargument,"r");

    vars c, k=0,text='';

    repeat

        getc(dev) -> c;
    quitif(c=termin);
        prnum(c,3,0); pr(' ');
        if c > 31 and c < 127 then
            text >< consstring(c,1) -> text;
        else
            text >< '.' -> text;
        endif;
        1+k->k;
        if k = 14 then
            0 -> k;
            pr(text);
            '' -> text;
            nl(1);
        endif;

    endrepeat;
    fclose(dev);
    nl(1);
enddefine;
