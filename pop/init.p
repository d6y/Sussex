;;; @(#)init.p 1.1 89/06/23 COGS

trycompile('/usr/local/global/init.p') ->;
trycompile('$GROUP/init.p') ->;

;;; pick up $PRINTER
vars popprinter = systranslate('$POPPRINTER');
if popprinter = false then
    systranslate('$PRINTER') -> popprinter;
endif;

false -> vedscrollscreen;

/*-- Search paths --*/

'~richardd/pop/lib' :: popliblist -> popliblist;
'~richardd/pop/lib' :: popuseslist -> popuseslist;
'~richardd/pop/help' :: vedhelplist -> vedhelplist;
['$HOME' '$HOME/mail' '$poplib'] -> vedsearchlist;


/*-- for david's version of popneural --*/
;;;'~davidy/poplib' :: popuseslist -> popuseslist;
constant pdp_precision = "double";
'$HOME/pop/neural/utils' :: popuseslist -> popuseslist;

uses vedloadline;
`^` -> vedexpandchar;
vedcurrentchar -> vedexpandchars(`c`);

;;; From adrianh to fix xved-not-getting-bindings problem
;;; Fixed Monday 17 August 1992
;;;lib vedsunxvedkeys;
;;;global vars vedserverxvedkeys = vedsunxvedkeys;

;;; NO CONTROL PANEL UNDER X - HELP * POP_UI
vars poplog_ui_enabled = false;

true -> pop_pr_quotes;
false -> pop_pr_quotes;

define pop_file_write_error(DEV);
    pr('\n-- Responding to file write error.');
    pr('\n   Device: '><DEV);
    pr('\n   Message: '><(sysiomessage()));
    pr('\n\n');
;;;    pr('\n   Deleting file.\n\n');
;;;    sysdelete(device_full_name(DEV));
enddefine;

define macro ls ; sysobey('ls'); enddefine;

vars init_loaded = true;
