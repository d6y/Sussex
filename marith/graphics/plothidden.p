uses rcg_unitplot;

define plothidden(clxfile,pats,width);

    pdp3_adddot(clxfile,'.clx') -> clxfile;

    vars npats = pats.pdp3_npats;

    vars i,line,a,b, dev = fopen(clxfile,"r");
   ;;; fgetstring(dev) -> i;

    vars h = [% for i from 1 to npats do
            stringtolist(fgetstring(dev));
    endfor; %];
    fclose(dev);

rcg_unitplot(h,pats.pdp3_stimnames,width);

vars x1,x2,y1,y2;
region --> [?x1 ?x2 ?y1 ?y2];
rc_print_at(x1,y2,clxfile);
width -> rcg_pt_cs;
rcg_plt_square(x2-0.5,y2-1);
rc_print_at(x2-0.3,y2-1.4,'=1.0');

enddefine;
