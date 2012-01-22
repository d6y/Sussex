vars Arith_keys_Width;

define get_list_width;
    vars wid,n;

    define dlocal pop_timeout;
        if iscaller(vedinascii) then
            exitfrom(false, vedinascii);
        endif;
    enddefine;

    vedclearinput();
    repeat
        vedinascii() -> n;

        if n = 13 then ;;; do nothing
            quitloop;
        elseif n>47 and n<58 then ;;; number
            n-48->wid;
            quitloop;

        endif;
    endrepeat;

    if isnumber(wid) then
        wid -> Arith_keys_Width;
    endif;

enddefine;


define make_num_list;
    vars digits;

    unless isnumber(Arith_keys_Width) then
        vedscreenbell();
    endunless;

    [% repeat Arith_keys_Width times
            vedinascii() -> n;
            if n=13 then quitloop; endif;
            n-48;
        endrepeat; %] -> digits;

    while length(digits) < Arith_keys_Width do
        [- ^^digits] -> digits;
    endwhile;

    vedinsertstring('['><listtostring(digits,' ')><'] [');
    repeat Arith_keys_Width times vedinsertstring('- '); endrepeat;
    vedchardelete();
    vedinsertstring('] ');

enddefine;

define make_rule_list;
    unless isnumber(Arith_keys_Width) then
        vedscreenbell();
        return;
    endunless;

    repeat 2 times
        vedinsertstring('[');
        repeat Arith_keys_Width times
            vedinsertstring('= ');
        endrepeat;vedchardelete(); vedinsertstring('] ');
    endrepeat;
enddefine;

;;; CTRL-n
vedsetkey('\^N', make_num_list);

;;; CTRL-b
vedsetkey('\^B', make_rule_list);

;;; CTRL-j
vedsetkey('\^J', get_list_width);

vars arithkeys = true;
