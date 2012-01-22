
/*

    XRUNNET.P


         CONTENTS - (Use <ENTER> g to access required sections)

 -- Library Files
 -- Varaible initialization
 -- Window handling routines
 -- Support functions
 -- Accepters
 -- Converters
 -- Display output vector
 -- Load network
 -- Load problem set
 -- Saving/print Graphs
 -- FINITE STATE MACHINE
 -- CDA
 -- PCA
 -- -- 3D Plotting code
 -- -- 2D trajectory code
 -- CLUSTER
 -- VISUALIZATION CONTROLS
 -- Solving problems
 -- Correct solutions
 -- LATEX CODE
 -- START-UP CODE

*/




/*
-- Library Files ------------------------------------------------------
*/

;;; Assumes programs.p has been loaded
uses popxlib;
uses rc_graphic;
uses rc_context;
uses propsheet;
uses rc_postscript;
uses ved_arith;
uses xrunnet_procs;
uses rc_draw_fsm;
;;; uses pdp3_extract_fsm;
uses find_states;
uses rc_3d;
uses stripquotes;

/*
-- Varaible initialization --------------------------------------------
*/

propsheet_init();

vars box, file_sheet, task_sheet, paper_window, net_sheet, paper_context,
    time_out, threshold, net, Solution, solution_position, solution_time,
    fsm_context, vis_sheet, machine, minimized_machine, pca_context;

vars Xcol, Xrow, xrunnet_ov;
vars default_wtsfile, default_netfile, default_problemsfile;


if isundef(default_wtsfile) then
'weights/' -> default_wtsfile;
endif;

if isundef(default_netfile) then
    'networks/fsm35' -> default_netfile;
endif;

if isundef(default_problemsfile) then
    'list' -> default_problemsfile;
endif;


vars outputbox, outputsheet=false, spew_file, current_problem=[];
vars vis_probs = [],
     vis_hidden = [],
     vis_names,
     vis_pcafile = '/tmp/pcadata',
     vis_pcatmpfile = '/tmp/pcatmp.tmp',
     vis_hidfile = '/tmp/hiddenvecs',
     vis_colours = '/tmp/hiddenvecs.colors',
     vis_namefile = '/tmp/hiddenvecs.row',
     vis_glyphs = '/tmp/hiddenvecs.glyphs',
     selection_box, selection_sheet,
     old_pca1, old_pca2, old_pca3,
     old_hidden_endpoints, old_xyzlist, old_netfile, netfile;

    vars colour_sheet, colour_box;

    vars colour_list = [Yellow Black Red Green Orange YellowGreen
        HotPink SkyBlue SlateBlue Orchid Peru];

    vars glyph_size = [Medium Large Small Jumbo Tiny];

    vars glyph_size_table = newproperty([ [Tiny 1] [Small 2] [Medium 3]
        [Large 4] [Jumbo 5]], 100, 3, "perm");

    vars glyph_types = ['Open circle' 'Filled circle' 'Filled rectangle'
        'Open rectangle' 'Cross' 'Plus' 'Pixel'];

    vars glyph_type_table;
    newanyproperty([ ['Filled circle' 25]
        ['Open circle' 20] ['Filled rectangle' 15] ['Open rectangle' 10]
        ['Cross' 5] ['Plus' 0] ['Pixel' 31]],20,false,false,
        syshash, nonop =,"perm",25,false)
        -> glyph_type_table;

define glyph_code(type,size);
    min(31,glyph_size_table(size)+glyph_type_table(type));
enddefine;

vars
    xgobi_default_colour = colour_list(1),
    xgobi_default_type = glyph_types(1),
    xgobi_default_size = glyph_size(1),
    xgobi_default_code = glyph_code(xgobi_default_type,xgobi_default_size),
    xgobi_map=[], i,
    op_list = [% for i in output_operations do i(1); endfor; %];


for i in op_list do
    [% i; [% xgobi_default_colour; xgobi_default_type;
            xgobi_default_size; xgobi_default_code;%] %]
        :: xgobi_map -> xgobi_map;
endfor;


/*
-- Window handling routines -------------------------------------------
*/

define xt_new_window(string,xsize,ysize,xloc,yloc) -> widget;
    lvars string, xsize, ysize, xloc, yloc, widget;
    lconstant arg_vector = initv(4); ;;; re-usable vector for XptNewWindow
    lconstant XpwGraphic = XptWidgetSet("Poplog")("GraphicWidget");
    lconstant input_arg_vector = {input ^(not(not(rc_wm_input)))};  ;;;thanks to jonm

    check_string(string);
    fi_check(xsize,0,false) ->;
    fi_check(ysize,0,false) ->;
    fi_check(xloc,false,false) ->;
    fi_check(yloc,false,false) ->;

    XptNewWindow(
        string,
        fill(xsize, ysize, xloc, yloc, arg_vector),
        [],
        XpwGraphic,
        [^input_arg_vector]
        ) ->widget;
enddefine;

/*
-- Support functions --------------------------------------------------
*/

define gobi_buttons(propbox, button) -> accept;
vars colour, op, g, s, c,atr;

    false -> accept;

    if button = "Dismiss" then
        propsheet_hide([% colour_box %]);
        unless vis_names = [] then
            make_gobi_colours(vis_names);
        endunless;
    elseif button = "Apply" then
        colour_sheet("Colour") -> colour;
        colour_sheet("Operation") -> op;
        colour_sheet("Glyph") -> g;
        colour_sheet("Size") -> s;
        glyph_code(g,s) -> c;

        xgobi_map --> [==[^op ?atr]==];
        delete([^op ^atr],xgobi_map)->xgobi_map;
        [^op [^colour ^g ^s ^c]] :: xgobi_map -> xgobi_map;
    endif;

enddefine;

