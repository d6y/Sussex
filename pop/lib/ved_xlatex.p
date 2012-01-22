/*

    VED_XLATEX.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Tuesday 13 October 1992
    Updated: Thursday 18 February 1993

    To load from XVed:
        <ENTER> load ~richardd/pop/lib/ved_xlatex.p

    To use, type the following in your .tex ved window
        <ENTER> xlatex

    This will create a window with a few buttons in for doing
    latex-ish things.

    If your printer names are not three characters long and you don't use
    dvips the way we do at Sussex then don't use the "Queue" or "Print" option.

    Pressing the LaTeX button will run latex on your file.

    The-not-so-obvious ones:

    "Queue"         - look at the printer queue.

    "PostScript"    - print to a postscript file

    "GhostScript"   - invoke gspreview (this may not work, depending on
                      the users' path).

    Un-tick the "All pages" to edit the "Page numbers" range.


    NOTES
    =====

    There's no error checking, so if you do something like press "GhostScript"
    before you have created a .ps file with "PostScript", and error will
    appear in a window somewhere.

    Pressing any button will quit the /tmp/vdsh... window that is on the
    screen (if there ius one), i.e., the window with LaTeX's output in it.
    I like this, because it means you get into the bad habbit of pressing
    "LaTeX" and then "BiBTeX" and then "Xdvi" without looking at the log
    file (because you don't have to go into the window and quit it).

*/



uses ved_latex;
uses propsheet;
propsheet_init();

define ved_ghost;   ;;; Invoke GhostScript
    lvars
        dir = sys_fname_path(vedpathname),
        rootfile = dir dir_>< sys_fname_nam(vedpathname),
        psfile = rootfile sys_>< '.ps';

    sysobey('gspreview '><psfile><' &');
enddefine;


vars
    ved_xl_box,
    ved_xl_command_sheet,
    ved_xl_default_file,
    ved_xl_printer_list,
    ved_xl_pages_sheet,
    ved_xl_editable_files;

unless islist(ved_xl_editable_files) then
    [log aux bbl blg tex ps] -> ved_xl_editable_files;
endunless;

unless islist(ved_xl_printer_list) then
    [spb2 spb spb4 spa2 spa spa4] -> ved_xl_printer_list;
endunless;

define inform_of_dvips_options(string);
    string -> ved_xl_command_sheet('DviPS options');
enddefine;

;;; Quit the current window if it's a /tmp/vdsh* file
;;; Try to make the filename set in the "Filename:" field active
define ved_xl_quit_tmp;
    vars s;

    if length(vedvedname) > 8 then
        if substring(1,9,vedvedname) = '/tmp/vdsh' then
            ved_q();
            ;;;ved_xl_quit_tmp();
        endif;
    endif;

    ;;; Make sure we work with the correct .tex file
    ;;; Does this actually work?!
    if (vedpresent(ved_xl_command_sheet("File")) ->> s)==false
    then
        vederror('You are not editing that file');  ;;; not very useful
    else
        vedsetonscreen(s, false);
    endif;

enddefine;

;;; Pop-up the "Page Numbers Range" sheet
define ved_xl_all_pages(sheet, name, value) -> value;
    if value = true then
        propsheet_hide(ved_xl_pages_sheet);
    else
        propsheet_show(ved_xl_pages_sheet);
    endif;
enddefine;

define ved_xl_print(printer,options);
    lvars
        dir = sys_fname_path(vedpathname),
        rootfile = dir dir_>< sys_fname_nam(vedpathname);

    veddo('sh cd ' >< dir >< '; dvips -P' >< printer >< ' ' >< options >< ' '
        >< rootfile);

enddefine;

define ved_xl_new_print_defaults(sheet, name, value) -> value;
    ved_xl_command_sheet('DviPS options') ->ved_latex_pr_command;
enddefine;

define ved_xl_edit(sheet, name, value) -> value;
lvars
        dir = sys_fname_path(vedpathname),
        rootfile = dir dir_>< sys_fname_nam(vedpathname);

    edit( rootfile >< '.' >< hd(value));
