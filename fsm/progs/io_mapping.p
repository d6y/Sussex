
define io_mapping(problem);
    vars solution, action, stimulus, junk, file = false, dev, printer=false,
        linestring;

    lvars linenumber;

    if isstring(problem) then
        (problem) -> (problem,file);
        if file = 'lpr' then
            systmpfile('/tmp','iomap','.tmp') -> file;
            true -> printer;
            vedputmessage('Printing...');
        else
            vedputmessage('Writing to file...');
        endif;
    endif;


    unless file = false  then
        fopen(file,"w") -> dev;
    endunless;

    set_problem(problem) -> PAGE;
    if problem(1) = "x" then
        [% multiplication(); %] -> solution;
    else
        [% addition(); %] -> solution;
    endif;

    set_problem(problem) -> PAGE;
    init_vars();

    if file = false then
        pr('I/O mapping for '><problem); nl(2);
    endif;

    1 -> linenumber;

    for action in solution do

    if linenumber > 9 then
        ' ' >< linenumber >< ' ' -> linestring;
    else
        ' ' >< linenumber >< '  ' -> linestring;
    endif;

    linenumber + 1 -> linenumber;

        code_input(true,1) -> (stimulus, junk);
        if file then
            finsertstring(dev,stimulus><' ');
;;;            finsertstring(dev,'-> ');
            finsertstring(dev,linestring);
            finsertstring(dev,perform_action(action));
            fnewline(dev);
        else
            spr(stimulus);
;;;            spr('-> ');
            spr(linestring);
            spr(perform_action(action));
            nl(1);
        endif;
    endfor;

    unless file = false then
        fclose(dev);
        if printer /= false then
            sysobey('lpr -h -T \"'><problem><'\" -p -Psqa '><file);
            sysdelete(file)->;
        endif;
    vedputmessage('Done');
    endunless;

enddefine;


define io_list(problem);
    vars solution, action, stimulus, junk;

    set_problem(problem) -> PAGE;
    if problem(1) = "x" then
        [% multiplication(); %] -> solution;
    else
        [% addition(); %] -> solution;
    endif;

    set_problem(problem) -> PAGE;
    init_vars();

    [% for action in solution do
        code_input(true,1) -> (stimulus, junk);
        [% stimulus;
        perform_action(action); %];
    endfor; %];
enddefine;
