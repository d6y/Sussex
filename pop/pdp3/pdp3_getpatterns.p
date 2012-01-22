/*
    PDP3_GETPATTERNS.P

    Author:  Richard Dallaway, September 1991
    Purpose: Read PDP pattern file into POP-11
    Version: Thursday 10 September 1992

 */

define pdp3_getpatterns(patfile,npats,network) -> pats;
    vars skipping=false, neg_bits, bit, waiting, seq,nhid,inlines,outlines,
        first_feedback, last_feedback, inbits, outbits, h, feedback, extinlines;

    if network = true then
        (patfile,npats,network) -> (patfile,npats,network,skipping);
    endif;

    if ispdp3_net_record(network) then
        pdp3_nunits(net) - (pdp3_nout(net) + pdp3_nin(net)) -> nhid;
        pdp3_nin(net) -> inlines;
        pdp3_nout(net) -> outlines;

        if pdp3_style(net) = "srn" then
            inlines -> first_feedback;
            first_feedback + (nhid-1) -> last_feedback;
            inlines - nhid -> extinlines;

        elseif isword(pdp3_style(net)) then
            mishap('PDP3_GETPATTERNS:  Unknown network style',
                [% pdp3_style(net); pdp3_wtsfile(net); %]);
        endif;

    else

        (patfile, npats, network, skipping) -> (patfile, npats, inlines, outlines);

        ;;; Skip over second field in each line if given <true> as
        ;;; additional argument

        if outlines = true then
            inlines -> outlines;
            npats -> inlines;
            patfile -> npats;
                -> patfile;
            true -> skipping;
        else
            false -> skipping;
        endif;


    endif;

    pdp3_adddot(patfile,'pat') -> patfile;
    vars pdev = fopen(patfile,"r");

    if pdev = false then
        mishap('PDP3_GETPATTERNS: Can\'t open file',[^patfile]);
    endif;

    fstringsize(pdev,pdp3_maximum_pattern_size);

    lvars i,p, last_inline = inlines+1, first_targ = inlines+2,
        last_targ = inlines+1+outlines, first_inline = 2,
        expected_line_length;


    inlines + outlines + 1 -> expected_line_length;

    if skipping then  ;;; skip over 2nd value
        last_inline + 1  -> last_inline;
        first_targ + 1 -> first_targ;
        last_targ + 1 -> last_targ;
        first_inline + 1 -> first_inline;
        1 + expected_line_length -> expected_line_length;
    endif;

    vars pat = newarray([1 ^npats 1 ^inlines]);
    vars patnames = newarray([1 ^npats]);
    vars targ = newarray([1 ^npats 1 ^outlines]);
    vars line, offset = first_inline-1;

    false -> waiting;

    [% 1;   ;;; always note the start of the first sequence

        fast_for p from 1 to npats do

            fgetstring(pdev) -> line;
            if line = termin then
                mishap('PDP3_GETPATTERNS: Unexpected end of file in '><patfile,
                    [pattern number ^p]);
            endif;

            stringtolist(line) -> line;

            if line matches [??inbits * ??outbits] then
                [% fast_for h from first_feedback to last_feedback do
                        pdp3_initialcontext;
                    endfast_for; %] -> feedback;
                [^^inbits ^^feedback ^^outbits] -> line;

            elseif member(":",line) then

                [% fast_for i from 1 to extinlines+1 do
                        line(i);
                    endfast_for;
                    fast_for h from first_feedback to last_feedback do
                        -h;
                    endfast_for;
                    fast_for h from i+1 to length(line) do
                        line(h);
                    endfast_for;
                %] -> line;
            endif;

            if length(line) > expected_line_length then
                mishap('PDP3_GETPATTERNS: Pattern too long', line);
            elseif length(line) < expected_line_length then
                mishap('PDP3_GETPATTERNS: Pattern too short', line);
            endif;

            line(1) -> patnames(p);

            false -> neg_bits;
            fast_for i from first_inline to last_inline do
                line(i) -> bit;
                bit -> pat(p,i fi_- offset);
                if bit < 0  then ;;; recurrent connection
                    true -> waiting;
                    true -> neg_bits;
                endif;
            endfast_for;

            if waiting and not(neg_bits) then ;;; start of new sequence
                false -> waiting;
                p;
            endif;

            fast_for i from first_targ to last_targ do
                line(i) -> targ(p,i fi_- last_inline);
            endfast_for;

        endfast_for;

    %] -> seq;

    ;;; Check for any remaining data
    check_for_remains(pdev) -> line;
    fclose(pdev);
    unless line = false then
        mishap('PDP3_GETPATTERNS: End of file not reached in '><patfile,
            [^line]);
    endunless;

    conspdp3_pats_record(patfile,pat,targ,patnames, seq,
        npats,inlines,outlines) -> pats;

    unless pdp3_dont_auto_setpoints then
        npats ->> Number_of_patterns -> Last_pattern;
        1 -> First_pattern;
    endunless;

