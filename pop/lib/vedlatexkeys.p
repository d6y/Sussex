/*

    VEDLATEXKEYS.P

    Richard Dallaway, with advice from Teresa Del Soldato.
    richardd@cogs.susx.ac.uk, June 1992.

    Friday 24 July 1992 (Last Update)

    Defines a number of key sequences for typing LaTeX commands.
    Uses VED_LATEX for some environments (and bits of code from
    VED_LATEX for LaTeX macros).

    SUMMARY
    =======

    CTRL-e for environments (inserted at the cursor)
    CTRL-r for environments (inserted around the marked range)
    CTRL-l for LaTeX macros (commands)


    Press one of these control sequences and then start typing the name
    of the macro/environment.  vedlatekeys will complete the name (and
    add LaTeX things like {}s, begin and \s) as soon as the name is
    unambiguous.

    ESC-b for {\bf } (just does <ENTER> latex bold word, plus charright)
    ESC-i for {\em } (just does <ENTER> latex italic word, plus charright)

    <ENTER> maketitle
    Inserts \author, \title and \date.  Also inserts \address and \email, but
    comments them out because few styles currently use them.

    INTRODUCTION
    ============

    To load, place the following line into your vedinit.p file:

            load ~richardd/pop/lib/vedlatexkeys.p

    or type the above on the VED command line.



    This file defines a keyword completion procedure for LaTeX commands.
    For example, to get \begin{center} ... \end{center} you type "CTRL-ec"
    (that is, hold the CONTROL key and press "e", then let go of the
    control key and press "c").

    Other environment names require more key presses.  You need to type
    "CTRL-equota" to get \begin{quotation}...\end{quotation} or
    "CTRL-equote" to get \begin{quote} ... \end{quote}

    LaTeX commands (like \item or \vspace{}) can be accessed through
    "CTRL-l".  Once pressed, VED will put the message "Start typing
    name of command" on the command line.  A _ cursor mark will appear
    in the file.  You may now start typing the name of the command.
    As soon as enough characters have been typed to disambiguate
    the command name, the name will be inserted into the file, along with
    an necessary curly brackets and "\"s.  If you mistype a character
    you may delete it, or press RETURN to abort the completion process.

    LaTeX environments are completed after "CTRL-E" has been typed.
    The \begin and \end are placed around the marked range if "CTRL-R"
    is used instead of "CTRL-E".

    ESC-b (press the ESCAPE key, let go and then press b) can be used for
    bold text.  I.e., it inserts {\bf } and moves the cursor into the
    {}s.  ESC-i does the same for emphasis (italics).

    CUSTOMIZATION
    =============

    Changes to variables must be done BEFORE loading vedlatexkeys.p

    The following variables determine which key sequences invoke
    the name-completion procedures.  The user may change them by
    adding the following kind of line to his/her vedinit.p file:

        ;;; makes ESC-t the LaTeX command key.
        vars vedlatexkey_command = '\^[t';

    See HELP * VEDSETKEY for details.

      vedlatexkey_command               [default CTRL l]
      For commands like \item or \maketitle{}

      vedlatekey_environment            [default CTRL e]
      For \begin{..} \end{..} environments.

      vedlatexkey_environment_mr        [default CTRL r]
      As above, but places the \begin{..} and \end{..} around the
      marked range.  See HELP * VED_LATEX/block <type> <scope>

      vedlatexkey_bold          {\bf }  [default ESC b]
      vedlatexkey_em            {\em }  [default ESC i]


    To add new environments/macros, set the following lists in your
    vedinit.p file.  Examples:

    To produce: \begin{mytheorem} ... \end{mytheorem}
        [mytheorem] -> latex_environments;

    For commands \entry and \notice which behave like \item, do...
        [entry notice] -> latex_commands_without_arguments;

    Other kinds of commands that use arguments (like \section)...
        [mysection] -> latex_commands_with_arguments;

    Some environments, like slide and tabular, require arguments.
    If the environments you add need an argument be sure to place
    their names in this list "latex_environments_with_arguments".

    By default, vedlatexkeys inserts the first \item for enumerate and
    itemize.  If any environments you define require this, add their names
    to the list "latex_environments_with_items".

    You may change the values of the string vedmaketitle_address and
    vedmaketitle_emailhost if you don't like the defaults used by <ENTER> maketitle.
    The default settings are:

        'School of Cognitive \\& Computing Sciences\\\\University of\
    Sussex\\\\Brighton BN1 9QH, UK' -> vedmaketitle_address;

    '@cogs.susx.ac.uk' -> vedmaketitle_emailhost;

    Note that <ENTER> maketitle automatically inserts your username at the start of
    your email address.


    RELATED DOCUMENTATION
    =====================

    HELP * LATEX
    HELP * VED_LATEX


    REVISION HISTORY
    ================

    Bug fix [bf 1] Thursday 25 June 1992.  Reported by teresa@cogs.
    -vlk_getname- wasn't checking the length of the words in the variable
    WORDS before trying to access substrings within the words.  The result
    was a range exceeded mishap for words shorted that the typed sequence.
    FIXED.

    Update [up 1] Monday 6 July 1992.  Requested that the \address and \email
    be inserted by ved_maketitle.  Decided to insert them commented out
    (because many styles do not use \address or \email.

    Update [up 2] Friday 24 July 1992.  Changed the procedures associated with
    key presses from closures to procedure...endprocedure code.  This allows
    the user to change any of the global lists after vedlatexkeys has loaded.

    Update [up 3] Friday 24 July 1992.  Added the varaible vedlatexkeys and
    set it to <true> at the end of the file, so that -uses- knows when
    vedlatexkeys has been loaded.

------------------------------------------------------------------------------*/

