/* Usage: stringtolist(string) -> list; */

compile_mode:pop11 +defcon +defpdr ;


section;

define isnotpunctuation(char);
lvars char, c = char(1);

    if
        c /= 43 and
;;;        c /= 45 and
;;;        c /= 46 and
;;;        c /= 47 and
        c fi_< 45
        or
        (c fi_> 57 and c fi_< 65)
        or
        (c fi_> 90 and c fi_< 95)
        or
        c fi_> 122 then
        false;
    else
        true;
    endif;
enddefine;


define dump(string);
    lvars string, number = strnumber(string);
    unless string = '' then
        if number /= false then
            number_coerce(strnumber(string),1);
        else
            consword(string);
        endif;
    endunless;
enddefine;

define global old_stringtolist(string) -> list;

        lvars char ='', stringword = '',i;

    vars list = [%

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

    %];
enddefine;

define global stringtolist(string) -> list;
    vars items, item;
    incharitem(stringin(string)) -> items;
    [%until (items() ->> item) == termin do item enduntil%] -> list;
enddefine;


endsection;
