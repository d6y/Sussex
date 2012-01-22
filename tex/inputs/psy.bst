% File: psy.bst (works with theapa.sty, v2.5 or psy.sty)
% Version: 1.1 (October 1992)
% Richard Dallaway <richardd@cogs.susx.ac.uk>
%
% Changes to version 1.1
% - included bug fix to @technicalreport from theapa v.2.5.1
%
% psy.bst evolved by tinkering with...
% theapa.bst $$$ --- Version 2.5 (April 1992)
%    Young U. Ryu (young@emx.utexas.edu)
% copyright (C) 1991, 1992.
%    Young U. Ryu
% newapa.bst 2.0 - 1991.
%    Young U. Ryu
% newapa.bst - copyright (C) 1989, 1990.
%    Stephen N. Spencer
% apalike.bst - copyright (C) 1986, 1988.
%    Susan King and Oren Patashnik
% alpha.bst - copyright (C) 1985.
%    Oren Patashnik

% Changes from theapa.bst version 2.5
% Search for "rzd"
%
% 1. (Bug fix) The definition of format.tr.number was changing the case of
% something  when there was no report number.  This was causing \BTR to be
% changed to \btr, which, being undefined, caused a LaTeX error message. The
% offending function has been replaced with a skip$
%
% 2. A new function has been added called "match.surnames".  It attempts
% to find authors with the same surnames, but different initials, and
% then include the initials as part of the \cite label (rather than
% simply adding a letter to the date).
% Contains many holes.  Should really use the initials for ANY two
% different authors with the same surname, but at the moment it just
% checks the first author.
%
% 3. For authors which were automatically "et al-ified", theapa.bst would
% add a letter to the date if there were more than one "Author et al"
% being \cite'd.  However, this causes a problem because
% Smith, Jones, Brown (1991) and Smith, Taylor, Brown (1991) were
% shortcite'd as "Smith et al (1991a)" and "Smith et al (1991b)"
% and the references also contained the letter after the date, which
% looks wrong.  The function same.surnames (called as part of
% match.surnames) now removes the shortcite option in the above case.
%
%
% 4. In references like: Smith, Jones, & Blogs
% you don't really need the "," after the last surname before the "&"
% (Jones, in this case).  So I've removed it.
%
% 5. Moved \protect\BCAY{ to output.bibitem to save string space
%
% 6. Removed final "." from edition comments (they are followed by ,s)
%

% Version 2.5 Update Notes (April 1992)
%
%    - \BUcase is dropped. It means that BibTeX always
%      changes cases of article titles.
%    - If you don't want to change cases of article titles,
%      see comments following `FUNCTION {format.title}'.
%    - See update notes in `theapa.sty'.

% Version 2.4 Update Notes (April 1992)
%
%    - See update notes in `theapa.sty'.

% Version 2.3 Update Notes (March 1992)
%    - See update notes in `theapa.sty'.

% Version 2.2 Update Notes (March 1992)
%
%    - A bug reported by Richard Dallaway <richardd@cogs.sussex.ac.uk>:
%
%             two periods after the title of MISC entries
%             (also two periods after the title of BOOKLET entries)
%
%      is fixed by adding a function {output.atitle} and modifying
%      functions {booklet} and {misc}.
%    - A bug reported by someone (Sorry, I lost his/her E-mail.):
%
%             incorrect order of references, e.x.
%               Bond K. \&\ Scott L.
%               Bond P. \&\ Scott L.
%               Bond K. \&\ Wright O. % This line must come before the above
%
%      is fixed by switching first two lines of the function {presort}.
%    - The function {unpublished} is changed to avoid potential errors.

% Version 2.1 Update Notes
%    - See update notes in `theapa.sty'.

% Tutorial Notes
%    - See tutorial notes in `theapa.sty'.

% Copying of this file is authorized only if either
% (1) you make absolutely no changes to your copy, including names, or
% (2) if you do make changes, you name it something other than
% btxbst.doc, plain.bst, unsrt.bst, alpha.bst, and abbrv.bst.
% This restriction helps ensure that all standard styles are identical.

% Requirements: BibTeX 0.99a (or higher?),
%               theapa.sty 2.4 under LaTeX 2.09 (or higher?)
%
%  NO GUARANTEE, absolutely (You know what I mean.)!!!

ENTRY
  { address
    author
    booktitle
    chapter
    edition
    editor
    howpublished
    institution
    journal
    key
    month
    note
    number
    organization
    pages
    publisher
    school
    series
    title
    type
    volume
    year
  }
  {}
  { label extra.label sort.label date.label }

INTEGERS { output.state before.all mid.sentence after.sentence after.block }

FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
}

