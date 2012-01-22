;;; @(#)vedinit.p 1.1 89/06/23 COGS

unless trycompile('/usr/local/global/vedinit.p') then
    pr('Warning: could not compile global vedinit.p\n');
endunless;

` ` -> vedscreentrailspacemark;

trycompile('$GROUP/vedinit.p') ->;

vars vedtexdocname = 'latex.tex';

vars ved_texdoc = vedsysfile(%"vedtexdocname",
    ['/usr/local/lib/tex/inputs' '/usr/local/lib/tex/doc/latex'
    '/usr/local/lib/tex/doc/bibtex' '/usr/local/lib/tex/doc/misc'
    '/usr/local/lib/tex/doc/dvips' '/usr/local/lib/tex/doc/mainz'
    '/csuna/home/richardd/tex/inputs'],
    false%);

35/2 -> vedwiggletimes;

;;;uses ved_autosave;
;;;15 -> vedautosave_minutes;
;;;false  -> vedautosave_preserve

2 -> pop_file_versions;

[^^vedfiletypes
    ['output.p' {vedwriteable false}]
    [ [^(hassubstring(%'/help/'%)) ^(hassubstring(%'/ref/'%))
            ^(hassubstring(%'/doc/'%)) ^(hassubstring(%'/teach/'%))
      ] {vedlinemax 72} {vednotabs true}]
]  -> vedfiletypes;

1024  -> vedautowrite;

uses vedesckeys;

false -> vednotabs;
true -> vedreadintabs;

define vedinit;
    true -> vedreadintabs;
    false -> vednotabs;
    75 -> vedlinemax;
enddefine;

define ved_dontwrite;
    false -> vedwriteable;
enddefine;

define ved_dowrite;
    true -> vedwriteable;
enddefine;

vars ved_sqa = veddo(%'lpr -Psqa -h'%);
vars ved_sqamr = veddo(%'lprmr -Psqa -h'%);

;;; done in .xrdb file
;;;#_IF vedusewindows == "x"
;;;true -> xved_value("application", "Vanilla");
;;;#_ENDIF
