;;; "Mail Tail" -- adds final address line to a buffer
define ved_mailtl;
    if vedargument = '' then
        '$HOME/.mailtl' -> vedargument;
    else
        '$HOME/.mailtl2' -> vedargument;
    endif;
    ved_r();
enddefine;