define selection_buttons(propbox, button) -> accept;
    lvars i, threshold, time_out, selected_problem;

    false -> accept;

    if button = "Dismiss" then
        propsheet_hide([% selection_sheet, selection_box %]);
    elseif button = 'All on' then
        for i from 1 to propsheet_length(selection_sheet) do
            true -> selection_sheet(i);
        endfor;
        [] -> vis_hidden;
    elseif button = 'All off' then
        for i from 1 to propsheet_length(selection_sheet) do
            false -> selection_sheet(i);
        endfor;
        [] -> vis_hidden;
    elseif button = "Solve" then

        if not(ispdp3_net_record(net)) then
            say('Load a network first');
            return;
        endif;

        false -> selected_problem;
        for i from 1 to propsheet_length(selection_sheet) do
            if selection_sheet(i) = true then i -> selected_problem; endif;
        endfor;

        ;;; Solve then last problem ticked ON

        if selected_problem = false then
            say('No problem ticked');
            return;
        endif;

        copy(vis_probs(selected_problem)) -> current_problem;

        set_problem(vis_probs(selected_problem)) -> PAGE;
        rc_start();
        xshow(PAGE);
        task_sheet('Time out') -> time_out;
        strnumber(task_sheet('Activity threshold')) -> threshold;
        runnet(net, time_out, threshold) -> (Solution,reason);
        length(Solution) -> solution_time;
        xdraw(Solution,solution_time);
        solution_time -> solution_position;
        say(reason>< ' in '><solution_time><' steps.');

    elseif button = "Next" then
        if not(ispdp3_net_record(net)) then
            say('Load a network first');
            return;
        endif;

        ;;; find last ticked button...
        false -> selected_problem;
        for i from 1 to propsheet_length(selection_sheet) do
            if selection_sheet(i) = true then i -> selected_problem; endif;
        endfor;

        ;;; ...or the first if none ticked or last ticked
        if selected_problem = false or selected_problem = i then
            1 -> selected_problem;
        else
            1 + selected_problem -> selected_problem;
        endif;

        ;;; TICK the problem
        true -> selection_sheet(selected_problem);
        copy(vis_probs(selected_problem)) -> current_problem;
        set_problem(vis_probs(selected_problem)) -> PAGE;
        rc_start();
        xshow(PAGE);
        task_sheet('Time out') -> time_out;
        strnumber(task_sheet('Activity threshold')) -> threshold;
        runnet(net, time_out, threshold) -> (Solution,reason);
        length(Solution) -> solution_time;
        xdraw(Solution,solution_time);
        solution_time -> solution_position;
        say(reason>< ' in '><solution_time><' steps.');
    endif;
enddefine;


define blank_netsheet;
    '' -> net_sheet("Output");
    '' -> net_sheet("Input");
    '' -> net_sheet("Step");
enddefine;

define say(string);
    ''><string -> net_sheet("Messages");
;;;    propsheet_refresh(net_sheet,"Messages");
enddefine;




define file_set(file,fop) -> file;
    sysfileok(file) -> file;

    if file = '' then
        say('Filename not set.');
        false -> file;
    else
        if fop = "r" then ;;; file must exist to be read
            unless readable(file) then
                say('Cannot open '><file);
                false -> file;
            endunless;
        elseif fop = "w" then ;;; clobber notice
            if readable(file) then
                say('Clobbering file.');
            endif;
        else mishap('FILE_SET: File operation not recognized',[^fop]);
        endif;
    endif;
enddefine;

define draw_3d_outline;
    if pca_context = false then
        ;;; say('No graph drawn yet!');
    else
        pca_context -> rc_context();
        rc_3d_init();
        rc_3d_unitcube();
        rc_3d_jumpto(0,0,0); rc_print_here('0');
        rc_3d_jumpto(1,0,0); rc_print_here('x');
        rc_3d_jumpto(0,1,0); rc_print_here('y');
        rc_3d_jumpto(0,0,1); rc_print_here('z');
        paper_context -> rc_context();
    endif;
enddefine;

/*
-- Accepters ----------------------------------------------------------
*/


define rotate(sheet, name, value) -> value;
lvars x,y,z;

    vis_sheet("x") -> x;
    vis_sheet("y") -> y;
    vis_sheet("z") -> z;

    if propsheet_acceptreason == "increment" then
        value + 4;
    elseif propsheet_acceptreason == "decrement" then
        value - 9
    else
        value
    endif -> value;
    if name = "x" then
        mkrotate(value,y,z)
    elseif name = "y" then
        mkrotate(x,value,z)
    elseif name = "z" then
        mkrotate(x,y,value)
    endif; -> rc_3d_R;
    draw_3d_outline();
enddefine;


define xgobi_op_details(sheet, name, value) -> value;
    vars atr;
    xgobi_map --> [==[^value ?atr]==];
    atr(1) -> colour_sheet("Colour");
    atr(2) -> colour_sheet("Glyph");
    atr(3) -> colour_sheet("Size");
enddefine;

define rotate_home(sheet, name, value) -> value;
    mkrotate(-15,25,0) -> rc_3d_R;
    draw_3d_outline();
    -15 -> vis_sheet("x");
    25 -> vis_sheet("y");
    0 -> vis_sheet("z");
enddefine;

define show_xgobi(sheet, name, value) -> value;
    propsheet_show([% colour_sheet, colour_box %]);
enddefine;

define start_xgobi(sheet, name, value) -> value;
    say('Starting xgobi...');
    sysobey('xgobi '><vis_hidfile>< ' &');
    say('');
enddefine;

define start_xgobi_pca(sheet, name, value) -> value;

    if vis_sheet('3D') then
        say('Starting xgobi...');
    else
        say('Use Xgobi 3dpca with 3d PCA data');
        return;
    endif;

    vars
        vis_pcafile2 = vis_pcafile><'',
        c = vis_pcafile2 >< '.colors',
        r = vis_pcafile2 >< '.row',
        g = vis_pcafile2 >< '.glyphs';

    sysobey('rm -f '><g><' '><c><' '><r><' ; '><
        'ln -s '><vis_colours><' '><c><' ; '><
        'ln -s '><vis_glyphs><' '><g><' ; '><
        'ln -s '><vis_namefile><' '><r><' ; '><
        'xgobi '><vis_pcafile2>< ' &');
    say('');
enddefine;


