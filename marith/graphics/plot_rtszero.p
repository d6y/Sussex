;;; Plot Mean RT for a number of nets

define plot_rts_zero(list_of_files,outfile) -> (DATA,Means);
    vars do_sd = true;

    if list_of_files = false then
        false -> do_sd;
            -> list_of_files;
    endif;

    vars a,b,tabledata,table,file,Means,Stderr,rcg_pt_type,DATA=[],
        y, Stderr_ties, Ties, N = sqrt(length(list_of_files)),
        table_mean;


    newarray([0 9],procedure(a); []; endprocedure) -> Means;
    newarray([0 9],0) -> Stderr;
    newarray([0 9],procedure(a); []; endprocedure) -> Ties;
    newarray([0 9],0) -> Stderr_ties;
    newarray([0 9 0 9]) -> tabledata;

    newarray([0 9 0 9], procedure(x,y); []; endprocedure) -> table_mean;

    for file in list_of_files do

        pdp3_adddot(file,'rt') -> file;
        fopen(file,"r") -> dev;

        fast_for a from 0 to 9 do
            fast_for b from 0 to 9 do
                stringtolist(fgetstring(dev)) --> [== ?t];
                t -> tabledata(a,b);
                t :: table_mean(a,b) -> table_mean(a,b);
            endfast_for;
        endfast_for;
        fclose(dev);

fast_for a from 0 to 9 do
     [% fast_for b from 0 to 9 do
        unless a == b then
            tabledata(a,b); tabledata(b,a);
        else
            tabledata(a,a);
            tabledata(a,a) :: Ties(a) -> Ties(a);
        endunless;
    endfast_for; %] -> table;

    table <>  DATA -> DATA;
    mean(table) :: Means(a) -> Means(a);
endfast_for;
endfor;


fast_for a from 0 to 9 do

    if do_sd then SD(Means(a))/N -> Stderr(a); endif;
    mean(Means(a)) -> Means(a);
    if do_sd then SD(Ties(a))/N -> Stderr_ties(a); endif;
    mean(Ties(a)) -> Ties(a);
endfast_for;

vars n1 =3, n2 =3;

pr('Files: '><(list_of_files(1))><' -> '><length(list_of_files)); nl(1);
pr('      |--All Probs--|-----Ties-------|\n');
pr('Table Mean RT StdErr   Mean RT StdErr\n');

for a from 0 to 9 do
    pr('  '><(a)><'  ');
    prnum(Means(a),n1,n2); pr(' ');
    prnum(Stderr(a),n1,n2); pr('    ');
    prnum(Ties(a),n1,n2); pr(' ');
    prnum(Stderr_ties(a),n1,n2); pr('\n');
endfor; nl(2);

"line" -> rcg_pt_type;
rc_graphplot({0 1 2 3 4 5 6 7 8 9},'',Means,'RT') -> region;

region --> [= = = ?y];
rc_print_at(1.5,y,list_of_files(1)><'-'><length(list_of_files));

"cross" -> rcg_pt_type;
samegraph();
rc_graphplot({0 1 2 3 4 5 6 7 8 9},'',Ties,'') -> region;

if do_sd then
    fast_for a from 0 to 9 do
        rcg_plt_bars(a,Means(a),Stderr(a),rcg_plt_bullet);
    endfast_for;


    fast_for a from 0 to 9 do
        rcg_plt_bars(a,Ties(a),Stderr_ties(a),rcg_plt_cross);
    endfast_for;
endif;

newgraph();

pdp3_adddot(outfile,'rt') -> outfile;
fopen(outfile,"w") -> dev;
for a from 0 to 9 do
    for b from 0 to 9 do
        fputstring(dev,''><mean(table_mean(a,b)));
    endfor;
endfor;
fclose(dev);



enddefine ;
