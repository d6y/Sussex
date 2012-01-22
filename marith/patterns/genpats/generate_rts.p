;;; Write a mean RT for a number of nets to a file

define generate_rts(list_of_files,outfile);

    vars a,b,tabledata,table,file,Data,Stddev,rcg_pt_type,DATA=[];

    newarray([1 64], procedure(n); []; endprocedure) -> Data;
    newarray([1 64]) -> Stddev;

for file in list_of_files do

    read_rt(file) -> tabledata;

    fast_for a from 1 to 8 do
        fast_for b from 1 to 8 do
            1 + ((a-1)*8)+(b-1) -> p;
            tabledata(a)(b) :: Data(p) -> Data(p);
        endfast_for;
    endfast_for;
endfor;

vars dev = fopen(outfile,"w");
for i from 1 to 64 do
fputstring(dev,''><mean(Data(i)));
endfor;
fclose(dev);

enddefine ;