define re_draw_3d_pca(sheet, name, value) -> value;

    if old_xyzlist = [] then
        say('No old graph to redraw');
        return;
    endif;

    vars x,y,z,oldx,oldy,oldz,xscale,yscale,zscale,x0,y0,z0, show_time,
            prob, show_prob, probnum, selectedprobs;

    vis_sheet("Time") -> show_time;
    vis_sheet('Show problem') -> show_prob;

    if show_prob then
        [% for probnum from 1 to length(vis_probs) do
                if selection_sheet(probnum) then
                    make_problem_label(vis_probs(probnum));
                endif;
            endfor; %] -> selectedprobs;
        1 -> probnum;
    endif;

    0 ->> xscale ->> yscale ->> zscale ->> x0 ->> y0 -> z0;

    pca_context -> rc_context();
    rc_start();
    rc_3d_init();
    rc_3d_unitcube();
    rc_3d_axis(0.1);

    foreach [?x ?y ?z] in old_xyzlist do
        min(x0,x) -> x0;
        max(xscale,x) -> xscale;
        min(y0,y) -> y0;
        max(yscale,y) -> yscale;
        min(z0,z) -> z0;
        max(zscale,z) -> zscale;
    endforeach;

    1.0/(xscale-x0) -> xscale;
    1.0/(yscale-y0) -> yscale;
    1.0/(zscale-z0) -> zscale;

    vars time =0, endpoints = [0 ^^old_hidden_endpoints], dif=0;

    foreach [?x ?y ?z] in old_xyzlist do
        xscale * (x-x0) -> x;
        yscale * (y-y0) -> y;
        zscale * (z-z0) -> z;

        if member(time,endpoints) then
            if show_time then
                rc_3d_jumpto(x,y,z);
                rc_print_here(''><(time-dif));
            endif;
            if time > 1 and show_prob then
                rc_print_here(selectedprobs(probnum));
                probnum+1->probnum;
            endif;
            dif+time->dif;
            ;;;    rc_3d_jumpto(x,y,z);
            rc_3d_to_2d(x,y,z) -> (x,y);
            x -> oldx; y->oldy;
        else
            rc_3d_to_2d(x,y,z) -> (x,y);
            rc_arrow_line(oldx,oldy,x,y,1.0);
            x->oldx;y->oldy;
            ;;;    rc_3d_drawto(x,y,z);
            if show_time then rc_print_here(''><(time-dif)); endif;
        endif;

        time+1->time;

    endforeach;

    if show_prob then
        rc_print_here(selectedprobs(probnum));
    endif;


    vars lab_off = -0.05;
    rc_3d_jumpto(0.5,lab_off,lab_off); rc_print_here(''><old_pca1);
    rc_3d_jumpto(lab_off,0.5,lab_off); rc_print_here(''><old_pca2);
    rc_3d_jumpto(1-lab_off,lab_off,0.5); rc_print_here(''><old_pca3);

    rc_print_at(-30,370,''><old_netfile);

    paper_context -> rc_context();

enddefine;




define show_selection(sheet, name, value) -> value;
    propsheet_show([% selection_sheet, selection_box %]);
enddefine;

define selection_change(sheet, name, value) -> value;
    [] -> vis_hidden;
enddefine;

define not_negative(sheet, name, value) -> value;
    if isstring(value) then
        if strnumber(value) < 0 then
            propsheet_undef -> value
        endif;
    elseif value < 0 then
        propsheet_undef -> value
    endif;
    if name = 'First row' then
        propsheet_set_focus_on(task_sheet,'Second row');
    endif;
enddefine;


define re_record(sheet, field, value) -> value;
    [] ->> vis_hidden -> vis_names;
enddefine;

define refuse(sheet, field, value) -> value;
    propsheet_undef -> value;
enddefine;

define numbers_only(sheet, field, value) -> value;
    unless isnumber(strnumber(value)) then
        propsheet_undef -> value;
    endunless;
enddefine;

define pca_sensitivity(sheet, field, value) -> value;

    if value = "pca" then
        true;
    else
        false;
    endif;

        ->> propsheet_field_sensitive(vis_sheet,'Pca1');
        ->> propsheet_field_sensitive(vis_sheet,'Pca2');
        -> propsheet_field_sensitive(vis_sheet,'Pca3');

    if value = "pca" and vis_sheet('3D') and vis_sheet("DrawMethod")="rc_graphic" then
        true -> propsheet_field_sensitive(vis_sheet,'Pca3');
    else
        false -> propsheet_field_sensitive(vis_sheet,'Pca3');
    endif;
enddefine;

define extract_method_sensitivity(sheet, field, value) -> value;
    if value = "Quantize" then
        false -> propsheet_field_sensitive(vis_sheet,'Similarity');
        true -> propsheet_field_sensitive(vis_sheet,"Quantization");
    else
        true -> propsheet_field_sensitive(vis_sheet,'Similarity');
        false -> propsheet_field_sensitive(vis_sheet,"Quantization");
    endif;
enddefine;

define threeD_sensitivity(sheet, field, value) -> value;
    if value and vis_sheet("Graph")="pca" and vis_sheet("DrawMethod")="rc_graphic" then
        true
    else
        false
    endif;
    -> propsheet_field_sensitive(vis_sheet,'Pca3');
enddefine;


define method_sesitivity(sheet, field, value) -> value;
    if value = "xgraph" then
        false -> propsheet_field_sensitive(vis_sheet,'Pca3');
    else
        if vis_sheet('3D') = true and vis_sheet("Graph")="pca" then
            true -> propsheet_field_sensitive(vis_sheet,'Pca3')
        endif;
    endif;
enddefine;

/*
-- Converters ---------------------------------------------------------
*/

define string_number_convert(value) -> value;
    strnumber(value) -> value;
enddefine;

define updaterof string_number_convert(value);
    value >< '' -> value;
enddefine;

/*
-- Display output vector ----------------------------------------------
*/

define quit_vector(propbox, button) -> accept;
    propsheet_destroy(outputbox);
    true -> accept;
    false -> outputsheet;
enddefine;

define plot_vector(sheet, name, value) -> value;
    vars i,order, v, name;

    unless ispdp3_net_record(net) then
        say('Load network first');
        return;
    endunless;

    if length(xrunnet_ov) /= length(output_operations) then
        say('Vector length different to number of operations');
        return;
    endif;

    [% for i from 1 to length(output_operations) do
            [^i ^(xrunnet_ov(i))] endfor; %] -> order;

    syssort(order, procedure(i1, i2); i1(2)>i2(2); endprocedure) -> order;

    propsheet_new_box('OUTPUT VECTOR',false,quit_vector,
        [Close]) -> outputbox;

    propsheet_new('Activity (left-to-right, top-to-bottom order)',
        outputbox, [%
            for i from 1 to length(order) do
                order(i)(1) -> name;
                order(i)(2) -> v;
                if i/2 = intof(i/2) then "+"; endif;
                [^(output_operations(name)(2)) message ^v]
            endfor; %]) -> outputsheet;

    propsheet_show([% outputsheet, outputbox %]);

enddefine;

define update_outputsheet;
    vars i, i1,i2, order, name, v;

    if outputsheet=false then return; endif;

    [% for i from 1 to length(output_operations) do
            [^i ^(xrunnet_ov(i))] endfor; %] -> order;

    syssort(order, procedure(i1, i2); i1(2)>i2(2); endprocedure) -> order;

    propsheet_destroy([^outputsheet]);

    propsheet_new('Activity (left-to-right, top-to-bottom order)',
        outputbox, [%
            for i from 1 to length(order) do
                order(i)(1) -> name;
                order(i)(2) -> v;
                if i/2 = intof(i/2) then "+"; endif;
                [^(output_operations(name)(2)) message ^v]
            endfor; %]) -> outputsheet;

    propsheet_show([^outputsheet]);

enddefine;


/*
-- Load network -------------------------------------------------------
*/