propsheet_undef -> value;
enddefine;


define ved_xl_command(sheet, name, value) -> value;
    lvars
        print_options = '', ;;; Additional arguments to dvips
        printer,        ;;; The printer set in the "Printer" field
        old_printer,    ;;; printer in the user's $PRINTER
        old_commands,   ;;; the default ved_latex_pr_command
        orient,         ;;; Orientation (landscape or portrait)
        first_page,     ;;; First page to print and...
        last_page,      ;;; ...Last page if "all" is <false>
        all_pages;      ;;; "Print all pages" flag

    '' >< ved_xl_command_sheet("Printer") -> printer;

    ved_xl_command_sheet('All pages') -> all_pages;
    ved_xl_command_sheet("Orientation") -> orient;

    ved_latex_pr_command -> old_commands;

    if all_pages = false then
        ved_xl_pages_sheet('First page') -> first_page;
        ved_xl_pages_sheet('Last page') -> last_page;
        print_options >< ' -p ' ><first_page >< ' -l '><last_page -> print_options;
    endif;

    if orient = "landscape" then
        ved_latex_pr_command >< ' -t landscape ' -> ved_latex_pr_command;
    endif;


;;;    inform_of_dvips_options(ved_latex_pr_command);

    switchon name

    case = "LaTeX" then
        ved_xl_quit_tmp();
        veddo('latex');
    case = "XDvi" then
        ved_xl_quit_tmp();
        veddo('xdvi');
    case = "BibTeX" then
        ved_xl_quit_tmp();
        veddo('bibtex')
    case = "Clear" then
        ved_xl_quit_tmp();
        veddo('latex clear');
    case = "Print" then
        ved_xl_quit_tmp();
        ved_xl_print(printer,print_options);
    case = "PostScript" then
        ved_xl_quit_tmp();
        veddo('latex print ps');
    case = "GhostScript" then
        ved_xl_quit_tmp();
        veddo('ghost');
    case = "Queue" then
        veddo('sh lpq -P'><substring(1,3,printer));

    endswitchon;


    old_commands -> ved_latex_pr_command;
;;;    inform_of_dvips_options(ved_latex_pr_command);

enddefine;

define ved_xlatex;

    if vedargument = '' then
        vedvedname -> ved_xl_default_file;
    else
        vedargument -> ved_xl_default_file;
    endif;

    propsheet_new_box('LaTeX Buttons', false, false, false) -> ved_xl_box;

    propsheet_new('', ved_xl_box, [
            [File       ^ved_xl_default_file]

            [Edit someof ^ved_xl_editable_files
            (accepter=ved_xl_edit,nodefault,allowNone)]

            [LaTeX      command  (nolabel,accepter=ved_xl_command)]
            + [BibTeX     command  (nolabel,accepter=ved_xl_command)]
            + [Clear      command  (nolabel,accepter=ved_xl_command)]

            [PostScript command  (nolabel,accepter=ved_xl_command)]
            + [Print      command  (nolabel,accepter=ved_xl_command)]
            + [Queue      command  (nolabel,accepter=ved_xl_command)]


            [GhostScript command (nolabel,accepter=ved_xl_command)]
            + [XDvi       command  (nolabel,accepter=ved_xl_command)]

            [Printer    oneof ^ved_xl_printer_list (nolabel)]

            ['All pages' true (accepter=ved_xl_all_pages)]
            + [Orientation oneof [portrait landscape] (nolabel)]

;;;            ['DviPS options' '' (accepter=ved_xl_new_print_defaults)]


    ]) -> ved_xl_command_sheet;


    propsheet_new('Select Pages', ved_xl_box, [
            ['First page' 1 (width=15)]
            + ['Last page' 999 (width=15)]
        ]) -> ved_xl_pages_sheet;

    propsheet_show([% ved_xl_command_sheet, ved_xl_box %]);

;;;    inform_of_dvips_options(ved_latex_pr_command);

enddefine;
