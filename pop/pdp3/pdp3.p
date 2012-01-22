/* LOADER FOR PDP3 ROUTINES */

vedputmessage('Loading PDP3 utilities');

extend_searchlist('~richardd/pop/pdp3',popuseslist) -> popuseslist;
extend_searchlist('~richardd/pop/pdp3',popliblist) -> popliblist;
extend_searchlist('~richardd/pop/lib',popuseslist) -> popuseslist;
extend_searchlist('~richardd/pop/lib',popliblist) -> popliblist;

;;; General routines for file I/O
uses stringtolist.p
uses stringtovector.p
uses sysio.p

;;; Basic PDP3 structures and variables
uses pdp3_utils.p

uses pdp3_getweights.p
uses pdp3_getpatterns.p

uses pdp3_activate.p
uses pdp3_cascade.p

uses pdp3_recordunits.p
uses pdp3_performance.p