define next_network(sheet, name, value) -> value;
    vars n, wtsfile, dash_point, dot_point, last_dash_point;

    pdp3_adddot(file_sheet('Weights file'),'wts') -> wtsfile;

    ;;; expect file name to be: something-NUMBER.wts

    issubstring('.wts',wtsfile) -> dot_point;

    ;;; Find last - in the filename

    false -> last_dash_point;
    issubstring('-',wtsfile) -> dash_point;

    while dash_point /= false do
        dash_point -> last_dash_point;
        issubstring('-',dash_point+1,wtsfile) -> dash_point;
    endwhile;

    if dot_point = false and last_dash_point = false then
        say('Don\'t recognize filename format');
        return;
    endif;

    ;;; Find number

    substring(last_dash_point+1,dot_point-last_dash_point-1,wtsfile) -> n;

    strnumber(n) -> n;

    if n == false then
        say('Didn\'t find a number between - and .');
        return;
    endif;

    substring(1,last_dash_point,wtsfile) >< (n+1) >< '.wts'
        -> file_sheet('Weights file');

    say('Weights filename updated...now load it');

enddefine;

define load_network(sheet, name, value) -> value;
    vars wtsfile,netfile;

    pdp3_adddot(file_sheet('Weights file'),'wts') -> wtsfile;
    pdp3_adddot(file_sheet('Network file'),'net') -> netfile;

    if file_set(wtsfile,"r") then
        if file_set(netfile,"r") then
            if readable(netfile) and readable(wtsfile) then
                say('Loading...');
                pdp3_getweights(netfile, wtsfile) -> net;
                say('Network loaded.');
                [] ->> vis_hidden -> vis_names;
                false ->> machine ->> minimized_machine -> Solution;
            else
                say('Could not open file.');
            endif;
        endif;
    endif;

    if isstring(netfile) then netfile -> file_sheet('Network file'); endif;
    if isstring(wtsfile) then wtsfile -> file_sheet('Weights file'); endif;

enddefine;


/*
-- Load problem set ---------------------------------------------------
*/

define vis_edit_probs(sheet, field, value) -> value;
    vars file,dev,line,problem,nprobs;

    if field = "Load" then

        if (file_set(task_sheet('Problems file'),"r") ->> file) == false then
            return;
        endif;

        say('Loading...');

        [] ->> vis_hidden -> vis_names;

        fopen(file,"r") -> dev;
        [% repeat
                fgetstring(dev) -> line;
                if line = termin then
                    quitloop;
                else
                    stringtolist(line);
                endif;
            endrepeat; %] -> vis_probs;
        fclose(dev);

        say('Loaded '><(length(vis_probs))><' patterns.');
        false ->> machine -> minimized_machine;
        [] -> vis_hidden;

    propsheet_hide([% selection_sheet, selection_box %]);
    propsheet_destroy([% selection_sheet %]);
    propsheet_new('Problems', selection_box, [%
        length(vis_probs) -> nprobs;
        for problem from 1 to nprobs do
            [% make_problem_label(vis_probs(problem)); false;
                "("; "accepter"; "="; "selection_change"; ")"; %];
            if (problem mod 4 /= 0) and problem/=nprobs then "+"; endif;
        endfor; %]) -> selection_sheet;

    elseif field = 'Ved probs' then

        if (file_set(task_sheet('Problems file'),"r") ->> file) then
            say('Editing...');
            edit(file);
        else
            if (file_set(task_sheet('Problems file'),"w") ->> file) then
                say('Creating...');
                edit(file);
            endif;
        endif;
        say('Don\'t forget to load after an edit');

    endif;

enddefine;


/*
-- Saving/print Graphs ------------------------------------------------
*/

define save_graph(sheet, field, value) -> value;
    lvars file, draw;

    vis_sheet("Graph") -> draw;

    if draw = "cluster" then
        say('Use the HARDCOPY menu in the custer window');
        return;
    endif;

    if draw = "pca" and vis_sheet("DrawMethod") = "xgraph" then
        say('Use the HARDCOPY menu in the PCA window');
        return;
    endif;

    if value = 'Save' then

        if draw = "pca" then
            say('Can only save FSMs');
            return;
        endif;

        if (file_set(vis_sheet('Graph file'),"w") ->> file) then
            if minimized_machine /= false then
                say('Saving minimized machine...');
                minimized_machine -> fsm_file(file);
            else
                say('Saving machine...');
                machine -> fsm_file(file);
            endif;
            say('Machine saved.');
        endif;

    elseif value = 'PS Print' then

        systmpfile('/tmp','XRunNet','.ps') -> file;
        say('Printing to '><systranslate('$PRINTER')><'...');

        if draw = "pca" then

            if pca_rc_ps(file) /= false then
                sysobey('lpr '><file);
                sysdelete(file)->;
                say('Print job queued on '><systranslate('$PRINTER')><'.');
            endif;
        else

            if ps_draw_machine(file) /= false then
                sysobey('lpr '><file);
                sysdelete(file)->;
                say('Print job queued on '><systranslate('$PRINTER')><'.');
            endif;

        endif;

    elseif value = 'PS Save' then

        if draw = "pca" then

            pca_rc_ps(file_set(vis_sheet('Graph file'),"w"))->;

        else

            say('Saving FSM in PostScript file...');
            if (file_set(vis_sheet('Graph file'),"w")->>file) then
                ps_draw_machine(file)->;
                say('Saved.');
            endif;
        endif;

    endif;

enddefine;


/*
-- FINITE STATE MACHINE -----------------------------------------------
*/



define ps_draw_machine(file);

    if machine = false then
        say('Extract machine first.');
        return(false);
    endif;

    fsm_context -> rc_context();
    if minimized_machine = false then
        rc_postscript(file, rc_draw_fsm(%machine%), [3 3 0.5 0.5], true);
    else
        rc_postscript(file, rc_draw_fsm(%minimized_machine%),
            [3 3 0.5 0.5], true);
    endif;
    paper_context -> rc_context();

    return(true);
enddefine;

