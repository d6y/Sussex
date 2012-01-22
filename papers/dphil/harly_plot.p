uses rcg;

rc_start();

uses sysio;

vars data = freaditems('~/marith/human/harley.rt');

vars a,b,c=0, list=[];

for a from 0 to 9 do
    for b from 0 to 9 do
        1 + c -> c;
        if a == 0 or b == 0 then
            (data(c)) :: list -> list;
        endif;
    endfor;
endfor;

"h" :: [] =>
