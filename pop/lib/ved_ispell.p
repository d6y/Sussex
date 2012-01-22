/*
    VED_ISPELL.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>

    April 27, 1990
    Sussex POPLOG (Version 13.7 Tue Mar  6 17:26:29 GMT 1990)


    Usually assigned to CTRL-a to check the spelling of the word at the cursor.
    ISPELL's guesses are presented the same way vedfileselect offers files.

    i.e, put vedsetkey('\^a', "ved_ispell"); in your vedinit.p
    and copy ved_ispell.p to a directory in popuseslist (etc).

    SEE MAN * ISPELL

    Bits stollen from SHOWLIB * VED_THESAURUS.P
                      SOURCEFILE VEDFILESELECT


    HISTORY:

    [bf 1] 21 November 1991: ISPELL sometimes returns suggested words which
    contain capital letters.  In the case when both the sugested word and
    the misspelt word were upper case, the routine made the suggested
    word "even more upper case", resulting in S becoming 3.  This is fixed.

    [bf 2] 10 January 1992: Now checks for the one-line identifier message
    produced by Ispell 3.0 (skips the first line of output from Ispell if it
    begins with @).

    [bf 3] 10 January 1991:  Changes to ISPELL: Ispell -a now returns '-' if
    a word was found through compound formation. Also, the format of the '&'
    return has changed (so ved_ispell now only works with versions of Ispell
    that generate a version identifier).  ISPELL capatalizes it's guesses
    in accordance with the misspelt word.

    [up 1] 10 January 1992: Added ved_ispell_flags string to allow users to
    change the flags given to Ispell.  Also ved_ispell_motivate_list can be
    modified by users to give alternative "motivations".

    [up 2] 10 January 1992: Added ved_ilearn and * option to allow words to be
    stored in the user's dictionary.

    [up 3] 26 March 1992: Version 3.0.09 (beta) changed back the meaning of -S
    to be "supress sorting".

    [up 4] 8 June 1992: ved_ispell checks that it hasn't been asked to check
    punctionation marks.

    [bf 4] 22 June 1992: Spaces can be part of ISPELL's guesses.

    [up 5] 22 June 1992: Changed the labeling on guesses to start from zero,
    just as they do in ISPELL.

    [up 6] 3 September 1992: When checking the spelling of the last word
    types, ved_ispell would use vedendwordright() to advance the cursor.
    In this case, there is no next word, so the cursor moved to the start
    of the next (empty) line.  This means that the author would have to
    move the cursor back to the end of the previous line to continue
    typing.  This has been changed by introducing ved_ispell_nextword()
    which, at the end of a line, only moves to the next line if the
    next line contains something.

    [up 7] 3 September 1992: If a punctuation mark is found, ved_ispell
    tries to search back for another word. See [up 4].

    [up 8] 16 July 1993: In some situations, ispell will not produce any
    output (e.g., no memory available) or produces an empty file. Ved_ispell
    now checks for this and produces a -vederror-.  The -mishap- for out
    of date versions of ISPELL (that don't produce version identifiers) has
    been replaced with a -vederror-.


 */


;;; [up 1]
vars ved_ispell_flags;
unless isstring(ved_ispell_flags) then
    '' -> ved_ispell_flags; ;;; [up 2]
endunless;

vars ved_ispell_motivate_list;
unless islist(ved_ispell_motivate_list) then
    [' - Great spelling!' ' - Lovely spelling' '' '' '' '' ''
        ' - You didn\'t need my help' ' - that spelling is fine'
        '- Excelent spelling!']
        -> ved_ispell_motivate_list;
endunless;


/* From showlib * vedendwordright
   Moved forward to the end of the next word, but does not
move the cursor to the next line if the next line is empty */
define ved_ispell_nextword;
    lvars i;
    vedchartype(` `) -> i;
    if vedcolumn > vvedlinesize then
        unless vedline > vvedbuffersize then
            vednextline();
        endunless;
        if vvedlinesize > 0 then
            vedtextleft();
            if vedcolumn > 1 then vedcharleft(); endif;
        else                ;;; This else inserted (rzd)
            vedcharleft();
        endif;
    else
        ;;; traverse spaces on right
        vedcharright();
        while vedcurrentchartype() == i and vedcolumn <= vvedlinesize do
            vedcharright();
        endwhile;
        vedcharleft();
        until vedatitemend(vedcolumn,vedthisline(),vvedlinesize + 1) do
            vedcharright()
        enduntil;
        vedcharright();
    endif;
enddefine;



/* Like vedstartwordleft but, if the cursor is before the first word
 * on a line then moves it to before the last word on the previous line

 RZD: changed to stop punctuation from begin selected as a word.
      See PUNCT variable.

*/

vars punct = chartype(`(`);

define constant vedispell_startwordleft();
    lvars vedtemp;
    chartype(` `) -> vedtemp;
    if vvedlinesize == 0 then
        vedcharup();
        vedtextright()
    endif;
    if vedcolumn fi_> vvedlinesize fi_+ 1 then
        vvedlinesize fi_+ 1 -> vedcolumn;
    endif;
    if not((vedcurrentchar()/==vedtemp and vedcurrentchartype()/=punct) and
            (vedatitemstart(vedcolumn,vedthisline(),vvedlinesize fi_+ 1))) then
        while  vedcurrentchartype() == vedtemp or vedcurrentchartype() ==punct do
            vedcharleft();
        endwhile;
        vedcharleft();
        until (vedcolumn==1) or (vedcurrentchartype()==vedtemp) or (vedcurrentchartype()==punct) and
            vedatitemstart(vedcolumn,vedthisline(),vvedlinesize fi_+ 1) do
            vedcharleft()
        enduntil;
    endif;
enddefine;