define draw_fsm;
    vars pn, nprobs, fsm_problems;
    false -> minimized_machine;
    if fsm_context = false then
        say('Creating FSM window...');
        xt_new_window('FSM', 500, 500, 550, 350) -> rc_window;
        520 -> rc_window_x; 300 -> rc_window_y;
        1 -> rc_xscale; -1 -> rc_yscale;
        0 ->> rc_xposition ->> rc_yposition -> rc_heading;
        false -> rc_clipping;
        0 ->> rc_xmin -> rc_ymin;
        50 -> rc_xorigin;
        400 -> rc_yorigin;
        700 -> rc_window_xsize;
        700 -> rc_window_ysize;
        XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-140-*-*-p-*-iso8859-1')->;
        rc_start();
        rc_context(false) -> fsm_context;
    endif;
    fsm_context -> rc_context();
    say('Extracting machine...');

    ;;;    pdp3_extract_fsm(net,vis_probs,nStates,time_out) -> machine;

    ;;; Build list of selected problems
    length(vis_probs) -> nprobs;
    [% for pn from 1 to nprobs do
            if selection_sheet(pn) = true then
                vis_probs(pn);
            endif;
        endfor; %] -> fsm_problems;

    find_states(net,fsm_problems,time_out,
        strnumber(task_sheet('Activity threshold')),
        true, extract_method)->machine;

    say('Drawing machine...');
    rc_draw_fsm(machine);
    paper_context -> rc_context();
    if fsm_non_deterministic(machine) then
        say(length(fsm_states(machine))><' states.  NON-DETERMINISTIC.');
    else
        say(length(fsm_states(machine))><' states.');
    endif;
enddefine;



define minimize_fsm;
    vars minl, macl, Talkative=false;

    if machine = false then
            draw_fsm(); ;;; get the full machine first
        ;;;say('Extract machine before you minimize it');
    else
        if minimized_machine = false then
            say('Minimizing machine...');
            fsm_minimize(machine) -> minimized_machine;
            say('Drawing...');
            fsm_context -> rc_context();
            rc_draw_fsm(minimized_machine);
            paper_context -> rc_context();
            length(fsm_states(minimized_machine)) -> minl;
            length(fsm_states(machine)) -> macl;
            if minl = macl then
                say('Total of '><minl><' states.  No saving.');
            else
                say('Total of '><minl><' states (saving '><(macl-minl)><' states).');
            endif;

        else
            say('Drawing...');
            fsm_context -> rc_context();
            rc_draw_fsm(minimized_machine);
            paper_context -> rc_context();
            say('');
        endif;
    endif;

enddefine;

/*
-- CDA ----------------------------------------------------------------
*/

vars cda_groupsfile = '/tmp/cda.groups';

define cda;

    vars l, threshold, timeout, pca1, pca2, pca3, threeD, plot_data,
        rcg_pt_type, rcg_ax_type = "box", xydata, end_point,
        file_string, file, phead, problem, i, op, start_point, points,
        netfile = sys_fname_nam(pdp3_wtsfile(net));

    if vis_hidden = [] then
        say('Recording hidden vectors...');
        task_sheet('Time out') -> timeout;
        strnumber(task_sheet('Activity threshold')) -> threshold;
        record_hidden(net,timeout,threshold,vis_probs)
            -> (vis_hidden, vis_names);
        say('Saving to file...');
        vis_hidden -> ffile(vis_hidfile);
        vis_names -> ffile(vis_namefile);

        make_gobi_colours(vis_names);
        say('');
    endif;

    [%
        for l in vis_names do
            [% substring(1,3,hd(l)); %];
        endfor;
    %] -> ffile(cda_groupsfile);


    say('RUNNING CDA...');

    vis_sheet('Pca1') -> pca1;
    vis_sheet('Pca2') -> pca2;

    ;;; remove anything left by last CDA run
    sysobey('rm -f '><vis_hidfile><'.canonical_* '><vis_pcafile);

    sysobey('cda -f '><vis_hidfile>< ' -g /tmp/cda '><
        '-x '><pca1><' -y ' ><pca2><' > '><vis_pcafile);


    ffile(vis_pcafile) -> xydata;

    if xydata == nil then
        say('Error - cda didn\'t produce output');
        return;
    endif;

    copy(hidden_endpoints) -> points;
    1 -> start_point;
    '' -> file_string;

    [% for problem in vis_probs do

            make_problem_label(problem) -> phead;

            ;;; Only show selected problems
            if selection_sheet(phead) = false then
                ;;; do nothing
            else

                [];
                [% '\"'><phead><'\"'; %];

                unless points = [] then
                    dest(points) -> points -> end_point;
                    for i from start_point to end_point do
                        [% xydata(i)(1); xydata(i)(2); hd(vis_names(i)); %];
                    endfor;
                    end_point+1 -> start_point;
                endunless;
            endif;
        endfor; %] -> ffile(vis_pcafile);


    sysobey(' xgraph -tk -bb -P -t \"CDA for ' >< netfile ><
        '\" -x \"V '><(pca1)><'\" -y \"V '>< (pca2)><'\" '
        ><vis_pcafile><' &');
enddefine;

/*
-- PCA ----------------------------------------------------------------
*/


define pca_rc_ps(file) -> file;

    if file = false then return; endif;

    if pca_context = false then
        say('No PCA graph yet!');
        false -> file;
        return;
    endif;

    rc_postscript(file, pca, [3 3 0.5 0.5], true);

enddefine;



define threeD_pca_plot(file,pca1,pca2,pca3);

    vars xscale=0, yscale=0, zscale=0;
    vars x0=0, y0=0, z0=0;
    vars x,y,z,oldx,oldy, show_time, prob, show_prob, probnum,
        selectedprobs,dif=0;


    vis_sheet("Time") -> show_time;
    vis_sheet('Show problem') -> show_prob;

    if show_prob then
        [% for probnum from 1 to length(vis_probs) do
                if selection_sheet(probnum) then
                    make_problem_label(vis_probs(probnum));
                endif;
            endfor; %] -> selectedprobs;
        1 -> probnum;
    endif;

    rc_start();
    rc_3d_init();
    rc_3d_unitcube();
    rc_3d_axis(0.1);

    vars xyzlist = ffile(file);

    foreach [?x ?y ?z] in xyzlist do
        min(x0,x) -> x0;
        max(xscale,x) -> xscale;
        min(y0,y) -> y0;
        max(yscale,y) -> yscale;
        min(z0,z) -> z0;
        max(zscale,z) -> zscale;
    endforeach;

    1.0/(xscale-x0) -> xscale;
    1.0/(yscale-y0) -> yscale;
    1.0/(zscale-z0) -> zscale;

    vars time =0, endpoints = [0 ^^hidden_endpoints];

    foreach [?x ?y ?z] in xyzlist do
        xscale * (x-x0) -> x;
        yscale * (y-y0) -> y;
        zscale * (z-z0) -> z;

        if member(time,endpoints) then
            if show_time then
                rc_3d_jumpto(x,y,z);
                rc_print_here(''><(time-dif));
            endif;
            if time > 1 and show_prob then
                rc_print_here(selectedprobs(probnum));
                probnum+1->probnum;
            endif;
            dif+time->dif;
            rc_3d_to_2d(x,y,z) -> (x,y);
            x -> oldx; y->oldy;
        else
            rc_3d_to_2d(x,y,z) -> (x,y);
            rc_arrow_line(oldx,oldy,x,y,1.0);
            x->oldx;y->oldy;
            ;;;    rc_3d_drawto(x,y,z);
            if show_time then rc_print_here(''><(time-dif)); endif;
        endif;

        time+1->time;


    endforeach;

    if show_prob then
        rc_print_here(selectedprobs(probnum));
    endif;

    vars lab_off = -0.05;
    rc_3d_jumpto(0.5,lab_off,lab_off); rc_print_here(''><pca1);
    rc_3d_jumpto(lab_off,0.5,lab_off); rc_print_here(''><pca2);
    rc_3d_jumpto(1-lab_off,lab_off,0.5); rc_print_here(''><pca3);

    rc_print_at(-30,370,''><netfile);

    if old_xyzlist = [] then
        true -> propsheet_field_sensitive(vis_sheet,'Last PCA');
    endif;

    copytree(hidden_endpoints) -> old_hidden_endpoints;
    copytree(xyzlist) -> old_xyzlist;
    pca1 -> old_pca1;
    pca2 -> old_pca2;
    pca3 -> old_pca3;
    netfile -> old_netfile;