uses ved_latex;

;;; User assignable lists
vars
    latex_environments,
    latex_commands_with_arguments,
    latex_commands_without_arguments,
    latex_environments_with_items,
    latex_environments_with_arguments;

;;; User assignable key sequences (strings)
vars
    vedlatexkey_command,
    vedlatekey_environment,
    vedlatexkey_environment_mr,
    vedlatexkey_bold,
    vedlatexkey_em,
    latex_generic_command;

;;; [up 1]
vars vedmaketitle_address,          ;;; Address used by ved_maketitle
     vedmaketitle_emailhost;        ;;; part of email address after username.



;;; Default (minimum) LaTeX macro and environment names

vars vlk_envs_items = [enumerate itemize];

vars vlk_envs_arg = [slide tabular];

vars vlk_envs =
[    abstract alltt array
     center
     description document
     enumerate equation eqnarray
     figure flushleft flushright
     itemize
     letter
     picture
     table tabbing tabular thebibliography titlepage
     minipage
     quote quotation
     slide
     verse verbatim ];

vars vlk_cmds = [
   author address
   bibliography bibliographystyle
   chapter caption cite closing
   documentstyle date
   footnote fbox
   hspace
   input include
   label
   maketitle
   opening
   paragraph psfig pagestyle
   ref
   section subsection subsubsection signature
   thanks thispagestyle title
   vspace
];

vars vlk_cmds_noargs = [
   item
   large Large LARGE
   normalsize noindent
   pounds pagebreak
   raggedright
   small
];


/*
    Reads the users key presses and tries to find a match to either
    a LaTeX environment or LaTeX command (macro).

    "Scope" is either "line" or "range" for use with inserting blocks
    (environment names) around the current "line" or the marked "range".

    "Type" is reither "environment" or "command", depending on which type
    of LaTeX structure is being inserted into the document.

    "Words" is a list: either of environments or macro names.

    KNOWN BUGS:
    ===========

    Not sure what will happen if we added "includeonly" to the
    list of LaTeX macros.  The problem is that "include" is already
    in the list.  Hence, if the user type "CTRL-l include", to get
    "\include{}", the program will wait for more text before
    it can disambiguate "include" from "includeonly".

*/

define vlk_getname(scope,type,words);
    lvars
        char,           ;;; The character typed by the user
        pos = 1,        ;;; Number of characters typed
        nmatches;       ;;; Number of words in WORDS that match the sequence typed

    vars
        blocks,         ;;; The list of words that match the sequence typed so far
        b,              ;;; Accesses elements in BLOCKS
        string='',      ;;; A string for the characters typed so far
        word;           ;;; The one word that is selected

    vedputmessage('Start typing name of '><type);
    vedinsertstring('_');           ;;; Cursor mark

    repeat  ;;; until unique word found, or no words match.

        vedinascii() -> char;

        if char==`\n` or char==`\r` then    ;;; abort
            ;;; Remove typed characters from the screen
            repeat pos times vedchardelete(); endrepeat;
            quitloop;
        endif;

        if char==127 and string /= '' then   ;;; delete
            vedchardelete(); vedchardelete(); vedinsertstring(`_`,1);
            pos fi_- 1 -> pos;
            substring(1,pos-1,string) -> string;

        else

            vedchardelete();                ;;; Remove the "cursor" mark
            vedinsertstring(char,`_`,2);    ;;; Insert the character and the cursor
            string >< consstring(char,1) -> string;

            ;;; Find possible words
            [% fast_for b in words do
                    unless length(b) < pos then     ;;; [bf 1]
                        if substring(1,pos,b) = string then
                            b;  ;;; Candidate word left on stack and collected into BLOCKS
                        endif;
                    endunless;
                endfast_for; %] -> blocks;

            pos fi_+1 -> pos;   ;;; Ready for next character

            length(blocks) -> nmatches;

            if nmatches==0 then     ;;; No matching words
                repeat pos times vedchardelete(); endrepeat;
                vederror('Can\'t complete that '><type);
                quitloop;
            endif;

            if nmatches==1 then     ;;; one unique match
                repeat pos times vedchardelete(); endrepeat;

                ;;; BLOCKS is a list, so extract the matching word from the list.
                hd(blocks) -> word;

                if type = "environment" then
                    ;;; Links to Aaroon's VED_LATEX code
                    veddo('latex block '><word><' '><scope);

                    if scope == "line" then
                        vedchardown();
                        ;;; Insert \item for some environments (but not
                        ;;; if inserted around the marked range)
                        if member(word,vlk_envs_items) then
                            vedinsertstring('\\item ');
                        endif;
                    endif;

                    ;;; Some environments (like tabular) require arguments
                    if member(word,vlk_envs_arg) then
                        if scope = "line" then
                            vednextline(); vedcharleft(); vedcharleft();
                            vedinsertstring('{}');
                            vedcharleft();
                        else
                            vedmarkfind(); vednextsentend(); vedcharright();
                            vedinsertstring('{}');  vedcharleft();
                        endif;
                    endif;

                elseif type = "command" then
                    unless member(word,vlk_cmds_noargs) then
                        ;;; macros with arguments
                        latex_generic_command(word);
                        vedcharright();
                    else    ;;; macros without arguments
                        vedinsertstring('\\'><word><' ');
                    endunless;
                endif;

                quitloop;
            endif;
        endif;
    endrepeat;
    vedputmessage('DONE');
