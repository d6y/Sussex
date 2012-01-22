/*
    PDP3_GETWEIGHTS.P

    Author:  Richard Dallaway, September 1991
    Purpose: Reads a set of M&R BP weights into POP-11.
    Version: Wednesday 9 September 1992
*/

define pdp3_firstoutputunit(net);
    (net.pdp3_nunits) - (net.pdp3_nout);
enddefine;

define pdp3_setpoints(net);
    vars nin = pdp3_nin(net), nout = pdp3_nout(net), nu = pdp3_nunits(net);
    0 ->> First_unit -> First_input_unit;
    nin - 1 -> Last_input_unit;
    nin -> First_hidden_unit;
    nu - nout -> First_output_unit;
    nu - 1 ->> Last_output_unit -> Last_unit;
    First_output_unit - 1 -> Last_hidden_unit;
enddefine;

;;; Reads a section of a file <dev> between <start_string> and
;;; <end_string> (or EOF) returning the lines between in the <list>

define pdp3_readfilesection(dev,start_string,end_string) -> list;
    vars line;
    repeat
        fgetstring(dev) -> line;
    quitif(line=start_string or line=termin);
    endrepeat;

    if line = termin then
        mishap('PDP3_READFILESECTION: End of file before '><start_string,[^dev]);
    endif;

    [% repeat
            fgetstring(dev) -> line;
        quitif(line=end_string or line=termin);
            stringtolist(line);
        endrepeat; %] -> list;
enddefine;


define pdp3_getweights(connectivity,wtfile) -> net;

    vars i,j, wtdev, biases, netinput, senders, lines, block, dev,
        units, connections, nunits, nin, nout, receive_start,
        receive_length, send_start, send_length, weights, senders,
        last_unit, last_send, last_receive, activity, style, nhid, ncontext,
        netstyle;

    if isstring(connectivity) then  ;;; scan .net file for details

        pdp3_adddot(connectivity,'net') -> connectivity;
        fopen(connectivity,"r") -> dev;

        if dev = false then
            mishap('PDP3_GETWEIGHTS: Can\'t open network file',[^connectivity]);
        endif;

        fstringsize(dev,100);

        pdp3_readfilesection(dev,'definitions:','end') -> units;
        pdp3_readfilesection(dev,'network:','end') -> connections;
        fclose(dev);

        units --> [==[nunits ?nunits]==];
        units --> [==[ninputs ?nin]==];
        units --> [==[noutputs ?nout]==];

        if connections matches  [[style ?style]] then
            if style = "srn" then
                style -> netstyle;
                nunits - (nin+nout) -> nhid;
                nhid/2 ->> nhid -> ncontext;
                nin + nhid -> nin;
                {   {% nin; nhid; 0; nin; %}
                    {% (nin+nhid); nout; nin; nhid; %}
                } -> connectivity;

            else
                mishap('PDP3_GETWEIGHTS: Unknown style',[^style]);
            endif;

        else

        {% for line in connections do
                {% line(3); line(4); line(5); line(6); %};
            endfor; %} -> connectivity;

        endif;

    else    ;;; network details provided by user

            -> (nunits, nin, nout);

    endif;

    nunits-1 -> last_unit;
    newarray([0 ^last_unit 0 ^last_unit],0.0) -> weights;
    newarray([0 ^last_unit],0.0) -> biases;
    newarray([0 ^last_unit],0.0) -> netinput;
    newarray([0 ^last_unit],0.0) -> activity;
    newarray([0 ^last_unit],{}) -> senders;

    for block in connectivity using_subscriptor subscrv do

        block(1) -> receive_start;
        block(2) -> receive_length;
        block(3) -> send_start;
        block(4) -> send_length;

        send_start+send_length-1 -> last_send;
        receive_start+receive_length-1 -> last_receive;

        {% fast_for i from send_start to last_send do
                i; endfast_for; %} -> lines;

        fast_for j from receive_start to last_receive do
            copy(lines) -> senders(j);
        endfast_for;

    endfor;

    ;;; Read R+M backprop net weights and biases file

    pdp3_adddot(wtfile,'wts') -> wtfile;
    vars wtdev = fopen(wtfile,"r");

    if wtdev = false then
        mishap('PD3_GETWEIGHTS - Can\'t open weights file',[^wtfile]);
    endif;

    fstringsize(wtdev,100);

    ;;; WEIGHTS

    fast_for j from 0 to last_unit do
        for i in senders(j) using_subscriptor subscrv do
            strnumber(fgetstring(wtdev)) -> weights(i,j);
        endfor;
    endfast_for;

    ;;; BIAS

    fast_for i from 0 to last_unit do
        strnumber(fgetstring(wtdev)) -> biases(i);
    endfast_for;

    ;;; check for any unread  weights
    check_for_remains(wtdev) -> line;
    fclose(wtdev);
    unless line = false then
        mishap('PDP3_GETWEIGHTS: End of file not reached in '><wtfile,[^line]);
    endunless;

    conspdp3_net_record(wtfile, nunits, nin, nout, weights, connectivity,
        senders, netinput, activity, 0.5, 1.0, netstyle, biases) -> net;

    unless pdp3_dont_auto_setpoints then
        pdp3_setpoints(net);
    endunless;