enddefine;

define twoD_pca_plot(file,pca1,pca2);

    vars x,y, rcg_ax_type, rcg_pt_type, oldx, oldy, rc_arrow_length, region,
        xwidth, ywidth;

    vars time =0, endpoints = [0 ^^hidden_endpoints];
    vars xylist = ffile(file);

    ;;; Find limit on data so we can calculate the size of the arrow head!
    false -> rcg_newgraph;  ;;; don't clear window
    false -> rcg_pt_type;   ;;; don't plot data
    false -> rcg_ax_type;   ;;; don't draw axes
    undef -> rcg_win_reg;   ;;; don't change scale
    rc_graphplot2(xylist,' ',' ') -> region;

    region(2)-region(1) -> xwidth;
    region(4)-region(3) -> ywidth;
    max(xwidth,ywidth)/30 -> rc_arrow_length;

    0.2 -> rcg_ax_space;
    true -> rcg_newgraph;
    "line" -> rcg_pt_type;
    "box" -> rcg_ax_type;
    0.1 -> rcg_win_reg;

    procedure(x,y);
        if member(time,endpoints) then
            x->oldx; y->oldy;
        else
            rc_arrow_line(oldx,oldy,x,y,1.0);
            x->oldx; y->oldy;
        endif;
        time + 1 -> time;
    endprocedure -> rcg_pt_type;

    rc_graphplot2(xylist,'PC'><pca1,'PC'><pca2) ->;

    rc_print_at(region(1)+xwidth/2.5,region(4)+0.05/ywidth,''><netfile);

enddefine;


define make_pca_window;
    lvars width=500, height=500, xloc=550, yloc=350, setframe=true;
    lvars old = false;

    say('Creating PCA window...');

    if xt_islivewindow(rc_window) then
        rc_window -> old;
    endif;

    width -> rc_window_xsize; height ->rc_window_ysize;
    xloc -> rc_window_x; yloc -> rc_window_y;

    if setframe then
        0 ->> rc_xmin -> rc_ymin;
        width -> rc_xmax; height -> rc_ymax;

        ;;; set origin in middle of window, y increasing upwards
        rc_set_coordinates(
            rc_window_xsize >> 1, rc_window_ysize >> 1, 1, -1);

        0 ->> rc_xposition ->> rc_yposition -> rc_heading;
    endif;

    xt_new_window(
        'PCA',
        rc_window_xsize, rc_window_ysize,
            rc_window_x, rc_window_y) -> rc_window;

    XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-140-*-*-p-*-iso8859-1')->;
    rc_start();
    rc_context(false) -> pca_context;
enddefine;



define make_gobi_colours(list);
    lvars cdev = fopen(vis_colours,"w"),
        gdev = fopen(vis_glyphs,"w"), colour, c;
    vars lab, op, atr;
    for lab in list do
        hd(lab) -> lab;
        xgobi_default_colour -> colour;
        xgobi_default_code -> c;
        foreach [?op ?atr] in xgobi_map do
            if issubstring(op,lab) then
                atr(1) -> colour;
                atr(4) -> c;
                quitloop;
            endif;
        endforeach;
        fputstring(cdev,''><colour);
        fputstring(gdev,''><c);
    endfor;
    fclose(cdev);
    fclose(gdev);
enddefine;

define pca;
    vars threshold, timeout, pca1, pca2, pca3, threeD, plot_data,
        rcg_pt_type, rcg_ax_type = "box", xydata, end_point,
        file_string, file, phead, problem, i, op, start_point, points,
        netfile = sys_fname_nam(pdp3_wtsfile(net));

    if vis_hidden = [] then
        say('Recording hidden vectors...');
        task_sheet('Time out') -> timeout;
        strnumber(task_sheet('Activity threshold')) -> threshold;
        record_hidden(net,timeout,threshold,vis_probs)
                -> (vis_hidden, vis_names);
        say('Saving to file...');
        vis_hidden -> ffile(vis_hidfile);
        vis_names -> ffile(vis_namefile);
        make_gobi_colours(vis_names);
        say('');
    endif;

    say('RUNNING PCA...');

    vis_sheet('Pca1') -> pca1;
    vis_sheet('Pca2') -> pca2;

    ;;; remove anything left by last PCA run
    sysobey('rm -f '><vis_hidfile><'.principal_* '><vis_pcafile);

    if vis_sheet("DrawMethod") = "rc_graphic" then
        if pca_context = false then
            make_pca_window();
        else
            pca_context -> rc_context();
        endif;
    endif;

    if (vis_sheet('3D')->>threeD) and vis_sheet("DrawMethod") = "rc_graphic"
    then

/*
-- -- 3D Plotting code ------------------------------------------------
        */


        vis_sheet('Pca3') -> pca3;
        sysobey('pca -f '><vis_hidfile><
            ' -x '><pca1><' -y '><pca2><' -z '><pca3><' > '><vis_pcafile);

        threeD_pca_plot(vis_pcafile,pca1,pca2,pca3);

    else

