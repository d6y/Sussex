/* --- Copyright University of Sussex 1992. All rights reserved. ----------
 > File:            $poplocal/local/auto/ved_spell.p
 > Purpose:         VED interface to Unix 'spell' program
                     (based on original by David Allport, June 1985)
 > Author:          John Williams, Nov 26 1992
 > Documentation:   HELP * SPELL
 > Related Files:
 */

section;

/* vedspellbritish - if true, '-b' flags is passed to Unix 'spell' */

global vars vedspellbritish;
if isundef(vedspellbritish) then
    true -> vedspellbritish
endif;

/* vedspell_ispellflags - string, flags for ISPELL */
global vars vedspell_ispellflags;
if isundef(vedspell_ispellflags) then
    '' -> vedspell_ispellflags;
endif;


/* vedspellfile - name of file in which personal spelling list is kept */

global vars vedspellfile;
if isundef(vedspellfile) then
    sysfileok('~/.myspells') -> vedspellfile
endif;

/* vedspelloutputfile - name of temporary VED file used by ved_spell to
    display unrecognised words
*/

global vars vedspelloutputfile;
if isundef(vedspelloutputfile) then
    systmpfile(false, 'ved_spell', nullstring) -> vedspelloutputfile
endif;

/* ved_respell - examines file of unrecognised words, prompts user for
    correct spellings
*/

lconstant Spell_options =
[
'-- SPELLING CORRECTION OPTIONS -----------------------------------------'
'    <new word>              Replace with <new word>, using <ENTER> S'
'    <new word>/g            Replace with <new word>, using <ENTER> GS'
'    =                       Add word to personal spelling list'
'    ?                       Guess word'
'    <RETURN>                Ignore this word'
'------------------------------------------------------------------------'
];

define lconstant Sort_vedspellfile(words);
    lvars line line_in line_out words;
    if sys_file_stat(vedspellfile, nullvector) then
        vedfile_line_repeater(vedspellfile, true) -> line_in;
        [% dl(words),
            for line from_repeater line_in do line endfor
        %] -> words
    endif;
    syssort(words, false, alphabefore) -> words;
    vedfile_line_consumer(vedspellfile, true) -> line_out;
    applist(words, line_out);
    line_out(termin)
enddefine;


define lconstant Apply_in_file(pdr, file);
    lvars procedure (pdr) start_file;
    vedpathname -> start_file;
    if vedpresent(file) then
        vedselect(file);
        pdr();
        if vedpresent(start_file) then
            vedselect(start_file)
        else
            vederror('Can\'t return to ' <> vedpathname)
        endif
    else
        vederror('File "' <> file <> '" not in VED')
    endif
enddefine;


define lconstant Set_iv(word) -> pos;
    lvars n pos word;
    dlocal vedargument;
    vedtopfile();
    if vedtestsearch(word, false)
    or vedtestsearch(word, true) then
        {^vedline ^vedcolumn} -> pos;
        'c +1' -> vedargument;
        datalength(word) -> n;
        repeat n times ved_chat() endrepeat;
        repeat n times vedcharleft() endrepeat;
    else
        false -> pos
    endif
enddefine;


define lconstant Unset_iv(word, pos);
    lvars n pos word;
    dlocal vedargument;
    vedjumpto(pos);
    datalength(word) -> n;
    'c -1' -> vedargument;
    repeat n times ved_chat() endrepeat;
    repeat n times vedcharleft() endrepeat
enddefine;


define lconstant Replace(command, word, new, pos);
    lvars command line new word;
    vedjumpto(pos);
    vedthisline() -> line;
    if vedatitemstart(vedcolumn, line, vvedlinesize)
    and vedatitemend(vedcolumn + datalength(word), line, vvedlinesize) then
        veddo(command <> '"' <> word <> '"' <> new, true)
    else
        veddo(command <> '/' <> word <> '/' <> new, true)
    endif;
    vedputmessage('Done')
enddefine;

define guess_word(word) -> guesses;
    lvars
        tmpfile = systmpfile(false,'spell_guess','.tmp'),
        char=inits(1),
        dummy,
        string = '',
        num;

    vars device, guess;

    nil -> guesses;

    vedputmessage('Guessing:'><word);
    sysobey('echo '><word><' | ispell -a '><vedspell_ispellflags><' > '><tmpfile);

    sysopen(tmpfile,0,"line")-> device;
    sysread(device,char,1) -> dummy;

    if char = '@' then ;;; Version 3.0 version identifier string
        ;;; Scan over line
        until char = '\n' do sysread(device,char,1) ->dummy; enduntil;
        sysread(device,char,1)->dummy;
    endif;

    if char = '&' or char = '?'  then   ;;; Guess found

        ;;; Skip to the ":"
        until char = ':' do sysread(device,char,1) -> dummy; enduntil;
        sysread(device,char,1) -> dummy;    ;;; skip over first space

        ;;; guesses separated by commas
        [% while dummy /= 0  do
                sysread(device,char,1) -> dummy;
                if char = ',' then
                    string;
                    '' -> string;
                    sysread(device,char,1) -> dummy;
                elseif char(1) >= 32 then
                    string >< char -> string;
                endif;
            endwhile;
            string;
        %]-> guesses;


    elseif char = '+' or char = '*' or char = '-' then
        vedinsertstring('Spelling ok!\n');
    else
        vedinsertstring('Sorry...Can\'t help you.');
    endif;

    sysclose(device);
    sysdelete(tmpfile) -> dummy;

    ;;; Display the spellings

    unless guesses = nil then
        0 -> num;
        for guess in guesses do
            num + 1 -> num;
            vedinsertstring(num><'. '><guess><'\n');
        endfor;
    endunless;

    vedlinebelow();
    vedinsertstring(word);

