
vars logname;

'DEVLOG' -> logname;
vars dev = fopen(logname,"r");

vars VN = [
'Network tss              '
'Network performance      '
'Number of errors         '
'Operand distance effect  '
'Operand errors           '
'High frequency products  '
'Table unrelated (close)  '
'Table unrelated (distant)'
'Operation errors         '
];


vars NUM_VARS;          ;;; number of variables
length(VN) -> NUM_VARS;

/*

filename to index language

    contains string number
    otherwise number
    lastdigits
    lastdigits op number (use lastdigits if "op number" true
    start stop substring digit

*/

define convert(file,idxs)->list;
    vars list,label,opts,o,value,id,p,l;

    [% foreach [index = ?label ??opts] in idxs do


            false -> value;
            for o in opts do

                o(1) -> id;


                if id="otherwise" then
                    o(2) -> value;
                elseif id = "contains" then
                    if issubstring(o(2),file) then
                        o(3)->value;
                        quitloop();
                    endif;
                elseif id = "lastdigits" then
                    length(file) ->> p -> l;
                    while isnumber(strnumber(substring(p,1,file))) do
                        p-1 -> p;
                    endwhile;
                    strnumber(substring(p+1,(l-(p+1))+1,file)) -> value;
                    if length(o) = 3 then
                        popval([^value ^(o(2)) ^(o(3))])->boo;
                        if boo = false then
                            false -> value;
                        endif;
                    endif;
                elseif isnumber(id) then
                    if substring(id,o(2),file) = o(3) then o(4) -> value; endif;
                endif;

            endfor;

            if value = false then
                pr('WARNING: No pattern applies ('><label><') for '><file);
                nl(1);
            endif;

                value;

        endforeach; %]->list;

if member(1=0,list) then
    false -> list;
endif;
enddefine;



vars idxs = [

[index 1 'Epoch counter'
    [lastdigits]]
;;;    [lastdigits < 16] ]


[index 2 'Net number'
   [contains 'dev1-' 1]
   [contains 'dev2-' 2]
   [contains 'dev3-' 3]
   [contains 'dev4-' 4]
   [contains 'dev5-' 5]
   [contains 'dev6-' 6]
   [contains 'dev7-' 7]
   [contains 'dev8-' 8]
   [contains 'dev9-' 9]
   [contains 'dev10-' 10] ] ];

[% for i from 1 to 30 do i; endfor; 60; 90; 120; 150;
for i from 180 by 500 to 5000 do i; endfor; %] -> I1;
10 -> I2;

vars Inames = [ [% for i from 1 to 15 do 'step'><i; endfor; %] ];
vars stat=newarray([1 ^(length(I1)) 1 ^I2 1 ^NUM_VARS],0);

length(I1)*I2 -> NFILES;
[] -> found;
until length(found)=NFILES do

repeat
    fgetstring(dev) -> string;
    stringtolist(string) -> list;

    if list matches [== Processing ?filename ==] then
        quitloop;
    endif;
endrepeat;


until stringtolist(fgetstring(dev)) matches [== tss = ?tss ?perf ==  ] do enduntil;

repeat
    fgetstring(dev) -> string;
    stringtolist(string) -> list;

    if list matches [Total of ?nerr errors ==] then
        quitloop;
    endif;
endrepeat;

stringtolist(fgetstring(dev)) --> [== ?ode = ];
stringtolist(fgetstring(dev)) --> [== ?oe = ];
stringtolist(fgetstring(dev)) --> [== ?hif = ];
stringtolist(fgetstring(dev)) --> [== ?tuc = ];
stringtolist(fgetstring(dev)) --> [== ?tud = ];
stringtolist(fgetstring(dev)) --> [== ?plus = ];

convert(filename,idxs) -> ix;

unless ix = false then

ix --> [?h ?n];
I1 --> [??pre ^h ==];
1+length(pre) -> h_pos;
[^filename ^h ^h_pos ^n] =>
h_pos -> h;
n :: found  -> found;

tss -> stat(h,n,1);
perf -> stat(h,n,2);
nerr -> stat(h,n,3);
ode -> stat(h,n,4);
oe -> stat(h,n,5);
hif -> stat(h,n,6);
tuc -> stat(h,n,7);
tud -> stat(h,n,8);
plus -> stat(h,n,9);

endunless;
enduntil;
fclose(dev);

for i1 in I1 do
;;;for i2 from 1 to I2 do

I1 --> [??pre ^i1 ==];
1+length(pre) -> i1_pos;

nl(3);
/*
pr('Summary statistics (mean) for '><I3><' networks: '><Inames(1)(i1_pos)
><Inames(2)(i2));
*/

pr('Summary statistics (mean) for '><I2><' networks: '><Inames(1)(i1_pos));

nl(2);

for v from 1 to NUM_VARS do

[% for n in found do
    stat(i1_pos,n,v);
endfor; %] -> data;

mean(data) -> r;
spr(VN(v)); prnum(r,3,3);

unless member(v,[1 3]) then pr('%'); else pr(' '); endunless;
pr(' ');
;;;prnum(SD(data),3,3);
prnum(0,3,3);
nl(1);
endfor;

endfor;
 ;;;endfor;

;;; data for 10 dev nets 15-30 epochs and
;;; 31 32  33 34       35
;;; 60 90 120 150 then 180 by 500 to 5000
;;; stat -> datafile('statdev.arr');

define writeall(s1,s2,v);;
    for j from 1 to 10 do
        fopen('dev'><j><'.xgr',"w") -> dev;
        fputstring(dev,'"Run '><j><'"');
        for i from s1 to s2 do
            fputstring(dev,I1(i)><' '><stat(i,j,v));
        endfor;
        fclose(dev);
    endfor;
enddefine;

[undef undef 70 110] -> rcg_usr_reg;
undef-> rcg_usr_reg;
showmean(35,44,5);
writeall(31,35,2);

;;; index: 1 = tss 2 = performance 5= table-related
define showmean(S1,S2,v);
    vars SD_list = [], N = sqrt(10);
    [% for i from S1 to S2 do
            [% for j from 1 to 10 do stat(i,j,v); endfor; %] -> data;
            {% I1(i); mean(data); %};
            SD(data)/N :: SD_list -> SD_list;
        endfor; %] -> data;
    rc_graphplot2(data,'Epochs','')->region;
    region --> [?x1 ?x2 = ?y];
    rc_print_at(x1+(x2-x1)/4,y,'Epochs: '><I1(S1)><' - '><I1(S2));
    rc_print_at(x1+(x2-x1)/4,y*1.02,VN(v));
    rev(SD_list) -> SD_list;
    for i from S1 to S2 do
        rcg_plt_bars(I1(i),data(i-S1+1)(2),SD_list(i-S1+1),rcg_plt_bullet);
    endfor;
enddefine;