STRINGS { s t }

FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { ", " * write$ }
    { output.state after.block =
        { add.period$ write$
          newline$
          "\newblock " write$
        }
        { output.state before.all =
            'write$
            { add.period$ " " * write$ }
          if$
        }
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output.atitle.nonnull}
{ 's :=
  output.state mid.sentence =
    { "\ " * write$ }
    { output.state after.block =
        { "\ " * write$
          newline$
          "\newblock " write$
        }
        { output.state before.all =
            'write$
            { "\ " * write$ }
          if$
        }
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {output.atitle}
{ duplicate$ empty$
    'pop$
    'output.atitle.nonnull
  if$
}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}

FUNCTION {output.atitle.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.atitle.nonnull
  if$
}

FUNCTION {output.year.check}
{ year empty$
     { "empty year in " cite$ * warning$ }
     { write$
        " \BBOP" year * extra.label * "\BBCP" *
        mid.sentence 'output.state :=
     }
  if$
}

FUNCTION {output.bibitem}
{ newline$
  "\bibitem[\protect\BCAY{" write$
  label write$
  "]{" write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}

FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
        'skip$
        { after.sentence 'output.state := }
      if$
    }
  if$
}

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}


FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}

FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "{\Bem " swap$ * "}" * }
  if$
}

FUNCTION {emphasize.space}
{ duplicate$ empty$
    { pop$ "" }
    { "{\Bem " swap$ * "\/}" * }
  if$
}

INTEGERS { nameptr namesleft numnames }

FUNCTION {push.author}
{
    author empty$  % The surname will be either author or
        { editor } % editor, but we prefer author.
        { author }
    if$
}

% Leave a string on stack, containing all authors (except the first)
% along with the appropriate "&" or "and"  if needed.

