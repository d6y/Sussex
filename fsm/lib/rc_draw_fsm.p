uses rc_arrow;
uses fsm;

/*
XpwSetFont(rc_window,
'-adobe-helvetica-medium-r-normal--*-75-*-*-p-*-iso8859-1')->;
*/

vars angle_counter, states_seen;

define expand_states(s,table,ninputs);
    vars s, i, next_state,xc,yc,ofs=15, X, angdist,
        circle, Y, R, xpos, ypos;


    s :: states_seen -> states_seen;
    X + sin(angdist*angle_counter)*circle -> xc;
    Y + cos(angdist*angle_counter)*circle -> yc;
;;;    rc_print_at(xc-4,yc-4,''><s);
    rc_print_at(xc-24,yc-4,''><s);

if fsm_outputs(M)(s) = undef then
    rc_print_at(xc+R+2,yc+R-4,''><((fsm_outputs(M)(s))));
else
    rc_print_at(xc+R+2,yc+R-4,''><(shorten(fsm_outputs(M)(s))));
endif;
    xc -> xpos(s);
    yc -> ypos(s);
    rc_jumpto(xpos(s),ypos(s)-R);
    rc_arc_around(R,360);
    angle_counter + 1 -> angle_counter;

    for i from 1 to ninputs do
        table(s,i) -> next_state;
        if next_state /= undef then


            if next_state = s then  ;;; self connections
                rc_jumpto(xpos(s)+R,ypos(s));
                rc_arc_around(R*2,230);
            else


                if not(member(next_state,states_seen)) then
                    expand_states(next_state,table,ninputs);
                endif;

                rc_jumpto(xpos(s),ypos(s));
                rc_drawto(xpos(next_state), ypos(next_state));

                rc_arrow_line(xpos(s),ypos(s),
                    xpos(next_state), ypos(next_state), 0.5,
                    fsm_inputs(M)(i) );

            endif;
        endif;
    endfor;

enddefine;


define rc_draw_fsm(M);
    vars pop_radians = false, X, Y, R, angdist,circle,xpos,ypos,i,s,
        c,nstates,ninputs,next_state,xc,yc;

    ;;; rc_default();
    50 -> rc_xorigin;
    400 -> rc_yorigin;
    700 -> rc_window_xsize;
    700 -> rc_window_ysize;
    rc_start();

    if fsm_extraction_method(M) = "file" then
;;;        rc_print_at(0,380,'Graph for '><sys_fname_nam(fsm_name(M)));
    else
;;;        rc_print_at(0,380,'Graph for '><sys_fname_nam(fsm_name(M))
;;;        ><', method: ' ><(fsm_extraction_method(M)) ><', '
;;;        ><(fsm_extraction_value(M)));
    endif;

    length(fsm_states(M)) -> nstates;
    length(fsm_inputs(M)) -> ninputs;
    newarray([0 ^nstates]) -> xpos;
    newarray([0 ^nstates]) -> ypos;

    360/(1+nstates) -> angdist;
    200 -> circle;
    100/nstates -> R;
    200 -> X;
    125-> Y;

    [] -> states_seen;
    0 -> angle_counter;
    expand_states(0,fsm_table(M),length(fsm_inputs(M)));

enddefine;
