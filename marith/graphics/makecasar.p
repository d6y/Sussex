/*
'pca3' -> file;
'p3x9' -> p;
pdp3_recordcascade_hidden(net,pats,'zero',p,70,0.05) -> v;
'pca3' -> file;
sysobey('rm -f '><file);
sysobey('pca -f 01_norm30-2.clx -i zero-'><p><'.cas  -x 0 -y 1 -z 2 > '><file);
*/

fopen(file,"r") -> dev;
vars clist = [%
    repeat
    fgetstring(dev) -> string;
    quitif(string=termin);
    stringtolist(string);
    endrepeat;
%];
fclose(dev);
vars kk=1;
foreach [?x ?y ?z] in clist do
(x-min_x)*xs ->x;
(y-min_y)*ys ->y;
(z-min_z)*zs ->z;
if kk = 1 then
elseif kk=2 then
rc_3d_cross(x,y,z);
else
if kk /4 = intof(kk/4) and kk < 30then
    rc_3d_drawto(x,y,z);
rc_3d_jumpto(x,0,z);
rc_3d_drawto(x,y,z);
else
    rc_3d_drawto(x,y,z);
endif;
endif;
kk+1->kk;
endforeach;
