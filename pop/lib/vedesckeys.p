/* My own escape sequences */

;;; <ESC> z - stop
;;; vedsetkey('\^[z', ved_stop);

;;; <ESC> t - thesaurus
;;; uses ved_thesaurus;
;;; vedsetkey('\^[t', "ved_thesaurus");

;;; CTRL-a - spell check word
;;; uses ved_ispell;
vedsetkey('\^a', "ved_ispell");

;;; CTRL-q - lookup definition of word at cursor
;;; vedsetkey('\^q', "ved_longman");


;;; <ESC> y copy marked range to current cursor positionn
;;;vedsetkey('\^[y', procedure;
;;;ved_copy(); ved_y(); endprocedure);

;;; <ESC> Y copy and delete marked range to current cursor positionn
;;;vedsetkey('\^[Y', procedure;
;;;ved_copy(); ved_y(); ved_d(); endprocedure);

;;; <ESC> - - centre current line
;;; vedsetkey('\^[-', procedure;
;;; vedmarklo(); vedmarkhi(); ved_ac();
;;; endprocedure);
;;;
;;; ;;; <ESC> . - move current line right
;;; vedsetkey('\^[.', procedure;
;;; vedmarklo(); vedmarkhi(); ved_ar();
;;; endprocedure);
;;;
;;; ;;; <ESC> , - move current line left
;;; vedsetkey('\^[,', procedure;
;;; vedmarklo(); vedmarkhi(); ved_al();
;;; endprocedure);
;;;

;;; <ESC> 6 - static toggle
;;; Writen because I couldn't find the static toggle
;;; on a SUN console...
vedsetkey('\^[6', procedure;
        if vedstatic then
            vedputmessage('Static mode OFF');
            false -> vedstatic;
        else
            true -> vedstatic;
            vedputmessage('Static mode ON');
        endif;
        endprocedure);



;;; <ESC> b - complete define/begin command
;;; uses ved_complete;
vedsetkey('\^[b', "ved_complete");

;;; <ESC> s - section title
;;; uses ved_section;
;;; vedsetkey('\^[s', "ved_section");

;;; <ESC> S - bigger section title
;;; uses ved_Section;
;;; vedsetkey('\^[S', "ved_Section");

;;;<ESC> v - Refreshes both ved windows. Useful if screen has been corrupted.
vedsetkey('\^[v', vedrestorewindows);

;;; CTRL-N - save current news file in $HOME/mail/<newsgroup>
;;; uses ved_sn;
;;; vedsetkey('\^N', "ved_sn");

;;; ctrn w - save file
vedsetkey('\^W', veddo(%'w1'%) );


;;; ESC-REDO - catchup-news
;;;vedsetkey('\^[\^[[32~', procedure(); vars vedargument = '.';
;;;        ved_gn(); endprocedure);


;;; ESC-REDO - catch-up news (different keyboards!)
;;;vedsetkey('\^[\^[Om', procedure(); vars vedargument = '.';
;;;         ved_gn(); endprocedure);

;;;;;; ESC-o - find next Subject line
;;;vedsetkey('\^[o', procedure();
;;;        veddo(%'/@aSubject'%)(); vedtopwindow(); endprocedure);

;;; ESC-o - find next From line
vedsetkey('\^[o', procedure();
        veddo(%'/@aFrom:'%)(); vedtopwindow(); endprocedure);


;;; ESC-i - copy current line to end of file (handy in immediate mode)
;;; uses ved_copytoend;
;;; vedsetkey('\^[i', ved_copytoend);

;;; ESC l - find message with same subject in get news
;;;vedsetkey('\^[l', "ved_samesubj");



vedsetkey('\^[1',veddo(%'ved ^f'%));    ;;; ESC-1 open filename at cursor
vedsetkey('\^[2',veddo(%'/^w'%));       ;;; ESC-2 search for word at cursor
vedsetkey('\^[3', "vedfilecomplete");   ;;; ESC-3 file name completion
vedsetkey('\^[4', veddo(%'^e'%));       ;;; ESC-4 execute ved command at cursor

;;; ESC ] -- jump to marked range
vedsetkey('\^[]', vedmarkfind);

;;; File browser
vedsetkey('\^[0', veddo(%'openfile'%));
;;; All windows lowered
vedsetkey('\^[V', veddo(%'closeall'%));