enddefine;

define pdp3_printweights(net);
    vars i,h,block,d1=pdp3_printweights_d1, d2=pdp3_printweights_d2,
        naming,labwidth=d1+d2+1;

    dlocal poplinemax  poplinewidth;
    100000 ->> poplinemax -> poplinewidth;

    ;;; naming procedure?
    if isprocedure(net) then
        net -> naming;
        -> net;
    endif;

    vars nunits = net.pdp3_nunits, weights = net.pdp3_weights,
        biases = net.pdp3_biases, receive_start, receive_length,
        send_start, send_length, label;

    define label_node(unit) -> label;
        if isprocedure(naming) then
            naming(unit,net) -> label;
        else
            unit -> label;
        endif;
    enddefine;

    pr('\nWeights: '><(net.pdp3_wtsfile)><'\n\n');

    for block in net.pdp3_connectivity using_subscriptor subscrv do

        block(1) -> receive_start;
        block(2) -> receive_length;
        block(3) -> send_start;
        block(4) -> send_length;

        repeat pdp3_printweights_rowspace times
            pr(' ');
        endrepeat;
        pr_field('bias',labwidth,' ',false);
        fast_for i from send_start to send_start+send_length-1 do
            label_node(i) -> label;
            pr_field(''><label,labwidth,' ',' ');
        endfast_for; nl(1);

        fast_for h from receive_start to receive_start+receive_length-1 do
            label_node(h) -> label;
            pr_field(''><label,pdp3_printweights_rowspace,false,' '); pr(' ');
            prnum(biases(h),d1,d2); pr(' ');
            fast_for i from send_start to send_start+send_length-1 do
                prnum(weights(i,h),d1,d2); pr(' ');
            endfast_for; nl(1);
        endfast_for; nl(2);

    endfor;
enddefine;


define pdp3_putweights(net);
    vars filename, dev, last_unit, i, j, biases, weights, senders;

    if isstring(net) then
            net -> filename;
            -> net;
        else
            pdp3_wtsfile(net)->filename;
    endif;

    pdp3_adddot(filename,'wts') -> filename;

    pdp3_nunits(net) - 1 -> last_unit;
    pdp3_biases(net) -> biases;
    pdp3_weights(net) -> weights;
    pdp3_senders(net) -> senders;

    fopen(filename,"w") -> dev;

    ;;; WEIGHTS

    fast_for j from 0 to last_unit do
        for i in senders(j) using_subscriptor subscrv do
            fputstring(dev,''><weights(i,j));
        endfor;
    endfast_for;

    ;;; BIAS

    fast_for i from 0 to last_unit do
        fputstring(dev,''><biases(i));
    endfast_for;

    fclose(dev);

enddefine;

define pdp3_fanin(net,unit) -> fanin;
    vars senders, w, weights;

    if unit < 0 or unit > pdp3_nunits(net)-1 then
        mishap('PDP3_FANIN: Requested unit does not exist',[^unit]);
    endif;

    pdp3_weights(net) -> weights;
    pdp3_senders(net)(unit) -> senders;

    {% for w in senders using_subscriptor subscrv do
            weights(w,unit); endfor; %} -> fanin;
enddefine;


define pdp3_fanout(net,unit) -> fanout;
    vars u, last_unit=(net.pdp3_nunits)-1, nunits, weights, senders;

    if unit < 0 or unit > last_unit then
        mishap('PDP3_FANOUT: Requested unit does not exist',[^unit]);
    endif;

    pdp3_weights(net) -> weights;

    {% fast_for u from 0 to last_unit do
            if member(unit,[% explode(pdp3_senders(net)(u)) %]) then
                weights(unit,u);
            endif;
        endfast_for; %} -> fanout;
enddefine;

define updaterof pdp3_inputactivation(value,net);
    lvars h, nhid;
    fast_for h from 0 to net.pdp3_nin do
        value -> (net.pdp3_activity)(h);
    endfast_for;
enddefine;
