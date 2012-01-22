vars dev;

uses sysio;

fopen('pca1',"r") -> dev;


0 ->> min_x ->> min_y -> min_z;
1 ->> max_x ->> max_y -> max_z;
vars a,b;
0 ->> a-> b;
-1 -> b;
vars list = [%
    repeat
    fgetstring(dev) -> string;
    quitif(string=termin);

    stripquotes(string) -> string;
    stringtolist(string) -> string;
    string --> [?x ?y ?z ?n];
    min(min_x,x) -> min_x;
    max(max_x,x) -> max_x;
    min(min_y,y) -> min_y;
    max(max_y,y) -> max_y;
    min(min_z,z) -> min_z;
    max(max_z,z) -> max_z;

    if n = "Zero" then
        n -> t;
    else
    b+1->b;
        min(a,b)><max(a,b)><'' -> t;
    endif;

    [% x; y; z; n; t; %];
    if b = 9 then -1 -> b; a+1->a;endif;

    endrepeat;
%];

fclose(dev);

1/(max_x - min_x) -> xs;
1/(max_y - min_y) -> ys;
1/(max_z - min_z) -> zs;

rc_3d_init();
mkrotate(30,40,0) -> rc_3d_R;
rc_3d_unitcube();
foreach [?x ?y ?z ?n ?t] in list do
(x-min_x)*xs ->x;
(y-min_y)*ys ->y;
(z-min_z)*zs ->z;

strnumber(''><n) -> n;
unless n = false then
if member(intof(n/10),[0 8])    then
;;;if lc-10*intof(lc/10) = 0 then
rc_3d_jumpto(x,0,z);
rc_3d_drawto(x,y,z);
rc_3d_print_at(x,y,z,''><n);
endif;
endunless;
endforeach;