/*
-- -- 2D trajectory code ------------------------------------------------
        */

        if vis_sheet("DrawMethod") = "xgraph" then

            sysobey('pca -f '><vis_hidfile>< ' -x '><pca1><' -y '
                ><pca2><' > '><vis_pcafile);

            ffile(vis_pcafile) -> xydata;

            copy(hidden_endpoints) -> points;
            1 -> start_point;
            '' -> file_string;

            [% for problem in vis_probs do

                    make_problem_label(problem) -> phead;

                    ;;; Only show selected problems
                    if selection_sheet(phead) = false then
                        ;;; do nothing
                    else

                        [];
                        [% '\"'><phead><'\"'; %];

                        unless points = [] then
                            dest(points) -> points -> end_point;
                            for i from start_point to end_point do
                                [% xydata(i)(1); xydata(i)(2); hd(vis_names(i)); %];
                            endfor;
                            end_point+1 -> start_point;
                        endunless;
                    endif;
                endfor; %] -> ffile(vis_pcafile);

            sysobey(' xgraph -tk -bb -P -t \"PCA for ' >< netfile ><
                '\" -x \"PC '><(pca1)><'\" -y \"PC '>< (pca2)><'\" '
                ><vis_pcafile><' &');


        else ;;; Using rcgraphic

            sysobey('pca -f '><vis_hidfile>< ' -x '><pca1><' -y '
                ><pca2><' > '><vis_pcafile);

            twoD_pca_plot(vis_pcafile,pca1,pca2);

        endif;


    endif;


    say('Done');
    paper_context -> rc_context();

enddefine;

/*
-- CLUSTER ------------------------------------------------------------
*/

define cluster;
    vars threshold, timeout, netfile = sys_fname_nam(pdp3_wtsfile(net));

    if vis_hidden = [] then
        say('Recording hidden vectors...');
        task_sheet('Time out') -> timeout;
        strnumber(task_sheet('Activity threshold')) -> threshold;
        record_hidden(net,timeout,threshold,vis_probs) -> (vis_hidden, vis_names);
        say('Saving to file...');
        vis_hidden -> ffile(vis_hidfile);
        vis_names -> ffile(vis_namefile);
        say('');
    endif;

    say('RUNNING CLUSTER...');

    sysobey('cluster -g '><vis_hidfile><' '><vis_namefile><
            ' | xgraph -tk -bb -t \"Cluster for '>< netfile
            ><'\" -x distance -y distance &');

    say('Done');

enddefine;


/*
-- VISUALIZATION CONTROLS ---------------------------------------------
*/

define vis_control(sheet, field, value) -> value;
    vars file, time_out, vis_type, extract_method;

    vis_sheet('FSM Method') -> extract_method;

    if extract_method = "Quantize" then
        vis_sheet('Quantization') -> fsm_similarity_threshold;
    else
        strnumber(vis_sheet('Similarity')) -> fsm_similarity_threshold;
    endif;

    if vis_probs = [] then
        say('No problems loaded');
        return;
    endif;

    vis_sheet("Graph")-> vis_type;

    unless ispdp3_net_record(net) then
        say('No network loaded');
        return;
    endunless;

    task_sheet('Time out') -> time_out;

    if  value = 'Draw' then

        if vis_type = "fsm" then
            draw_fsm();
        elseif vis_type = "cda" then
            cda();
        elseif vis_type = 'min fsm' then
            minimize_fsm();
        elseif vis_type = "pca" then
            pca();
        elseif vis_type = "cluster" then
            cluster();
        endif;
    endif;

enddefine;



/*
-- Solving problems ---------------------------------------------------
*/

define ready_for_problem -> (task, first_number, second_number);

    task_sheet("Operation") -> task;

    if task = "+" then
        say('Adding...please wait');
    else
        say('Multiplying...please wait');
    endif;

    task_sheet('First row') -> first_number;
    task_sheet('Second row') -> second_number;

    [^task ^first_number ^second_number] -> current_problem;
    set_problem([^task ^first_number ^second_number]) -> PAGE;

    rc_start();
    xshow(PAGE);

enddefine;

define solve_problem;
    vars first_number, second_number, task;

    blank_netsheet();
    say('Solving...');
    ready_for_problem() -> (task, first_number, second_number);

    task_sheet('Time out') -> time_out;
    strnumber(task_sheet('Activity threshold')) -> threshold;

    runnet(net, time_out, threshold) -> (Solution,reason);

    length(Solution) -> solution_time;

    xdraw(Solution,solution_time);
    solution_time -> solution_position;

    say(reason>< ' in '><solution_time><' steps.');
enddefine;

/*
-- Correct solutions --------------------------------------------------
*/

define correct_solution;
    vars first_number, second_number, task;

    blank_netsheet();
    say('Finding correct solution...');

    ready_for_problem() -> (task, first_number, second_number);

    if task = "+" then
        correct_run(addition) -> Solution;
    else
        correct_run(multiplication) -> Solution;
    endif;

    length(Solution) -> solution_time;

    xdraw(Solution,solution_time);
    solution_time -> solution_position;

    say(solution_time><' steps.');
enddefine;


define solve_commands(sheet, field, value) -> value;

    if field = "Forward" then

        if Solution = false then
            say('Need to SOLVE first');
        else
            say('');
            min(solution_time,solution_position + 1) -> solution_position;
            xdraw(Solution,solution_position);
            update_outputsheet();
        endif;

    elseif field = "Backward" then
        if Solution = false then
            say('Need to SOLVE first');
        else
            say('');
            max(1,solution_position -1) -> solution_position;
            xdraw(Solution,solution_position);
            update_outputsheet();
        endif;

    elseif field = "Solve" then
        if ispdp3_net_record(net) then
            say('');
            solve_problem();
        else
            say('Load a network first');
        endif;

    elseif field = "Record" then
         if Solution = false then
            say('Need to SOLVE first');
        else
            say('Recording...');
            spew_sequence();
        endif;

    elseif field = "Restart" then
        if Solution = false then
            say('Need to SOLVE first');
        else
            say('');
            1 -> solution_position;
            xdraw(Solution,1);
        endif;

    elseif field = "Correct" then
            say('');
        correct_solution();

    endif;

enddefine;




/*
-- LATEX CODE ---------------------------------------------------------
*/

define latex_problem(sheet, name, value ) -> value;
    vars file = task_sheet('LaTeX file');

    if file = '' then
        say('Specify a file');
        return;
    endif;

    pdp3_adddot(file,'tex') -> file;
    sysfileok(file) -> file;

    file -> task_sheet('LaTeX file');

    if name = "LaTeX" then

        if (Solution = []) or (Solution = false) then
            say('Use SOLVE first');
            return;
        endif;

        if readable(file) then
            say('Appending...');
        else
            say('Writing...');
        endif;

        fopen(file,"a") -> dev;
        fputstring(dev,'% Problem: '><
            task_sheet('First row') ><' '><
            task_sheet("Operation") ><' '><
            task_sheet('Second row') );
        if last(Solution)(3) = {0} then
            fputstring(dev,'% Correct solution');
        else
            fputstring(dev,'% Weights: '><
                pdp3_wtsfile(net));
            fputstring(dev,'% Network: '><
                pdp3_adddot(file_sheet('Network file'),'net'));
        endif;

        fputstring(dev,'% Step '>< solution_position >< ' of '>< solution_time);
        list_to_tabular(task_sheet("Operation"),Solution(solution_position)(4),dev);

        fclose(dev);

    elseif name = 'Ved tex' then
        say('Editing LaTeX file');
        edit(file);
    endif;

    say('Done');