FUNCTION {other.authors}
{ push.author 's :=
  s num.names$ 'numnames :=
  #2 'nameptr :=
  numnames #1 - 'namesleft :=
  numnames #1 >
    { "" { namesleft #0 > }
                { namesleft #1 =
                    { " \B\ " }
                    { ", " }
                  if$
                s nameptr "{}{vv~}{ll}{, jj}" format.name$ * *
                namesleft #1 - 'namesleft :=
                nameptr #1 + 'nameptr :=
       } while$
    }
    { "" } % If one author, just leave something on the stack.
  if$
}

FUNCTION {format.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{vv~}{ll}{, jj}{, F.}" format.name$ 't :=
      nameptr #1 >
        { namesleft #1 >
            { ", " * t * }
        { numnames #2 >
                { "\ " * }     % was ",", but you don't need a comma
        { "\BBACOMMA\ " * }    % for the author before the "&"
              if$
              t "others" =
                { " et~al." * }
                { "\B\ " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.names }
  if$
}

FUNCTION {format.editors}
{ editor empty$
    { "" }
    { editor format.names
      editor num.names$ #1 >
        { "\BEDS" * }
        { "\BED" * }
      if$
    }
  if$
}

FUNCTION {format.editors.dot}
{ editor empty$
    { "" }
    { editor format.names
      editor num.names$ #1 >
    { "\BEDS." * }
    { "\BED." * }
      if$
    }
  if$
}

FUNCTION {format.key}
{ empty$
    { key field.or.null }
    { "" }
  if$
}

FUNCTION {format.title}
{ title empty$
    { "" }
    { "\BBOQ " title "t" change.case$ * "\BBCQ" *}
  if$
}

% If you don't want to change cases of article titles,
% use the following `format.title' function instead the one.

%FUNCTION {format.title}
%{ title empty$
%    { "" }
%    { "\BBOQ " title * "\BBCQ" *}
%  if$
%}

FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
        { t #1 #2 substring$ "--" = not
            { "--" *
              t #2 global.max$ substring$ 't :=
            }
            {   { t #1 #1 substring$ "-" = }
                { "-" *
                  t #2 global.max$ substring$ 't :=
                }
              while$
            }
          if$
        }
        { t #1 #1 substring$ *
          t #2 global.max$ substring$ 't :=
        }
      if$
    }
  while$
}

FUNCTION {format.btitle}
{ edition empty$
  { title emphasize }
  { title empty$
    { title emphasize }
%    { "{\Bem " title * "\/} (" * edition * " \BEd)" * "." * }
% RZD - removed final "."
    { "{\Bem " title * "\/} (" * edition * " \BEd)" * }
    if$
  }
  if$
}

FUNCTION {format.emphasize.booktitle}
{ edition empty$
  { booktitle emphasize }
  { booktitle empty$
    { booktitle emphasize }
%    { "{\Bem " booktitle * "\/} (" * edition * " \BEd)" * "." * }
% RZD - removed final "."
    { "{\Bem " booktitle * "\/} (" * edition * " \BEd)" * }
    if$
  }
  if$
}

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { "\ " }
  if$
  swap$ * *
}

FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

FUNCTION {format.bvolume}
{ volume empty$
    { "" }
    { "\lowercase{\BVOL}" volume tie.or.space.connect
      series empty$
        'skip$
        { " of " * series emphasize * }
      if$
      "\losercase{\BVOL\ and \BNUM}" number either.or.check
    }
  if$
}

FUNCTION {format.number.series}
{ volume empty$
    { number empty$
        { series field.or.null }
        { output.state mid.sentence =
            { "\lowercase{\BNUM}" }
            { "\BNUM" }
          if$
          number tie.or.space.connect
          series empty$
            { "there's a number but no series in " cite$ * warning$ }
            { " in " * series * }
          if$
        }
      if$
    }
    { "" }
  if$
}

FUNCTION {format.edition}
{ edition empty$
    { "" }
    { output.state mid.sentence =
        { edition "l" change.case$ " \BEd" * }
        { edition "t" change.case$ " \BEd" * }
      if$
    }
  if$
}

INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
        { #1 'multiresult := }
        { t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}

FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
        { "\BPGS" pages n.dashify tie.or.space.connect }
        { "\BPG" pages tie.or.space.connect }
      if$
    }
  if$
}

FUNCTION {format.vol.num.pages}
{ number empty$
    { volume empty$
       'skip$
       { "{\Bem " volume * "}" * }
      if$
    }
    { volume emphasize.space
      volume empty$
       {"there's a number but no volume in " cite$ * warning$ }
       { "(" number * ")" * * }
      if$
    }
  if$
  pages empty$
    'skip$
    { duplicate$ empty$
      { pop$ format.pages }
      { ", " * pages n.dashify * }
      if$
    }
  if$
}

FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
        { "\BCH" }
        { type "l" change.case$ }
      if$
      chapter tie.or.space.connect
      pages empty$
        'skip$
        { ", " * format.pages * }
      if$
    }
  if$
}

FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { editor empty$
        { "In " format.emphasize.booktitle * }
        { "In " format.editors * ", " * format.emphasize.booktitle * }
      if$
    }
  if$
}

FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and
  key empty$ not and
    { "all relevant fields are empty in " cite$ * warning$ }
    'skip$
  if$
}

FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      type "t" change.case$
    }
  if$
}

% FUNCTION {format.tr.number}
% { type empty$
%     { "\BTR" }
%     'type
%   if$
%   number empty$
%     'skip$
% %    { "t" change.case$ } % rzd: what are we changing the case of?
%     { number tie.or.space.connect}
%   if$
% }


FUNCTION {format.tr.number}
{ type empty$
    { "\BTR" }
    { type "t" change.case$ }
  if$
  number empty$
    'skip$
    { number tie.or.space.connect }
  if$
}

FUNCTION {format.article.crossref}
{ key empty$
    { journal empty$
        { "need key or journal for " cite$ * " to crossref " * crossref *
          warning$
          ""
        }
        { "In {\Bem " journal * "\/}" * }
      if$
    }
    { "In " key * }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {format.crossref.editor}
{ editor #1 "{vv~}{ll}" format.name$
  editor num.names$ duplicate$
  #2 >
    { pop$ " et~al." * }
    { #2 <
        'skip$
        { editor #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
            { " et~al." * }
            { "\BBACOMMA\ \B\ " * editor #2 "{vv~}{ll}" format.name$ * }
          if$
        }
      if$
    }
  if$
}

FUNCTION {format.book.crossref}
{ volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$
      "In "
    }
    { "\BVOL" volume tie.or.space.connect
      " of " *
    }
  if$
  editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
        { series empty$
            { "need editor, key, or series for " cite$ * " to crossref " *
              crossref * warning$
              "" *
            }
            { "{\Bem " * series * "\/}" * }
          if$
        }
        { key * }
      if$
    }
    { format.crossref.editor * }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {format.incoll.inproc.crossref}
{ editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
        { booktitle empty$
            { "need editor, key, or booktitle for " cite$ * " to crossref " *
              crossref * warning$
              ""
            }
            { "In {\Bem " booktitle * "\/}" * }
          if$
        }
        { "In " key * }
      if$
    }
    { "In " format.crossref.editor * }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {article}
{ output.bibitem
  format.authors "author" output.check
  author format.key output
  output.year.check
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { journal emphasize "journal" output.atitle.check
      format.vol.num.pages output
    }
    { format.article.crossref output.atitle.nonnull
      format.pages output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {book}
{ output.bibitem
  author empty$
    { format.editors.dot "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
        { "author and editor" editor either.or.check }
        'skip$
      if$
    }
  if$
  output.year.check
  new.block
  format.btitle "title" output.check
  crossref missing$
    { format.bvolume output
      new.block
      format.number.series output
      new.sentence
      publisher "publisher" output.check
      address output
    }
    { new.block
      format.book.crossref output.nonnull
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {booklet}
{ output.bibitem
  format.authors output
  author format.key output
  output.year.check
  new.block
  format.btitle "title" output.check
  howpublished address new.block.checkb
  howpublished output
  address output
  new.block
  note output
  fin.entry
}

FUNCTION {inbook}
{ output.bibitem
  author empty$
    { format.editors.dot "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
        { "author and editor" editor either.or.check }
        'skip$
      if$
    }
  if$
  output.year.check
  new.block
  format.btitle "title" output.check
  crossref missing$
    { format.bvolume output
      format.chapter.pages "chapter and pages" output.check
      new.block
      format.number.series output
      new.sentence
      publisher "publisher" output.check
      address output
    }
    { format.chapter.pages "chapter and pages" output.check
      new.block
      format.book.crossref output.nonnull
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {incollection}
{ output.bibitem
  format.authors "author" output.check
  author format.key output
  output.year.check
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.atitle.check
      format.bvolume output
      format.number.series output
      format.chapter.pages output
      new.sentence
      publisher "publisher" output.check
      address output
    }
    { format.incoll.inproc.crossref output.atitle.nonnull
      format.chapter.pages output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {inproceedings}
{ output.bibitem
  format.authors "author" output.check
  author format.key output
  output.year.check
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.atitle.check
      format.bvolume output
      format.number.series output
      format.pages output
      address empty$
        { organization publisher new.sentence.checkb
          organization output
          publisher output
        }
        { address output.atitle.nonnull
          new.sentence
          organization output
          publisher output
        }
      if$
    }
    { format.incoll.inproc.crossref output.nonnull
      format.pages output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {conference} { inproceedings }

FUNCTION {mastersthesis}
{ output.bibitem
  format.authors "author" output.check
  author format.key output
  output.year.check
  new.block
  format.title "title" output.check
  new.block
  "Master's thesis" format.thesis.type output.atitle.nonnull
  school "school" output.check
  address output
  new.block
  note output
  fin.entry
}


FUNCTION {manual}
{ output.bibitem
  author empty$
    { organization empty$
        'skip$
        { organization output.nonnull
          address output
        }
      if$
    }
    { format.authors output.nonnull }
  if$
  output.year.check
  new.block
  format.btitle "title" output.check
  author empty$
    { organization empty$
        { address new.block.checka
          address output
        }
        'skip$
      if$
    }
    { organization address new.block.checkb
      organization output
      address output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {misc}
{ output.bibitem
  format.authors output
  author format.key output
  output.year.check
  title howpublished new.block.checkb
  format.title "title" output.check
  howpublished new.block.checka
  howpublished output.atitle
  new.block
  note output
  fin.entry
  empty.misc.check
}

FUNCTION {phdthesis}
{ output.bibitem
  format.authors "author" output.check
  author format.key output
  output.year.check
  new.block
  format.btitle "title" output.check
  new.block
  "Ph.D.\ thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  new.block
  note output
  fin.entry
}

FUNCTION {proceedings}
{ output.bibitem
  editor empty$
    { organization output }
    { format.editors.dot output.nonnull }
  if$
  author format.key output
  output.year.check
  new.block
  format.btitle "title" output.check
  format.bvolume output
  format.number.series output
  address empty$
    { editor empty$
        { publisher new.sentence.checka }
        { organization publisher new.sentence.checkb
          organization output
        }
      if$
      publisher output
    }
    { address output.nonnull
      new.sentence
      editor empty$
        'skip$
        { organization output }
      if$
      publisher output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {techreport}
{ output.bibitem
  format.authors "author" output.check
  author format.key output
  output.year.check
  new.block
  format.title "title" output.check
  new.block
  format.tr.number output.atitle.nonnull
  institution "institution" output.check
  address output
  new.block
  note output
  fin.entry
}

FUNCTION {unpublished}
{ output.bibitem
  format.authors "author" output.check
  author format.key output
  output.year.check
  new.block
  format.title "title" output.check
  new.block
  note output.atitle
  fin.entry
}

FUNCTION {default.type} { misc }

MACRO {jan} {"January"}

MACRO {feb} {"February"}

MACRO {mar} {"March"}

MACRO {apr} {"April"}

MACRO {may} {"May"}

MACRO {jun} {"June"}

MACRO {jul} {"July"}

MACRO {aug} {"August"}

MACRO {sep} {"September"}

MACRO {oct} {"October"}

MACRO {nov} {"November"}

MACRO {dec} {"December"}

READ

FUNCTION {sortify}
{ purify$
  "l" change.case$
}

INTEGERS { len }

FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

INTEGERS { et.al.char.used }

FUNCTION {initialize.et.al.char.used}
{ #0 'et.al.char.used :=
}

EXECUTE {initialize.et.al.char.used}

FUNCTION {format.full.lab.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{vv~}{ll}" format.name$ 't :=
      nameptr #1 >
        { namesleft #1 >
            { ", " * t * } % ", "
            { numnames #2 >
                { "\ " * } % was "," buy you don't need a comma
                'skip$     % after the author before the &
              if$
              t "others" =
                { " et~al." * }
                { " \B\ " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.lab.names}
{ 's :=
  s #1 "{vv~}{ll}" format.name$
  s num.names$ duplicate$
  #2 >
     { pop$ " et~al." * }
     { #2 <
          'skip$
          { s #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
                { " et~al." * }
                { " \B\ " * s #2 "{vv~}{ll}" format.name$ * }
             if$
          }
       if$
     }
  if$
}

FUNCTION {author.key.label}
{ author empty$
    { key empty$
        { cite$ #1 #3 substring$ }
        { key #3 text.prefix$ }
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {author.editor.key.label}
{ author empty$
    { editor empty$
        { key empty$
            { cite$ #1 #3 substring$ }
            { key #3 text.prefix$ }
          if$
        }
        { editor format.lab.names }
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {author.key.organization.label}
{ author empty$
    { key empty$
        { organization empty$
            { cite$ #1 #3 substring$ }
            { "The " #4 organization chop.word #3 text.prefix$ }
          if$
        }
        { key #3 text.prefix$ }
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {editor.key.organization.label}
{ editor empty$
    { key empty$
        { organization empty$
            { cite$ #1 #3 substring$ }
            { "The " #4 organization chop.word #3 text.prefix$ }
          if$
        }
        { key #3 text.prefix$ }
      if$
    }
    { editor format.lab.names }
  if$
}




FUNCTION {calc.label}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.key.label
    { type$ "proceedings" =
        'editor.key.organization.label
        { type$ "manual" =
            'author.key.organization.label
            'author.key.label
          if$
        }
      if$
    }
  if$ duplicate$

  push.author format.full.lab.names
  % CHANGE HERE - RZD moved \protect\BCAY{
  "}{" * swap$ * "}{" *
  year field.or.null purify$ #-1 #4 substring$ *
  'label :=

  year field.or.null purify$ #-1 #4 substring$  'date.label :=

  push.author #1 "{}{}{}{f}" format.name$ * % initials to label
  date.label * sortify duplicate$ 'sort.label := 'sort.key$ :=

}


FUNCTION {sort.format.names}
{ 's :=
  #1 'nameptr :=
  ""
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 >
        { "   " * }
        'skip$
      if$
      s nameptr "{vv{ } }{ll{ }}{  ff{ }}{  jj{ }}" format.name$ 't :=
      nameptr numnames = t "others" = and
        { "et~al." * }
        { t sortify * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {sort.format.title}
{ 't :=
  "A " #2
    "An " #3
      "The " #4 t chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}

FUNCTION {author.sort}
{ author empty$
    { key empty$
        { "to sort, need author or key in " cite$ * warning$
          ""
        }
        { key sortify }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.editor.sort}
{ author empty$
    { editor empty$
        { key empty$
            { "to sort, need author, editor, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { editor sort.format.names }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.organization.sort}
{ author empty$
    { organization empty$
        { key empty$
            { "to sort, need author, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {editor.organization.sort}
{ editor empty$
    { organization empty$
        { key empty$
            { "to sort, need editor, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { editor sort.format.names }
  if$
}

% Produces the correct sort.key$ for each entry

FUNCTION {correct.order}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.sort
    { type$ "proceedings" =
        'editor.organization.sort
        { type$ "manual" =
            'author.organization.sort
            'author.sort
          if$
        }
      if$
    }
  if$
  "    "
  *
  year field.or.null sortify
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}


% Presort into first author/chronological, order so that multi-author
% entries with the same date appear next to each other.  This means
% we can easily spot ambiguous uses of "First Author et al Year" (where
% the First Author and the same Year occur as two entries).

ITERATE {calc.label}

SORT

% Functions to search through looking for authors with the same
% surname, and giving different initials in that case.

STRINGS {surname initials last.surname last.initials last.author last.year}

FUNCTION {init.match}
{
    " " 'last.author :=
}

FUNCTION {same.surname}
{ % Having found two surnames the same, test to see if they
  % have different initials, which means they are different people.
  % If so, rebuild the label to include the initials.
    initials last.initials =
        { push.author num.names$ #2 >   % remove short cite
          last.author num.names$ #2 > and
          last.year year = and
            {  author format.full.lab.names 's :=
                s  "}{" * s * "}{" * date.label *
                'label :=
            % Don't add a letter unless all authors are the same
            push.author format.full.lab.names year * 'sort.label := }
            'skip$
          if$
          push.author 'last.author :=
          year 'last.year := }
        { initials ".~" * surname *
         other.authors * "}{" * initials * ".~" * surname *
         other.authors * "}{" * date.label * 'label := }
    if$
}




% Expects author and #number on the stack, and leaves
% surname and initials on the stack
FUNCTION {push.surname.initials}
{ 'nameptr := duplicate$
  nameptr "{}{}{}{f}" format.name$ % initials
  swap$ nameptr "{vv~}{ll}{, jj}{}" format.name$ % surname
}

FUNCTION {match.surnames}
{ % We assume the entries are in alphabetical order, so that the
  % next entry will have exactly the same surname, or it will not,
  % in which case no more entries with this surname will be encountered.

    last.author " " =
        { push.author 'last.author :=
          year 'last.year := } % initialize
        { last.author #1 push.surname.initials
          'last.surname := 'last.initials :=
          push.author #1 push.surname.initials
          'surname := 'initials :=

          % If the last surname is the same as the current surname
          % see if the initials match, otherwise go on to the next entry.
          last.surname surname =
              'same.surname
              { push.author 'last.author :=
                year 'last.year :=}
          if$
        }
    if$
}

EXECUTE {init.match}

ITERATE {match.surnames}

% The forward algorithm misses the first of a duplicate set of surnames,
% so we have to go back over the entries to tidy up

EXECUTE {init.match}

REVERSE {match.surnames}

% Sort into the correct order for the bibliography

ITERATE {correct.order}

SORT

STRINGS { last.sort.label next.extra }

INTEGERS { last.extra.num }

FUNCTION {forward.pass}
{ last.sort.label sort.label =
    { last.extra.num #1 + 'last.extra.num :=
      last.extra.num int.to.chr$ 'extra.label :=
    }
    { "a" chr.to.int$ 'last.extra.num :=
      "" 'extra.label :=
      sort.label 'last.sort.label :=
    }
  if$
}

FUNCTION {reverse.pass}
{ next.extra "b" =
    { "a" 'extra.label := }
    'skip$
  if$
  label extra.label * "}" * 'label :=
  extra.label 'next.extra :=
}

ITERATE {forward.pass}

REVERSE {reverse.pass}

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{}"  write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}