enddefine;


/*
-- <ENTER> maketitle
*/


define ved_maketitle;
    vars author;
    unless sysgetusername(popusername) ->> author then
        vederror('Real name not found')
    endunless;
    vedinsertstring('\\author{'><author><'}\n');
    vedinsertstring('\\title{As Yet Untitled}\n');
    vedinsertstring('\\date{\\today}\n');
    ;;; [up 1]
    vedmarkpush(); vedmarklo();
    vedinsertstring('\\address{'><vedmaketitle_address><'}\n');
    vedinsertstring('\\email{'><popusername><vedmaketitle_emailhost><'}\n');
    vedcharup(); vedmarkhi(); veddo('gsr/@a/%'); vedmarkpop();
    vedchardown();
    vedinsertstring('\\maketitle\n');
enddefine;


define global latex_generic_command(name);
    dlocal vedbreak = false;            ;;; Stop automatic line breaking for a moment
    vedinsertstring('\\'><name><'{}');  ;;; Insert command with argument brackets
    vedcharleft(); vedcharleft();       ;;; Move cursor into the brackets
enddefine;


/*-- Add user's extensions to lists of commands/environments --*/

unless islist(latex_environments) then
    [] -> latex_environments;
endunless;

unless islist(latex_commands_with_arguments) then
    [] -> latex_commands_with_arguments;
endunless;

unless islist(latex_commands_without_arguments) then
    [] -> latex_commands_without_arguments;
endunless;

unless islist(latex_environments_with_items) then
    [] -> latex_environments_with_items;
endunless;

unless islist(latex_environments_with_arguments) then
    [] -> latex_environments_with_arguments;
endunless;

latex_commands_without_arguments <> vlk_cmds_noargs -> vlk_cmds_noargs;
vlk_cmds <> vlk_cmds_noargs -> vlk_cmds;
vlk_cmds <> latex_commands_with_arguments -> vlk_cmds;
latex_environments_with_arguments <> vlk_envs_arg -> vlk_envs_arg;
latex_environments_with_items <> vlk_envs_items -> vlk_envs_items;
latex_environments <> vlk_envs -> vlk_envs;


;;; [up 1]
unless isstring(vedmaketitle_address) then
    'School of Cognitive \\& Computing Sciences\\\\University of\
Sussex\\\\Brighton BN1 9QH, UK' -> vedmaketitle_address;
endunless;

unless isstring(vedmaketitle_emailhost) then
    '@cogs.susx.ac.uk' -> vedmaketitle_emailhost;
endunless;


/*-- SET KEY SEQUENCES --*/

;;; Default key sequences

unless isstring(vedlatexkey_command) then
    '\^l' -> vedlatexkey_command;
endunless;

unless isstring(vedlatekey_environment) then
    '\^E' -> vedlatekey_environment;
endunless;

unless isstring(vedlatexkey_environment_mr) then
    '\^R' -> vedlatexkey_environment_mr;
endunless;

;;; [up 2]
;;; vedsetkey(vedlatexkey_command,
;;;     vlk_getname(%"none","command",vlk_cmds%) );
vedsetkey(vedlatexkey_command, procedure();
    vlk_getname("none","command",vlk_cmds); endprocedure );

;;; [up 2]
;;; vedsetkey(vedlatekey_environment,
;;;     vlk_getname(%"line","environment",vlk_envs%));
vedsetkey(vedlatekey_environment, procedure();
    vlk_getname("line","environment",vlk_envs) endprocedure);

;;; [up 2]
;;; vedsetkey(vedlatexkey_environment_mr,
;;;     vlk_getname(%"range","environment",vlk_envs%));
vedsetkey(vedlatexkey_environment_mr, procedure();
     vlk_getname("range","environment",vlk_envs); endprocedure);

unless isstring(vedlatexkey_bold) then
    '\^[b' -> vedlatexkey_bold;
endunless;

vedsetkey(vedlatexkey_bold, procedure;
    veddo('latex bold word'); vedcharright(); endprocedure);

unless isstring(vedlatexkey_em) then
    '\^[i' -> vedlatexkey_em;
endunless;

vedsetkey(vedlatexkey_em, procedure;
    veddo('latex italic word'); vedcharright(); endprocedure);

;;; [up 3]
vars vedlatexkeys = true;