enddefine;


/*
-- START-UP CODE ------------------------------------------------------
*/

define button_proc(propbox, button) -> accept;
    false -> accept;

    blank_netsheet();

    if button = "Quit" then
        true -> accept;
        sysobey('rm -f '><vis_hidfile><'.*'><' '><vis_namefile><'*');
        propsheet_destroy(propbox);
        propsheet_destroy(selection_box);
        propsheet_destroy(colour_box);
        rc_destroy_context(paper_context);
        unless fsm_context = false then rc_destroy_context(fsm_context); endunless;
        unless pca_context = false then rc_destroy_context(pca_context); endunless;
    elseif button == "Reset" then
        propsheet_reset(propbox, true);

    elseif button == "Apply" then
        propsheet_apply(propbox, true);
        propsheet_save(propbox, true);

    elseif button == "Refresh" then
        propsheet_refresh(propbox, true);

    endif;

enddefine;



define xrunnet;
    vars i,name;

    false ->> machine ->> minimized_machine ->> net
        ->> Solution ->> pca_context -> fsm_context;
    [] ->> old_xyzlist ->> vis_probs -> vis_hidden;

    ;;; Start 'Paper' windows

    xt_new_window('PAPER', 250, 250, 900, 10) -> rc_window;
    1 -> rc_yscale; 1 -> rc_xscale;
    20 -> rc_xorigin; 10 -> rc_yorigin;
    rc_start();
    XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-140-*-*-p-*-iso8859-1')->;
    rc_context(false) -> paper_context;

    propsheet_new_box('PROBLEM SELECTION',false,selection_buttons,
        [Next 'All on'  'All off' Solve Dismiss]) -> selection_box;

    propsheet_new('Problems', selection_box, []) -> selection_sheet;

    ;;; Start prop sheet

    propsheet_new_box('NETWORK CONTROL',false,button_proc,
        [Apply Reset Refresh Quit ]) -> box;

    propsheet_new('Network Description', box, [
            ['Weights file' ^default_wtsfile (width=30)]
            + ['Next' command (nolabel,accepter=next_network)]
            ['Network file' ^default_netfile (width=30]
            + ['Load' command (nolabel,accepter=load_network)]]) -> file_sheet;

    propsheet_new('Problem', box, [
            [Operation oneof     [x +] ]
            + [Solve command (nolabel,accepter=solve_commands)]
            + [Record command (nolabel,accepter=solve_commands)]
            + [Correct command (nolabel,accepter=solve_commands)]
            + [Output command (nolabel,accepter=plot_vector)]

            ['First row'    '2'
                (width=10,accepter=not_negative,converter=string_number_convert)]
            + [Forward command (nolabel,accepter=solve_commands)]
            + [Backward command (nolabel,accepter=solve_commands)]
            + [Restart command (nolabel,accepter=solve_commands)]

            ['Second row'   '9'
                (width=10,accepter=not_negative,converter=string_number_convert)]
            + ['LaTeX file' 'probs.tex' (width=15)]
            + [LaTeX command (nolabel,accepter=latex_problem)]
            + ['Ved tex'  command (nolabel,accepter=latex_problem)]

            ['Activity threshold' '0.0'
                (accepter=numbers_only,width=15)]
            + ['Time out' 1-300 (default=100,width=30)]

            ['Problems file' ^default_problemsfile (width=15)]
            + [Load command (nolabel,accepter=vis_edit_probs)]
            + ['Ved probs' command (nolabel,accepter=vis_edit_probs)]
            + [Selection command (nolabel,accepter=show_selection)]

        ]) -> task_sheet;


    propsheet_new('Network state', box, [
            ['Input'        message '' (width=30)]
            ['Output'       message '' (width=30)]
            ['Step'         message '' (width=30)]
            ['Messages'     message '']
            ['Show error'   false   ]
            + [Error       message '' (width=10)]
            + [Closest     message '' (width=10)]
        ]) -> net_sheet;



    propsheet_new('Visualization', box, [

            ['Similarity' '0.05' (accepter=numbers_only,width=15)]
            + ['Quantization' 4 (width=15)]
            + ['FSM Method' menuof [Maskara Quantize] (nolabel,
                accepter=extract_method_sensitivity)]

            ['Show problem' false (accepter=re_record)]
            + [Time true (accepter=re_record)]
            + ['Input or output' menuof [output input neither both] (accepter=re_record)]
            + [Colours command (nolabel,accepter=show_xgobi)]

            [Graph menuof [pca cda cluster fsm 'min fsm']
                (accepter=pca_sensitivity,nolabel)]
            + [Draw command (nolabel,accepter=vis_control)]
            + ['Last PCA' command (nolabel,accepter=re_draw_3d_pca)]
            + [Xgobi command (nolabel,accepter=start_xgobi)]

            ['Pca1' 0 (width=10,accepter=not_negative)]
            + ['Graph file' '' (width=15)]
            + ['Xgobi 3pc' command (nolabel,accepter=start_xgobi_pca)]

            ['Pca2' 1 (width=10,accepter=not_negative)]
            + ['Graph output' menuof ['PS Print' 'Save' 'PS Save']
                (accepter=save_graph)]

            ['Pca3' 2 (width=10,accepter=not_negative)]
            + ['3D' false (accepter=threeD_sensitivity)]
            + [DrawMethod oneof [xgraph rc_graphic]
                    (accepter=method_sesitivity,nolabel)]


            [Home command (nolabel,accepter=rotate_home)]
            + [x -15 (width=10,accepter=rotate)]
            + [y 25 (width=10,accepter=rotate)]
            + [z 0 (width=10,accepter=rotate)]

        ]) -> vis_sheet;


    propsheet_new_box('XGOBI',false, gobi_buttons, [Apply Dismiss])
        -> colour_box;

    propsheet_new('Colour and glyph map', colour_box,
        [ [Operation menuof ^op_list (accepter=xgobi_op_details)]
          [Colour    menuof ^colour_list]
          [Glyph     menuof ^glyph_types]
          [Size      menuof ^glyph_size] ]) -> colour_sheet;

    extract_method_sensitivity(true,true, "Maskara") ->;
    pca_sensitivity(true,true,"pca")->;
    false -> propsheet_field_sensitive(vis_sheet,'Last PCA');

    propsheet_show([% file_sheet, task_sheet, net_sheet, vis_sheet, box %]);



enddefine;

xrunnet();