enddefine;

define pdp3_patternnumber(n,pats) -> n;
    vars found,i;

    if isstring(n) then
        consword(n) -> n;
    endif;

    if isword(n) then ;;; convert pattern name to number
        false -> found;
        fast_for i from 1 to pats.pdp3_npats do
            if (pats.pdp3_stimnames)(i) = n then
                i -> n;
                true -> found;
                quitloop;
            endif;
        endfast_for;
    elseif n > pats.pdp3_npats or n < 1 then
        mishap('PDP3_PATTERNNAME: No such pattern number',[^n]);
    endif;


    if found = false then
        mishap('PDP3_PATTERNNUMBER: Pattern name not recognized',[^n]);
    endif;

enddefine;


define pdp3_selectpattern(n,pats) -> (stim, targ);
    vars i,stim,targ;

    pdp3_patternnumber(n,pats) -> n;

    {% fast_for i from 1 to pats.pdp3_inlines do
            (pats.pdp3_stims)(n,i);
        endfast_for; %} -> stim;

    {% fast_for i from 1 to pats.pdp3_outlines do
            (pats.pdp3_targs)(n,i);
        endfast_for; %} -> targ;
enddefine;

define pdp3_printpatsnum(number);
    vars labwidth = pdp3_printpats_d1 + pdp3_printpats_d2;
    if pdp3_printpats_numbers then
        prnum(number,pdp3_printpats_d1,pdp3_printpats_d2);
    else
        if number = 1 then pr_field('*',labwidth,' ',' ');
        elseif number >= 0.5 and number < 1.0 then
            pr_field('=',labwidth,' ',' ');
        elseif number < 0.5 and number >= 0.05 then
            pr_field('-',labwidth,' ',' ');
        else
            pr_field('',labwidth,' ',false);
        endif;
    endif;
enddefine;


define pdp3_headlabel(width,string);

    if width <= (length(string)+2) then
        pr(substring(1,width,string));
    else
        pr('|');
        width - 2 -> width;

        while length(string) < width do
            '-' >< string -> string;
            quitif(length(string)=width);
            string >< '-' -> string;
        endwhile;
        pr(string);
        pr('|');
    endif;
enddefine;


define pdp3_printpatterns(pats);
    vars npats, p , nout, o, nin, i, printlabel, unit,
        type, labwidth, inputs, outputs, names;

    dlocal poplinemax  poplinewidth;
    100000 ->> poplinemax -> poplinewidth;

    pdp3_printpats_d1 + pdp3_printpats_d2 -> labwidth;

    if isprocedure(pats) then   ;;; naming procedure
        pats -> printlabel;
             -> pats;
    else
        procedure(unit, type);
            substring(1,1,type) >< unit;
        endprocedure -> printlabel;
    endif;

    pats.pdp3_inlines -> nin;
    pats.pdp3_outlines -> nout;
    pats.pdp3_stims -> inputs;
    pats.pdp3_targs -> outputs;
    pats.pdp3_stimnames -> names;
    pats.pdp3_npats -> npats;

    pr('\nPatterns: '><(pats.pdp3_patsfile)><'\n\n');

    pr_field('',pdp3_printpats_d0,' ',false);
    pdp3_headlabel(2+labwidth*nin,pdp3_printpats_inputstr);
    pdp3_headlabel(2+labwidth*nout,pdp3_printpats_targetstr);
    nl(1);

    pr_field('',pdp3_printpats_d0+1,' ',false);
    fast_for i from 1 to nin do
        printlabel(i,"input") -> unit;
        pr_field(''><unit, labwidth, ' ', ' ');
    endfast_for;
    pr('  ');
    fast_for o from 1 to nout do
        printlabel(o,"target") -> unit;
        pr_field(''><unit, labwidth, ' ', ' ');
    endfast_for;
    nl(1);

    fast_for p from 1 to npats do
        pr_field(names(p),pdp3_printpats_d0,false,'  ');

        fast_for i from 1 to nin do
            pdp3_printpatsnum(inputs(p,i));
        endfast_for;
        pr('  ');
        fast_for o from 1 to nout do
            pdp3_printpatsnum(outputs(p,o));
        endfast_for;
        nl(1);
    endfast_for;

enddefine;

;;; Returns a list of end points
define pdp3_seqend(pats);
    lvars s, seqstart=pdp3_seqstart(pats), nseq = length(seqstart);
    [% fast_for s from 1 to nseq-1 do seqstart(s+1)-1;; endfast_for;
        pdp3_npats(pats); %];
enddefine;
