
/* Usage: stringtovector(string) -> vector; */

/* isnotpunctuation(char) and sump() from stringtolist */

/*
define stringtovector(string) -> vect;
    vars vect = {%

        vars char ='', stringword = '',i;
        fast_for i from 1 to length(string) do
            substring(i,1,string) -> char;
            if isnotpunctuation(char) then
                stringword >< char -> stringword;
            else
                dump(stringword);

                unless char(1) < 33 then
                    consword(char);
                endunless;
                '' -> stringword;
            endif;
        endfast_for;

    dump(stringword);
    %};
enddefine;
*/

define stringtovector(string) -> v;
    lvars items, item, string, v;
    incharitem(stringin(string)) -> items;
    {%until (items() ->> item) == termin do item enduntil%} -> v;
enddefine;
