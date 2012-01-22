/*
DO NOT CNTRL-C THIS APPLICATION!!!
If you do, you may need to execute
    7 -> item_chartype(39);
    5 -> item_chartype(58);
to make pop work properly

*/
uses propsheet;
propsheet_init();

vars xmb_start_line, xmb_bibliography_file, xmb_author_size,
    xmb_title_size, xmb_file, xmb_box, xmb_sheet, xmb_key_size;

unless isstring(xmb_bibliography_file) then
    'bib.bib' -> xmb_bibliography_file;
endunless;

unless isnumber(xmb_title_size) then
    15 -> xmb_title_size;
endunless;

unless isnumber(xmb_key_size) then
    8 -> xmb_key_size;
endunless;
unless isnumber(xmb_author_size) then
    10 -> xmb_author_size;
endunless;


define check_end_of_line(pos,p,len,string) -> (pos,p,len,string);
    lvars pos, p, len, string;
    if pos > len then
        p fi_+ 1 -> p;
        subscrv(p,vedbuffer) -> string;
        length(string) -> len;
        1 -> pos;
    endif;
    if p > vvedbuffersize then
        vederror('Missing { in quote (line '><xmb_start_line><')');
    endif;
enddefine;

define find_citations -> citation_list;
    lvars p, string, pos, len, char, gather, citation_list = [];

    ved_w1();
    vedputmessage('One moment...');

    [% fast_for p from 1 to vvedbuffersize do
            subscrv(p,vedbuffer) -> string;
            length(string) -> len;
            1 -> pos;
            repeat;
                issubstring('\\cite',pos,string) -> pos;
            quitif(pos==false);
                p -> xmb_start_line;
                pos+5 -> pos;
                check_end_of_line(pos,p,len,string) -> (pos,p,len,string);
                ;;; scan for {
                while substring(pos,1,string) /= '{' do
                    pos + 1 -> pos;
                    check_end_of_line(pos,p,len,string) -> (pos,p,len,string);
                endwhile;
                ;;; scan for citations
                pos + 1 -> pos;
                check_end_of_line(pos,p,len,string) -> (pos,p,len,string);
                substring(pos,1,string) -> char;
                '' -> gather;
                while char /= '}' do
                    if char = ',' then ;;; end of a citation
                        unless member(gather,citation_list) then
                            gather :: citation_list -> citation_list;
                        endunless;
                        '' -> gather;
                    else
                        gather >< char -> gather;
                    endif;
                    pos + 1 -> pos;
                    check_end_of_line(pos,p,len,string) -> (pos,p,len,string);
                    substring(pos,1,string) -> char;
                endwhile;
                if gather /= '' then
                    unless member(gather,citation_list) then
                        gather :: citation_list -> citation_list;
                    endunless;
                endif;
            endrepeat;

        endfast_for; %];

enddefine;

define extract_details(pos,string) -> details;
    lvars pos, string, details='', len,char, consuming=false,i;

    length(string) -> len;

    for i from pos to len do
        substring(i,1,string) -> char;
        if consuming then
            if char = '\"' or char = '}' then
                quitloop;
            endif;
            if char = '.' then ;;; remove Initials
                min(len,i + 1) -> i;
                substring(1,length(details)-1,details) -> details;
            else
                details >< char -> details;
            endif;
        else
            if char = '\"' or char = '{' then
                true -> consuming;
            endif;
        endif;
    endfor;

    ;;; Repalce AND with &

    length(details) -> len;
    while (issubstring('and',details)->>i) do
        substring(1,i-1,details) >< '&' ><
        substring(min(i+3,len),min(len,len-(i+2)),details) -> details;
        length(details) -> len;
    endwhile;

enddefine;

define stringtolist(string) -> list;
    lvars items, item, string, list;
    incharitem(stringin(string)) -> items;
    [%until (items() ->> item) == termin do item enduntil%] -> list;
enddefine;


define scan_bibliography(citation_list) -> assoc;
    lvars assoc=[], getline, string, ncites,
        nbibs, author_pos, title_pos, author_string, title_string,
        key, openbrace =consword('{'), dev;

    vars possible_key, citation_list;
    length(citation_list) -> ncites;
    vedputmessage('Scanning bibliography for '><ncites ><' citations...');

    if readable(xmb_bibliography_file) then
        5 -> item_chartype(58);
        1 -> item_chartype(39);
        line_repeater(xmb_bibliography_file,1000) -> getline;
    else
        vederror('Cannot open biblography file '><xmb_bibliography_file);
    endif;


    repeat
        getline() -> string;
    quitif(string=termin or citation_list == nil);

        if stringtolist(string) matches [@ == ^openbrace ?possible_key ,] then
            possible_key >< '' -> possible_key;
            if member(possible_key, citation_list) then
                delete(possible_key, citation_list) -> citation_list;
                getline() -> string;
                '' -> title_string;
                '' -> author_string;
                repeat;
                    if issubstring('@',string) or string==termin then
                        7 -> item_chartype(39);
                        5 -> item_chartype(58);
                        vederror('Missing author or title for '><possible_key);
                    endif;
                    issubstring('author',string) -> author_pos;
                    if author_pos then
                        extract_details(author_pos+6,string) -> author_string;
                    else
                        issubstring('title',string) -> title_pos;
                        if title_pos and issubstring('booktitle',string)=false then
                            extract_details(title_pos+5,string) -> title_string;
                        endif;
                    endif;
                quitif(author_string /= '' and title_string /= '');
                    getline() -> string;
                endrepeat;
                [^possible_key ^author_string ^title_string] :: assoc -> assoc;
            endif;

        endif;

    endrepeat;

    if citation_list /= nil  then
        7 -> item_chartype(39);
        5 -> item_chartype(58);
        length(assoc) -> nbibs;
        'Missing '><(ncites-nbibs) >< ' entries: ' -> string;
        for key in citation_list do
            string >< key >< ' ' -> string;
        endfor;
        vederror(string);
    endif;

    7 -> item_chartype(39);
    5 -> item_chartype(58);
enddefine;

define xmb_insert_cite(sheet, field, value) -> value; lvars s;
    if (vedpresent(xmb_file) ->> s)==false
    then
        vederror('You are not editing '><xmb_file);
    else
        vedsetonscreen(s, false);
    endif;
    vedinsertstring('{'><field><'}');
    vedrestorewindows();
enddefine;

define xmb_make_sheet(xmb_box) -> (xmb_assoc, xmb_sheet);
    vars citation_list, key, author, title,count=1;
    find_citations() -> citation_list;
    scan_bibliography(citation_list) -> xmb_assoc;
    vedputmessage('Building window...');
    propsheet_new('Citations', xmb_box, [%
            foreach [?key ?author ?title] in xmb_assoc do
                if count / 2 = intof(count/2) then
                    "+";
                endif;
                count + 1 -> count;
                substring(1,min(length(author),xmb_author_size),author) ->
                author;
                substring(1,min(length(title),xmb_title_size),title) ->
                title;
                [^key command (width=800,nolabel,accepter=xmb_insert_cite)];
                "+"; [^(key><'_xmb_a') message ^author (width= ^(xmb_author_size+1),nolabel)];
                "+"; [^(key><'_xmb_t') message ^title (width= ^(xmb_title_size+1),nolabel)];
            endforeach;
        %]) -> xmb_sheet;
vedputmessage('Ok');
enddefine;



define xmb_buttons(box, button) -> accept;
    lvars accept, box, button,s;
    false -> accept;
    if button = "Quit" then
        propsheet_destroy(box);
    elseif button = "Rescan" then
    if (vedpresent(xmb_file) ->> s)==false
    then
        vederror('You are not editing '><xmb_file);
    else
        vedsetonscreen(s, false);
    endif;
    xmb_make_sheet(xmb_box) -> (xmb_assoc, xmb_sheet);
    endif;
enddefine;


define ved_xmemobib;

    vedpathname -> xmb_file;
    propsheet_new_box('XMemoBib', false, xmb_buttons, [Rescan Quit]) -> xmb_box;
    xmb_make_sheet(xmb_box) -> (xmb_assoc, xmb_sheet);
    propsheet_show([% xmb_sheet, xmb_box %]);

enddefine;