enddefine;


/*
    Test to see if the STRING is a number, possibly with '/g' at
    the end of the string.
*/

define is_a_number(string) -> (boolean, command, number);

    false -> boolean;
    strnumber(string) -> number;

    if number then
        true -> boolean;
        's' -> command;
    elseif isendstring('/g', string) then
        strnumber(allbutlast(2, string)) -> number;
        'gs' -> command;
        if number then
            true -> boolean;
        endif;
    endif;

enddefine;


define global ved_respell();
    lvars source_file, read_input_again, guesses=nil,number;
    dlocal
        pop_charin_device = consveddevice(vedpathname, 2, false),
        proglist_state = proglist_new_state(charin),
        popprompt = '? ',
        ;

    /* Remove 'respell' from command line, in case REDO is pressed
        unintentionally */
    vedputcommand(nullstring);

    /* Determine name of source text file (also save cursor pos.) */
    vedswapfiles();
    vedpositionpush();
    vedpathname -> source_file;
    vedswapfiles();

    /* Insert reminder of options at start of file */
    vedtopfile();
    unless vedthisline() = hd(Spell_options) do
        dlocal vveddump = Spell_options;
        veddo('y 0', false)
    endunless;
    vedjumpto(length(Spell_options) + 1, 1);

    /* Clear junk from previous runs */
    lvars line;
    vedpositionpush();
    until vedatend() do
        vedthisline() -> line;
        if line = nullstring
        or strmember(vvedpromptchar, line) then
            vedlinedelete()
        else
            vednextline()
        endif;
    enduntil;
    vedpositionpop();

    /* Examine each mispelled word */

    lvars command, input, new, new_words, pos, word;
    [] -> new_words;
    until vedatend() do
        false -> read_input_again;
        vedthisline() -> word;
        if isalphacode(word(1))
        and (Apply_in_file(word, Set_iv, source_file) ->> pos) then
            vedlinebelow();
            readstringline() -> input;
            if input = nullstring then
                /* ignore this word */
            elseif input = '=' then
                word :: new_words -> new_words
            elseif input = '?' then
                true -> read_input_again;
                guess_word(word) -> guesses;
            elseif (is_a_number(input) -> (command,number)) then
                ;;; possible response to a guess
                if number > 0 and number =< length(guesses) then
                    guesses(number) -> new;
                    Apply_in_file(command, word, new, pos, Replace, source_file);
                endif;
            else
                if isendstring('/g', input) then
                    allbutlast(2, input) -> new;
                    'gs' -> command
                else
                    input -> new;
                    's' -> command
                endif;
                Apply_in_file(command, word, new, pos, Replace, source_file);
                false -> pos    /* No need to unset inverse video */
            endif;
            if pos then
                Apply_in_file(word, pos, Unset_iv, source_file)
            endif
        else
            vedputmessage('Couldn\'t locate "' <> word <> '"')
        endif;
        unless read_input_again then
            vednextline();
        endunless;
    enduntil;

    unless new_words = [] do
        Sort_vedspellfile(new_words)
    endunless;

    Apply_in_file(vedpositionpop, source_file);

    if ved_get_reply('Finished - quit this file now (y/n)? ', 'yn') = `y` then
        ved_rrq()
    else
        vedputcommand('respell');
        nullstring -> vedmessage
    endif

enddefine;


/* ved_spell
    Runs Unix 'spell program' using current file as input.
    Reads unrecognised words into VED file named by vedspelloutputfile.
    Then runs ved_respell defined above.
*/

define global ved_spell();
    lvars indev outdev status pid;
    lvars lo hi flags output;

    if vedargument = nullstring then
        [%  if vedspellbritish then '-b' endif,
            if sys_file_stat(vedspellfile, nullvector) then
                '+' <> vedspellfile
            endif
        %]
    else
        sysparse_string(vedargument)
    endif -> flags;

    if vvedmarklo > vvedmarkhi then
        1, vvedbuffersize
    else
        vvedmarklo, vvedmarkhi
    endif -> (lo, hi);

    run_unix_program('spell', flags, true, true, 1, false)
        -> pid -> status -> /* errdev */ -> outdev -> indev;

    vedputmessage('Running Unix spelling checker - please wait');

    vedwriterange(indev, lo, hi);               ;;; Send data to 'spell'
    sysclose(indev);

    define lconstant Cons_buffer(n);
        lvars n;
        if n then consvector(n) else vederror('Interrupted') endif
    enddefine;

    Cons_buffer(vedreadin(outdev)) -> output;   ;;; Read output from 'spell'
    sysclose(outdev);

    until syswait() == pid do                   ;;; Wait for 'spell' to die
        vedputmessage('Waiting for process ' sys_>< pid sys_>< ' to die')
    enduntil;
    vedputmessage('Done');

    define lconstant New_buffer(buffer);
        lvars buffer;
        buffer -> vedbuffer;
        vedusedsize(vedbuffer) -> vvedbuffersize;
        vedsetlinesize();
        ved_save_file_globals();
        vedrefresh();
    enddefine;

    define lconstant Prepare_for_respell();
        vedputcommand('respell');
        vedputmessage('Press REDO to start correcting spellings');
        vedscreenbell()
    enddefine;

    if output = {} then
        vedputmessage('No spelling mistakes detected')
    else
        vedinput(Prepare_for_respell);
        vedinput(New_buffer(% output %));
        vededitor(vedhelpdefaults, vedspelloutputfile)
    endif
enddefine;


endsection;
