From cogs.susx.ac.uk!teresa Sat May  8 16:27:01 1993
Date: Sat, 8 May 93 16:26 BST
From: teresa@cogs.susx.ac.uk (Teresa Del Soldato)
To: richardd@cogs.susx.ac.uk

stringtolist('this is a list [a b [dog [] [1 2 3 4] cat] c d e] hello') -> list;


define check_sublist(list) -> list;
    vars item,list;
    unless list == nil then
        destpair(list) -> list -> item;
        if item == "[" then
            [% check_sublist(list) -> list; %];
        elseif item == "]" then
            ;;;
        else
            item;
            check_sublist(list) -> list;
        endif;
    endunless;
enddefine;

define sublistify(list) /* -> list */ ;
[% until list == nil then
        check_sublist(list) -> list;
   enduntil; %];
enddefine;