define Getnumber(_char, _filecount);
    lvars _char, _filecount;
    max(if _filecount fi_< 10 then
            _char fi_- `0`
        else    ;;; convert what may be a non-numeric label
            uppertolower(_char) -> _char;
            if (_char - `0` ->> _char) fi_>= 10 then
                _char fi_- 39
            else
                _char
            endif
        endif, 0)   ;;; [up 5] changed 1 to zero.
enddefine;

;;; Just store the word in the user dictionary
define ved_ilearn;
    vedispell_startwordleft();
    vars checkword = (vednextitem());
    vedputmessage('Storing '><checkword><' in dictionary...');
    sysobey('echo "*'><checkword><'" | ispell -a '><ved_ispell_flags><' > /dev/null');
    vedputmessage('DONE');
enddefine;


define ved_ispell;
    vars dummy,tmpfile = systmpfile(false,'ved_ispell','.tmp'),
        char = inits(1), string = '',label=inits(1), device, g, guess,
        largeselection=false,n,h,upperify,newword,size=0;

    vedispell_startwordleft();
    vars checkword = vednextitem();

    ;;; [up 4]
    if chartype(checkword(1)) = punct then
        vedcharleft();
        vedispell_startwordleft();
        vednextitem() -> checkword;
        if chartype(checkword(1)) = punct then ;;; [up 7]
            vedputmessage('Won\'t check '><checkword><' punctuation');
            return;
        endif;
    endif;


    vedputmessage('Checking '><checkword);
    sysobey('echo '><checkword><' | ispell -a '><ved_ispell_flags><' > '><tmpfile);

    sysopen(tmpfile,0,"line")-> device;

    ;;; [up 8]
    if device == false then
        vederror('Ispell failed to run');
    endif;

    sysread(device,char,1) -> dummy;

    if dummy = 0 then   ;;; no bytes read [up 8]
        vederror('No output from ispell');
        sysdelete(tmpfile) -> dummy;
    endif;

    ;;; [bf 2]
    if char = '@' then ;;; Version 3.0 version identifier string
        ;;; Scan over line
        until char = '\n' do sysread(device,char,1) -> dummy; enduntil;
        sysread(device,char,1) -> dummy;
    else
        vederror('No version id. (old version of ispell?)'); ;;; [up 8]
    endif;

    ;;; [bf 2] added the '?'
    if char = '&' or char = '?'  then
        vedputmessage('Guessing...');

        ;;; [bf 3] skip to :
        until char = ':' do sysread(device,char,1) -> dummy; enduntil;
        sysread(device,char,1) -> dummy;    ;;; skip over first space [bf 4]

        ;;; [bf 3] guesses separated by commas
        [% while dummy /= 0  do
                sysread(device,char,1) -> dummy;
                if char = ',' then
                    string;
                    length(string) + size -> size;
                    '' -> string;
                    sysread(device,char,1) -> dummy;    ;;; skip over first space [bf 4]
                elseif char(1) >= 32 then   ;;; [bf 4] inserted the =
                    string >< char -> string;
                endif;
            endwhile;
            string;
            length(string) + size -> size; %] -> guess;
        sysclose(device);

        'SELECT, RETURN or *' -> h;
        if length(guess)*3+size < (vedscreenwidth-length(vedstatusheader)-length(h)) then
            false -> largeselection;
            '' -> string;
            for g from 0 to length(guess)-1 do  ;;; [up 5]
                string >< ' '><g><':'><guess(g+1) -> string;
            endfor;
            vedputmessage('Select:'><string><' or RETURN or *');
        else
            true -> largeselection;
            systmpfile(false,'ved_iguess','.tmp') -> tmpfile;
            vededitor(vedhelpdefaults, tmpfile);
            if wved_should_warp_mouse("vedfileselect") then
                ;;; change input window so that it will change back later
                wved_set_input_focus(wvedwindow)
            endif;
            vedinsertstring('        ISPELL\'S GUESSES   Type label, * to learn, or RETURN ');
            vednextline();
            for g from 0 to length(guess)-1 do  ;;; [up 5]
                vednextline(); 3 -> vedcolumn;
                if g < 10 then
                    48+g -> label(1);
                else
                    55+g -> label(1);
                endif;
                vedinsertstring(label><': '><guess(g+1));   ;;; [up 5]
            endfor;
        endif;

        ;;; read key press

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

                ;;; [up 2]
            elseif n = 42 then  ;;; * = learn
                vedputmessage('Storing '><checkword><' in dictionary...');
                sysobey('echo "*'><checkword><'" | ispell -a '><ved_ispell_flags><' > /dev/null');
                quitloop;
            else
                Getnumber(n, length(guess)) -> n;
                if n >= 0 and n<length(guess) then  ;;; [up 5]
                    quitloop;
                else
                    vedscreenbell();
                endif;
            endif;

        endrepeat;

        if largeselection then
            ved_q();
        endif;

        if n = 13 then
            vedputmessage('No change');
        elseif n /= 42 then
            ''><guess(n+1) -> newword;  ;;; [up 5]
            vedendwordrightdelete();
            vedinsertstring(newword);
            vedputmessage('DONE');
        else
            vedputmessage('DONE');
        endif;

        ;;; [bf 3]
    elseif char = '+' or char = '*' or char = '-' then
        vedputmessage('OK'><oneof(ved_ispell_motivate_list));
        sysclose(device);
        vedendwordright(); ;;; extra skip
    else
        sysclose(device);
        vedscreenbell();
        vedputmessage('Sorry...I can\'t help you');
    endif;

    sysdelete(tmpfile) -> dummy;

    ;;; put cursor ahead of word, ready to continue typing [up 6]
    ved_ispell_nextword();

enddefine;
