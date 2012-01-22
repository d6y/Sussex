uses sysio;

vars DEBUG = true;

vars

    entry_types,        ;;; List of entry types (e.g., 'book');
    bibstyle_list,      ;;; List of styles (e.g., 'psy' or 'apa')
    default_bibstyle,   ;;; String, default style to use.

    comment_device,
    FATAL = 1,
    CONTINUE = 2;

/*

Each style should define procedures for each kind of publication,

    stylename_entrytype (bib_record);

E.g.,

    psy_book_entry(bib_record)
    psy_article_entry(bib_record) ... etc

for all of:

    article         book            booklet         inbook
    incollection    inproceedings   manual          mastersthesis
    misc            phdthesis       proceedings     techreport
    unpublished

AND

    stylename_bibcite(bib_record);

When a procedure is not defined, the default version will be used

*/


unless islist(bibstyle_list) then
    ['psy'] -> bibstyle_list;
endunless;

unless isstring(default_bibstyle) then
    hd(bibstyle_list) -> default_bibstyle;
endunless;

unless islist(entry_types) then
[   'article' 'book' 'booklet' 'inbook' 'incollection' 'inproceedings'
    'manual' 'mastersthesis' 'misc' 'phdthesis' 'proceedings' 'techreport'
    'unpublished' ] -> entry_types;
endunless;

defclass procedure bib_record {
    ;;; All strings
    Address,
    Annote,
    Author,
    Booktitle,
    Chapter,
    Edition,
    Editor,
    Howpublished,
    Institution,
    Journal,
    Key,
    Month,
    Note,
    Number,
    Organization,
    Pages,
    Publisher,
    School,
    Series,
    Title,
    Type,
    Volume,
    Year
};


define vedcomment(string, status);
    if DEBUG then string==> endif;
    fputstring(comment_device,string);
    if status = FATAL then
        fclose(comment_device);
        vederror(string);
    else
        vedputmessage(string);
    endif;
enddefine;


define parse_aux_file(auxfile) -> (bibcite_list, bibfile, bibstyle);
    lvars ss, ll, dev, line;

    false -> bibstyle;
    false -> bibfile;
    [] -> bibcite_list;

    fopen(auxfile,"r") -> dev;
    vedcomment('Reading '><auxfile><'...', CONTINUE);

    repeat;
        fgetstring(dev) -> line;
    quitif(line=termin);
        length(line) -> ll;
        if ll > 9 then
            substring(1,10,line) -> ss;
            if ss = '\\citation{' then
                substring(11,ll-11,line) :: bibcite_list -> bibcite_list;
            elseif ss = '\\bibstyle{' then
                substring(11,ll-11,line) -> bibstyle;
            elseif ll > 8 then
                if substring(1,9,line) = '\\bibdata{' then
                    ;;; ONLY ONE BIB FILE ALLOWED
                    substring(10,ll-10,line) -> bibfile;
                endif;
            endif;
        endif;
    endrepeat;

    fclose(dev);
enddefine;

define parse_bib_file(outputfile, bibfile, bibstyle, bibcite_list);

    lvars idev, odev, i, c, line, ll;

    vars abrv = [], short, long;

    fopen(bibfile,"r") -> idev;
    if idev = false then
        vedcomment('Can\'t open bib file '><bibfile,FATAL);
    endif;

    fopen(outputfile,"w") -> odev;

    vedcomment('Reading '><bibfile><' ('><bibstyle><','
        ><(length(bibcite_list))><')', CONTINUE);


    repeat
        fgetstring(idev) -> line;
    quitif(line=termin);

    length(line) -> ll;

    if ll > 7 then
        if substring(1,8,line) = '@string{' then
            ;;; abbreviation
            '' -> short;
            9 -> i;
            while (substring(i,1,line) ->> c) /= ' ' and c /= '=' do
                short >< c -> short; i+1->i;
            endwhile;
            uppertolower(short) -> short;
            ;;; Look for the " marks
            issubstring('\"',8,line) -> i;
            substring(i+1,ll-(i+2),line) -> long;
            [% short; long; %] :: abrv -> abrv;
        endif;

    endif;

    endrepeat;

abrv ==>



    fclose(idev);
    fclose(odev);
enddefine;

define ved_bibtex;
    lvars
        dir = sys_fname_path(vedpathname),
        rootfile = dir dir_>< sys_fname_nam(vedpathname),
        auxfile = rootfile sys_>< '.aux',
        outputfile,
        commentfile;

    vars
        bibcite_list,
        bibstyle,
        bibfile;

    unless vedargument = '' then
        sys_fname_path(vedargument) -> dir;
        dir dir_>< sys_fname_nam(vedargument) -> rootfile;
        rootfile sys_>< '.aux' -> auxfile;
    endunless;

    unless readable(auxfile) then
        vederror('Can\'t open '><auxfile);
    endunless;

    rootfile sys_>< '.vbg' -> commentfile;
    rootfile sys_>< '.bbl' -> outputfile;

    fopen(commentfile,"w") -> comment_device;
    fputstring(comment_device,'ved_bibtex: '><rootfile><' ('><(sysdaytime())><')');

    parse_aux_file(auxfile) -> (bibcite_list, bibfile, bibstyle);

    bibfile >< '.bib' -> bibfile;

    if bibcite_list = nil then
        vedcomment('No \\citation lines in aux file',FATAL);
    endif;

    if bibfile = false then
        vedcomment('Bibliography file not specified in aux file',FATAL);
    endif;

    unless member(bibstyle,bibstyle_list) then
        vedcomment('Style \"'><bibstyle><'\" unknown...using \"'
            ><default_bibstyle><'\"', CONTINUE);
    endunless;

    parse_bib_file(outputfile, bibfile, bibstyle, bibcite_list);

    vedcomment('Log in '><commentfile, CONTINUE);
    fclose(comment_device);

enddefine;
