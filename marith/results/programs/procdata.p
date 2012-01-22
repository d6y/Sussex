
;;; For processing of Night.p logs
/*
uses sysio;
uses statlib;
*/

vars logname;

;;;'new6.night_log' -> logname;
;;; 'mix.night_log' -> logname;
;;;'data.night_log'->logname;
;;;'THREE' -> logname;
;;;'Night.output' -> logname;

'ONES.CHURN.OUT' -> logname;
vars dev = fopen(logname,"r");

vars VN = [
'Network tss              '
'Network performance      '
'Number of errors         '
'Operation distance effect'
'Operation errors         '
'   ...of which two prob  '
'Table unrealted (close)  '
'Table unrelated (distant)'
'Operation errors         '
];


vars NUM_VARS;          ;;; number of variables
length(VN) -> NUM_VARS;


define convert(file,idxs);
    vars label,opts,o,value,id,p,l;

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
                elseif isnumber(id) then
                    if substring(id,o(2),file) = o(3) then o(4) -> value; endif;
                endif;

            endfor;

            if value = false then
                pr('WARNING: No pattern applies ('><label><') for '><file);
                nl(1);
                return false;
            else value;
            endif;

        endforeach; %];

enddefine;

/*

vars idxs = [

[index 1 'File type'
    [1 3 'the' 1]
    [1 3 'one' 2]
    [1 3 'not' 3]  ]

[index 2 'Normality'
    [contains '-norm' 2]
    [otherwise 1] ]

[index 3 'Counter'
    [lastdigits] ]
];

vars Inames = [ ['thermometer' 'one-of-n' 'no-ties']
                ['-prob' '-norm']
            ];


vars I1,I2,I3,I4;
3 -> I1;
2 -> I2;
3 -> I3;

vars NFILES = I1*I2*I3;

vars stat=newarray([1 ^I1 1 ^I2 1 ^I3 1 ^NUM_VARS],0);


;;;; NIGHT PROB

vars idxs = [
[index 1 'Training'
    [contains 'PROB' 1]
    [contains 'NORM' 2] ]

[index 2 'Counter'
    [lastdigits] ] ];
2 -> I1;
20 -> I2;

I1*I2 -> NFILES;
vars Inames = [ ['PROB' 'NORM'] ];
    vars stat=newarray([1 ^I1 1 ^I2 1 ^NUM_VARS],0);

*/


vars idxs = [
[index 1 'Type'
    [contains '-norm' 2]
    [otherwise 1] ]

[index 2 'Counter'
    [lastdigits] ]
];
2 -> I1;
3 -> I2;
vars Inames = [ ['PROB' 'NORM']];
vars stat = newarray([1 ^I1 1 ^I2 1 ^NUM_VARS],0);

I1*I2 -> NFILES;

repeat NFILES times

repeat
    fgetstring(dev) -> string;
    stringtolist(string) -> list;

    if list matches [== Processing ?filename ==] then
        quitloop;
    endif;
endrepeat;

stringtolist(fgetstring(dev)) --> [== tss = ?tss ?perf ==  ];

repeat
    fgetstring(dev) -> string;
    stringtolist(string) -> list;

    if list matches [Total of ?nerr errors ==] then
        quitloop;
    endif;
endrepeat;



stringtolist(fgetstring(dev)) --> [== ?ode = ];
stringtolist(fgetstring(dev)) --> [== ?oe = ];
stringtolist(fgetstring(dev)) --> [== ?two = ];
stringtolist(fgetstring(dev)) --> [== ?tuc = ];
stringtolist(fgetstring(dev)) --> [== ?tud = ];
stringtolist(fgetstring(dev)) --> [== ?plus = ];

convert(filename,idxs) -> ix;

/*
ix --> [?h ?n ?nn];
[^filename ^h ^n ^nn] =>

tss -> stat(h,n,nn,1);
perf -> stat(h,n,nn,2);
nerr -> stat(h,n,nn,3);
ode -> stat(h,n,nn,4);
oe -> stat(h,n,nn,5);
tuc -> stat(h,n,nn,6);
tud -> stat(h,n,nn,7);
plus -> stat(h,n,nn,8);
  */

unless ix = false then
ix --> [?h ?n];
[^filename ^h ^n] =>


tss -> stat(h,n,1);
perf -> stat(h,n,2);
nerr -> stat(h,n,3);
ode -> stat(h,n,4);
oe -> stat(h,n,5);
two -> stat(h,n,6);
tuc -> stat(h,n,7);
tud -> stat(h,n,8);
plus -> stat(h,n,9);
endunless;

endrepeat;
fclose(dev);

for i1 from 1 to I1 do
;;;for i2 from 1 to I2 do

nl(3);
/*
pr('Summary statistics (mean) for '><I3><' networks: '><Inames(1)(i1)
><Inames(2)(i2));
*/

pr('Summary statistics (mean) for '><I2><' networks: '><Inames(1)(i1));

nl(2);

for v from 1 to NUM_VARS do

[% for n from 1 to I2 do
    stat(i1,n,v);
endfor; %] -> data;

mean(data) -> r;
spr(VN(v)); prnum(r,3,3);


unless member(v,[1 3 9]) then pr('%'); else pr(' '); endunless;
if v == 9 then
    t_test_r(r,64) -> (t,df);
    upper_t(t,df) -> p;
    pr('(p='); prnum(p,3,3); pr(')');
endif;

pr(' '); prnum(SD(data),3,3); nl(1);
endfor;

endfor;
 ;;;endfor;
