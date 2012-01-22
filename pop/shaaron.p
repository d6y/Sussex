
/* production system for children's multiplication behaviour */

/* Shaaron Ainsworth */

/*********************************************************************/
/* procedures in the intepreter */
/*********************************************************************/

define fire(rule);
    /* .1. fires the consequents of a chosen rule */
    vars rhs lhs mark stuff consequents antecedents;
    rhs(rule)->consequents;
    lhs(rule)->antecedents;
    popval(consequents);
    mark(hd(antecedents));
enddefine;

define convert(setrules) -> rules;
    /* .2. returns rule values from names*/
    maplist(setrules, procedure rule; valof(rule) endprocedure) -> rules
enddefine;

define lhs(rule) -> antecedents;
    ;;; .3. returns the left hand side of a rule
    vars antecedents;
    rule --> [= = ??antecedents => ==];
enddefine;

define rhs(rule) -> consequents;
    ;;; .4. returns the right hand side of a rule
    vars consequents;
    rule --> [== => ??consequents];
enddefine;

define start(topds, botds, set);
    /* .5. reads in the intial value into the database */
    vars examine examine_set asserts prune prules convert interpreter wmno;
    0 ->wmno;
    examine(topds);
    examine(botds);
    examine_set(set);
    [[** ^topds ^botds [] ^(length(topds)) ^(length(botds)) 0 **]]
        ->database;
    asserts([processmult]);     ;;; asserts the first goal into database
    prune(set) ->setrules;
    prules(setrules);
    convert(setrules)->rules;
    interpreter(rules);
enddefine;

define interpreter(rules);
    /* .6. implements the recognise act cycle */
    vars wm stop fire resolve possible choose ;
    until present([wm ?wm [stop]]) do

        choose(rules) ->possible;
        resolve(possible)->rule;
        fire(rule);
    enduntil;
    stop();
enddefine;

define prune(set)-> setrules;
    /* .7. takes a list of rules and removes any duplicates
    if the procedure is modeled by a deletion of a rule makes certain
    that bug combination does not put it back in again */
    lvars delit;
    []->setrules;
    until set = [] do                           ;;; checks whether any
        if issubstring  ('minus', hd(set)) then ;;; deletion bugs present
            substring(6, length(hd(set))-5, hd(set))->delit; ;;; removes minus
            delete(hd(set),tl(set)) ->set;
            consword(delit) ->delit;       ;;; turns string into word to
            delete(delit, set) ->set;      ;;; and removes it if present
            delete(delit,setrules)->setrules;   ;;; elsewhere
            else
            hd(set) :: setrules ->setrules;
            delete(hd(set),tl(set))->set;
        endif;
    enduntil;
enddefine;

define mark(antecedents);
    /* .8. removes all instances of triggers once used */
    vars wm;
    foreach ([wm ?wm [^^antecedents]]) do
        remove([wm ^wm [^^antecedents]]);
    endforeach;
enddefine;

define asserts(item);
    /* .9. places items in working memory after paper represenation and with a
    unique integer to denote recency in working memory */
    vars everything paper;
    lookup ([** ??paper **]);
    lookup ([??everything]);
    remove ([^^everything]);
    wmno + 1 ->wmno;
    add([wm ^wmno ^item]);
    add([^^everything]);
enddefine;

define choose(rules) -> possible;
    /* .10.  makes a list of all rules whose conditions are appropriate */
    vars rule details wm;
    [] -> possible;
    for rule in rules do
        lhs(rule) -> details;
        if present([wm ?wm ^^details]) then
            possible <> [^rule] -> possible;
        endif ;
    endfor;
    if possible = [] then        ;;; if none relevent stop processing
        [[fi: [none_left] => asserts([stop])]] -> possible;
    endif;
enddefine;


define resolve(possible) ->choice;
    /* .11. main procedures for conflict resolution */
    vars recency conset rcount specificity complexity;
    if length(possible) = 1 then
        hd(possible) ->choice;
        else
        recency(possible)->conset; ;;;looks for recently asserted triggers
        if length(conset) = 1 then
            hd(conset) ->choice;
            else
            complexity(conset) ->rcount;  ;;;looks for most complex ante
            if length(rcount) = 1 then
                hd(rcount) ->choice;
                else
                specificity(rcount)->rcount;  ;;; looks for the most specific
                if length(rcount) >= 1 then
                    hd(rcount) ->choice;
                endif;
                if choice = [] then     ;;; if no rules chosen then pick first
                    hd(possible) ->choice;
                endif;
            endif;
        endif;
    endif;
enddefine;


define recency(possible) ->conset;
/* .12. finds the most recently asserted */
vars wm rest store chosen ante rule;
    0 ->store;   [] ->conset;
    foreach [wm ?wm ?rest] do
        if wm > store then
            wm ->store;            ;;; finds highest wm number
            rest ->chosen;         ;;; and its associated trigger
        endif;
    endforeach;
    for rule in possible do
        lhs(rule) ->ante;
        if chosen matches hd(ante) then  ;;; finds rules which match trigger
            rule :: conset ->conset;
        endif;
    endfor;
enddefine;

define complexity(conset) ->rcount;
    /* .13. finds the rule or rules with most number of items in their
     antecedent */
    vars rule rulecount ante anten  nrule rcount;
    [] ->rcount;
    hd(conset) -> rule;
    lhs(rule) ->ante;
    length(hd(ante))->rulecount;
    for nrule in conset do
        lhs(nrule)->anten;
        if length(hd(anten)) > rulecount
            then
            length(hd(anten)) ->rulecount;
        endif;
    endfor;
    for rule in conset do
        lhs(rule) ->anten;
        if length(hd(anten)) < rulecount then
            delete(rule, conset)->conset;
        endif;
    endfor;
    conset ->rcount;
enddefine;

define specificity(rcount) ->rcount;
    /* .14. finds the rules with the least number of questionmarks in
    antecedents */
    vars rule fireante check ante cstore count newcount;
    0 ->count;
    hd(rcount) ->rule;
    lhs(rule) ->fireante;
    check(fireante)->cstore;
    for rule in rcount do
        lhs(rule) ->ante;
        check(ante) -> count;
        if count < cstore then     ;;; finds the least no of questionmarks in
            count ->cstore;        ;;; antecedent
        endif;
    endfor;
    for rule in rcount do
        lhs(rule) ->ante;
        check(ante) ->newcount;           ;;; deletes all rules from the set
        if newcount > cstore then         ;;; with more than the least
            delete(rule, rcount)->rcount; ;;; number of questionmarks
        endif;
    endfor;
enddefine;


define questionmark(item);
/* .15. */
item = "?"
enddefine;



define check(ante)->count;
    /* .16. count how many questionmarks anywhere in the antecedent */
    0 ->count;
    if islist(ante) and ante /= [] then
        check(hd(ante)) + check(tl(ante))->count;
        elseif
        questionmark(ante) then
        1 + count ->count;
    endif;
enddefine;

/*********************************************************************/
/*  print out rules and answers*/
/*********************************************************************/

define prules(setrules);
/* .17. prints the rules being used */
lvars item;
    nl(4);
    sp(5);
    spr('Using rules:');
    for item in setrules do
        spr(item);
    endfor;
    nl(1);
enddefine;

define stop();
    /* .18. prints the result and intermediate stages in multiplication */
    vars row multresult int lengthof amount anything lengthresult result carry
        a_result a_carry item multiplicand multiplier blength tlength;
    if present ([** ?multiplicand ?multiplier ?? anything **]) then
        length(multiplicand) ->tlength;
        length(multiplier) ->blength;
        max(tlength,blength) ->amount;
    endif;
    if present([wm ?wm [?bottom bottom ?multresult]]) then
        max(length(multresult), amount) ->amount;
    elseif present([** ?multiplicand ?multiplier [a_result ?a_result a_carry
                    ?a_carry] length ?lengthof **]) then
        max(length(a_result),amount) ->amount;
    elseif present ([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow
                ?carry **]) then
        max(length(result), amount) ->amount;
    endif;
    sp(28 - amount);
    vedcolumn ->int;
    nl(1);
    sp(30 + amount - (tlength*2));
    for item in multiplicand do
        spr(item);
    endfor;
    nl(1);
    sp(28 + amount -(blength *2));
    pr('x ');
    for item in multiplier do
        spr(item);
    endfor;
    nl(1);
    if present([wm ?wm [row ?row ?multresult]]) then

        sp(int);
        repeat amount times
            pr('--');
        endrepeat;
        nl(1);
        foreach([wm ?wm [row ?row  ?multresult]]) do
            sp(30 + amount -(length(multresult)*2) );
            for item in multresult do
                spr(item);
            endfor;
            nl(1);
        endforeach;
    endif;
    if present([**
                ?multiplicand ?multiplier [a_result ?a_result a_carry
                    ?a_carry]
                length ?lengthof **]) then
        sp(int);
        repeat amount times
            pr('--');
        endrepeat;
        nl(1);
        sp(30 + amount - (length(a_result) * 2));
        for item in a_result  do
            spr(item);
        endfor;
        nl(1);
        sp(int);
        repeat amount times
            pr('--');
        endrepeat;
    elseif present([wm ?wm [?bottomrow bottom ?result]]) then
        sp(int);
        repeat amount times
            pr('--');
        endrepeat;
        nl(1);
        sp(30 + amount -(length(result) * 2));
        for item in result do
            spr(item);
        endfor;
        nl(1);
        sp(int);
        repeat amount times
            pr('--');
        endrepeat;
    elseif present([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow
                ?carry **])then
        sp(int);
        repeat amount times
            pr('--');
        endrepeat;
        nl(1);
        sp(30 + amount - (length(result) * 2));
        for item in result  do
            spr(item);
        endfor;
        nl(1);
        sp(int);
        repeat amount times

            pr('--');
        endrepeat;
    endif;
enddefine;

define examine(input);
    /* .19.  examines numerical input */
    lvars num;
    for num in input do
        unless isinteger(num) and num >= 0 then
            mishap('digits should be both integers and positive',[^num]);
        endunless;
    endfor;
enddefine;

define examine_set(set);
    /* .20. empty set check */
    if set = [] then
        mishap('procedures needed', [^set]);
    endif;
enddefine;


/***************************************************************/
/* begining of the actions for the correct model */
/***************************************************************/

define readintandb();
    /* .21. asserts the current digits into working memory */
    vars toprow bottomrow carry result multiplier multiplicand;
    lookup([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    asserts ([[t ^(multiplicand(toprow))]
            [b ^((rev(multiplier))(bottomrow))]
            [c ^(carry)]]);
enddefine;


define shift_top_left();
    /* .22. shifts left along the top row */
    vars multiplicand multiplier toprow bottomrow carry
        result asserts;
    remove([** ?multiplicand ?multiplier ? result ?toprow ?bottomrow
            ?carry **]);
    toprow - 1 ->toprow;
    add([** ^multiplicand ^multiplier ^result ^toprow ^bottomrow ^carry **]);
    if toprow = 0 then
        asserts([no_more_top]);
        remove([wm ?wm [processmult]]);
    endif;
enddefine;

define do_calc();
    /* .23. calculates the product in terms of carry and unit digit */
    vars asserts multiplicand multiplier asserts writedown
        result toprow bottomrow carry unitdigit carrydigit t b c;
    lookup([wm ?wm [[t ?t] [b ?b] [c ?c]]]);
    (t * b + c) mod 10 -> unitdigit;
    (t * b + c) div 10 -> carrydigit;
    asserts([[result ^unitdigit] [ carry  ^carrydigit]]);
enddefine;

define check_bottom();
    /*  .24. checks whether last bottom digit has been used */
    vars multiplicand multiplier result toprow bottomrow carry;
    remove([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    bottomrow - 1 ->bottomrow;
    add([** ^multiplicand ^multiplier [] ^(length(multiplicand)) ^bottomrow
            0 **]);
    if bottomrow = 0 then
        asserts([no_more])
    else asserts([processmult]);
        endif
enddefine;


define checkcarry();
    /* .25. if the last digit in the column has been multiplied and there is a
    carry, places the carry in the result */
    vars  multiplicand multiplier result toprow bottomrow carry;
    remove([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    unless carry = 0 do
        [^carry ^^result] ->result;
    else [^^result] ->result;
    endunless;
    add([** ^multiplicand ^multiplier [] ^toprow ^bottomrow 0 **]);
    asserts([^bottomrow bottom ^result]);
enddefine;

define writedown();
    /* .26. add current result to result store */
    remove([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    lookup([wm ?wm [[ result ?unitdigit] [carry ?carrydigit]]]);
    [^unitdigit ^^result] ->result;
    add([** ^multiplicand ^multiplier ^result ^toprow ^bottomrow
            ^carrydigit **]);
enddefine;

/*************************************************************************/
/* actions needed for more than one digit multiplier */

/*************************************************************************/

define endmult();
    /* .27. reset database to start addition stage */
    vars fill_out multiplier multiplicand toprow bottomrow carry everything
        bottom cheat_by_using_zero a_result a_carry multresult;
    foreach ([wm ?wm [?bottom bottom ??multresult ]]) do
        remove ([wm ?wm [?bottom bottom ??multresult ]]);
        asserts([row ^bottom ^^multresult length
                ^(length(hd(multresult)))]);
    endforeach;
    remove([** ?multiplicand ?multiplier ? result ?toprow ?bottomrow
            ?carry **]);
    add([** ^multiplicand ^multiplier [a_result [] a_carry 0] **]);
    fill_out();
enddefine;


define fill_out();
    /* .28. fills out rows till they are all the same length with the empty
    string */
    vars item row multresult  readincolumn counter lengthof current;
    0 -> current;
    foreach[wm ?wm [row ?row ?multresult length ?lengthof]] do
        if lengthof > current
        then lengthof ->current;
        endif;
    endforeach;
    for item in database do
        if item matches [wm ?wm[row ?row ?multresult length ?lengthof]] then
            current - lengthof ->counter;
            repeat counter times
                [' ' ^^multresult] ->multresult;
            endrepeat;
            remove(item);
            asserts([row ^row ^multresult]);
        endif;
    endfor;
    remove([** ?multiplicand ?multiplier [a_result ?a_result a_carry
                ?a_carry] **]);
    add([** ^multiplicand ^multiplier [a_result ^a_result a_carry ^a_carry]
            length ^current **]);
enddefine;


define readincolumn();
    /* .29. asserts into WM the digits to be added */
    vars row multresult  do_add counter lengthof;
    lookup([** ?multiplicand ?multiplier [a_result ?a_result a_carry ?a_carry]
            length ?lengthof  **]);
    foreach [wm ?wm[row ?row ?multresult]] do
        asserts([column ^lengthof ^(multresult(lengthof))])
    endforeach;
enddefine;



define do_add();
    /* .30. adds the digits in wm */
    vars writeadd result moveleft item lengthof carry digit addresult
        multiplicand multiplier a_result a_carry colresult templist tempresult
        unitresult carryresult;
    [] ->colresult; 0 ->tempresult;   []->templist;
    foreach[wm ?wm [column ?lengthof ?digit]] do
        digit:: colresult -> colresult;
    endforeach;
    colresult ->templist;
    for item in templist do
        unless item = ' ' do
            item + tempresult ->tempresult;
        endunless;
    endfor;
    lookup([** ?multiplicand ?multiplier [a_result ?a_result a_carry ?a_carry]
            length ?lengthof **]);
    tempresult + a_carry ->colresult;
    colresult mod 10 ->unitresult;
    colresult div 10 ->carryresult;
    asserts([[unitresult ^unitresult][ carryresult ^carryresult]]);
enddefine;


define moveleft();
    /* .31. moves left along column to be added */
    vars result checkadd item lengthof carry carrydigit carryresult
        multiplicand multiplier a_carry a_result;
    remove([** ?multiplicand ?multiplier [a_result ?a_result a_carry
                ?a_carry] length ?lengthof  **]);
    lengthof -1 ->lengthof;
    add([** ^multiplicand ^multiplier [a_result ^a_result a_carry ^a_carry]
            length ^lengthof **]);
    if lengthof = 0 then
        asserts([no_more_digits]);
        remove([wm ?wm [startadd]]);
    endif;
enddefine;


define writeadd(unitresult,carryresult);
    /* .32. add the current result to the addition store */
    vars unitresult a_carry a_result multiplicand multiplier carryresult;
    remove([** ?multiplicand ?multiplier [a_result ?result a_carry ?carry]
            length ?lengthof **]);
    [^unitresult ^^a_result] ->a_result;
    add([** ^multiplicand ^multiplier [a_result ^a_result a_carry
                ^carryresult] length ^lengthof **]);
enddefine;



define checkadd();
    /* .33. if the last digit in the column has been added and there is a
carry then place the carry in the result */
    vars multiplicand multiplier a_result a_carry result lengthof;
    remove([** ?multiplicand ?multiplier [a_result ?a_result a_carry ?a_carry]
            length ?lengthof **]);
    unless a_carry = 0 do
        [^a_carry ^^a_result] ->a_result;
    else[^^a_result] ->a_result;
    endunless;
    add([** ^multiplicand ^multiplier [a_result ^a_result a_carry ^a_carry]
            length ^lengthof **]);
    asserts([none_left]);
enddefine;


define add_zero();
    /* .34. places zero in the right hand side of the column */
    vars bottomrow result;
    remove([wm ?wm [?bottomrow bottom ?result]]);
    repeat (bottomrow - 1) times
        [^^result 0] ->result;
    endrepeat;
    asserts([^bottomrow bottom ^result]);
enddefine;

/***************************************************************************/
/* bug action */
/**************************************************************************/

define bug6_shift();
    /* .35. rewrites 'paper' so that T1 and T2 can be multiplied togther */
    vars multiplicand multiplier multi toprow bottomrow carry
        result asserts;
    remove([** ?multiplicand ?multiplier ? result ?toprow ?bottomrow
            ?carry **]);
    unless length(multiplicand) = 2 and length(multiplier) = 2 then
        mishap(' this bug in only present for 2 by 2 sums',
            [^multiplicand ,^multiplier])
    endunless;
    toprow -1 ->toprow;
    add([** ^multiplicand ^multiplicand ^result ^toprow ^bottomrow ^carry
            **]);
    unless toprow = 0 then
      asserts([ original ^multiplier ]); ;;; this is needed to reset paper
    endunless;                    ;;; values for the display but has no
    if toprow = 0 then            ;;; place in the model
        asserts([no_more_top]);
    remove([** ?multiplicand ?multi ? result ?toprow ?bottomrow
            ?carry **]);
     remove([ wm ?wm [ original ?multiplier]]);
    add([** ^multiplicand ^multiplier ^result ^toprow ^bottomrow ^carry
            **]);
        remove([wm ?wm [processmult]]);
    endif;
enddefine;


define  bug21_check_bottom();
    /* .36. checks whether last bottom digit has been used and carrys carry
     into next row */
    vars multiplicand multiplier result toprow bottomrow carry;
    remove([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    bottomrow - 1 ->bottomrow;
    add([** ^multiplicand ^multiplier ^result ^(length(multiplicand))
            ^bottomrow ^carry **]);
    if bottomrow = 0 then
        asserts([no_more])
    else asserts([processmult]);
        endif
enddefine;


define bug23_add();
    /* .37.  multiplies the digits in wm in a way that mimiced addition */
    vars writeadd result moveleft lengthof carry digit addresult multiplicand
        multiplier a_result item a_carry colresult templist tempresult unitresult
        carryresult;
    [] ->colresult;  1 ->tempresult;  []->templist;
    foreach[wm ?wm [column ?lengthof ?digit]] do
        digit:: colresult -> colresult;
    endforeach;
    colresult ->templist;
    for item in  templist do
        unless item = ' ' do
            item * tempresult ->tempresult;
        endunless;
    endfor;
    lookup([** ?multiplicand ?multiplier [a_result ?a_result a_carry ?a_carry]
            length ?lengthof **]);
    if length(multiplier) > 2 then
        mishap('bug23 only known for two digit multipliers',[^multiplier]);
    endif;
    tempresult + a_carry ->colresult;
    colresult mod 10 ->unitresult;
    colresult div 10 ->carryresult;
    asserts([[unitresult ^unitresult][ carryresult ^carryresult]]);
enddefine;


define bug2_add();
    /* .38. if digit in toprow is zero then 0 * N -> N */
    vars asserts multiplicand multiplier asserts writedown
        result toprow bottomrow carry unitdigit carrydigit t b c;
    lookup([wm ?wm [[t ?t] [b ?b] [c ?c]]]);
    unless t = 0 then
        (t * b + c) mod 10 -> unitdigit;
        (t * b + c) div 10 -> carrydigit;
        else
        (b + c) mod 10 ->unitdigit;
        (b + c) div 10 -> carrydigit;
    endunless;
    asserts([[result ^unitdigit] [ carry  ^carrydigit]]);
enddefine;


define bug3_add();
    /* .39. if digit in bottomrow is zero then N * 0 -> N */
    /* if digit in toprow is zero then 0 * N -> N */
    vars asserts multiplicand multiplier asserts writedown
        result toprow bottomrow carry unitdigit carrydigit t b c;
    lookup([wm ?wm [[t ?t] [b ?b] [c ?c]]]);
    unless b = 0 then
        (t * b + c) mod 10 -> unitdigit;
        (t * b + c) div 10 -> carrydigit;
        else
        (t + c) mod 10 ->unitdigit;
        (t + c) div 10 -> carrydigit;
    endunless;
    asserts([[result ^unitdigit] [ carry  ^carrydigit]]);
enddefine;

define bug14_write();
    /* .40. add unit and carry to result and set carry to zero */
    remove([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    lookup([wm ?wm [ [ result ?unitdigit] [carry ?carrydigit] ]]);
    unless carrydigit = 0 do
        [^carrydigit ^unitdigit ^^result] ->result;
        else
        [^unitdigit ^^result] ->result;
    endunless;
    add([** ^multiplicand ^multiplier ^result ^toprow ^bottomrow 0 **]);
enddefine;

define bug12_write();
    /* .41. add unit and carry together result and set carry to zero */
    remove([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    lookup([wm ?wm [[ result ?unitdigit] [carry ?carrydigit]]]);
    [ ^(unitdigit + carrydigit)  ^^result] ->result;
    add([** ^multiplicand ^multiplier ^result ^toprow ^bottomrow
            0 **]);
enddefine;

define readinbug();
    /* .42. asserts the current digits into working memory, reversed
     multiplier*/
    vars toprow bottomrow carry result multiplier multiplicand;
    lookup([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    asserts ([[t ^(multiplicand(toprow))]
            [b ^(multiplier(bottomrow))] [c ^(carry)]]);
enddefine;



define bug4shift_left();
    /* .43. moves left both columns at a time allowing for odd numbers in
    multiplicand and multiplier */
    vars multiplicand multiplier toprow bottomrow carry result;
    remove([** ?multiplicand ?multiplier ? result ?toprow ?bottomrow
            ?carry **]);
    if length(multiplicand) /= length(multiplier) then
        mishap(' Bug4 only observed in rows of equal length ',[^multiplicand
                ^multiplier]);
    endif;
    toprow - 1 ->toprow;
    bottomrow -1 ->bottomrow;
    add([** ^multiplicand ^multiplier ^result ^toprow ^bottomrow ^carry **]);
    if toprow = 0 and bottomrow = 0 then
        asserts([no_more_top]);
        remove([wm ?wm [processmult]]);
    endif;
enddefine;


define do_calcbug();
    /* .44. calculates the product in terms of carry and unit digit
    and but asserts the wrong way round */
    vars asserts multiplicand multiplier asserts writedown
        result toprow bottomrow carry unitdigit carrydigit t b c;
    lookup([wm ?wm [ [t ?t] [b ?b] [c ?c] [now in] [top ?top] [bo ?bo] ]]);
    (t * b + c) mod 10 -> unitdigit;
    (t * b + c) div 10 -> carrydigit;
    asserts([[result ^unitdigit] [ carry  ^carrydigit]]);
enddefine;


define buggy_add();
    /* .45. calculates the product in terms of carry and unit digit then
    carries the unit digit not the carry digit */
    vars unitdigit carrydigit t b c top bo;
    lookup([wm ?wm [[t ?t] [b ?b] [c ?c] [now in] [top ?top] [bo ?bo]]]);
    (t * b + c) mod 10 -> unitdigit;
    (t * b + c) div 10 -> carrydigit;
    unless carrydigit = 0 then
        asserts([[result ^carrydigit] [ carry ^unitdigit]])
        else
        asserts([[result ^unitdigit] [carry ^carrydigit]]);
    endunless;
enddefine;


define bug13_readin();
    /* .46.  asserts the current digits into working memory and assigns
     position */
    vars bo top  toprow bottomrow carry result multiplier multiplicand;
    lookup([** ?multiplicand ?multiplier ?result ?toprow ?bottomrow ?carry
            **]);
    unless length(multiplicand) = 2 and length(multiplier) = 2 then
        mishap(' this bug in only present for 2 by 2 sums',
            [^multiplicand,^multiplier])
    endunless;
    if length(multiplicand) - toprow = 0 then
        1 ->top
        else
        2 ->top;
    endif;
    asserts ([ [t ^(multiplicand(toprow))]
            [b ^((rev(multiplier))(bottomrow))] [c ^(carry)] [now in] [top
                ^top] [bo ^bottomrow] ]);
enddefine;


/* rule names */


vars SM BFIF BT BF INTO WM NB CC BCC BPC BP BTC AZ BT BTDA BTRI CB BTW FI NX
    WA CO BTWR ML BSI BFS BFI BV DA CA BZT BZB;


/* procedure names */


vars correct bug_13 bug_5 bug_6 bug_23 bug_14 bug_4 n_by_one bug_12 bug_22
    bug_15 bug_2 bug_3 bug_21;


/* rules for correct multiplication (N by 1) */


[sm: [[t ?t] [b ?b] [c ?c]] => do_calc()] ->SM;
[into: [processmult] => readintandb()] ->INTO;
[nx: [next_top] => asserts([processmult]); shift_top_left()] ->NX;
[wm: [[result ?unitdigit]  [carry ?carrydigit]] => writedown();
    asserts([next_top])] ->WM;
[cc: [no_more_top] =>  checkcarry(); asserts([checkbottom]);
    asserts([addzero]) ] ->CC;
[cb: [checkbottom] => check_bottom ()] ->CB;
[fi: [none_left] => asserts([stop])] ->FI;

/* additional rules needed for N by N */

[nb: [no_more] =>  endmult(); asserts([startadd])]->NB;
[co: [startadd] => readincolumn()] ->CO;
[da: [column ?lengthof ?digit] => do_add()] -> DA;
[ml: [next_left] => asserts([startadd]); moveleft(); ] ->ML;
[wa: [[unitresult ?unitresult][ carryresult ?carryresult]] =>
    writeadd(unitresult, carryresult); asserts([next_left])];->WA;
[ca: [no_more_digits] => checkadd();] ->CA;
[az: [addzero] => add_zero()] ->AZ;

/* bug rules */

[b13: [[t ?t][b ?b] [c ?c] [now in] [top 1] [bo 1]] => buggy_add()] ->BT;
[b15: [[t ?t][b ?b] [c ?c] [now in] [top 2] [bo 1]] => buggy_add()] ->BFIF;
[b13d: [[t ?t] [b ?b] [c? c] ??x ] => do_calcbug()] ->BTDA;
[b13r: [processmult] => bug13_readin()] ->BTRI;
[b14: [[result ?unitdigit] [carry ?carrydigit]] => bug14_write();
    asserts([next_top])] ->BF;
[b12: [[result ?unitdigit]  [carry ?carrydigit]] => bug12_write();
    asserts([next_top])] ->BTW;
[b4i: [processmult] => readinbug()] ->BFI;
[b4s: [next_top] => asserts([processmult]); bug4shift_left()] ->BFS;
[b2: [[t 0][b ?b] [c ?c]] => bug2_add()] ->BZT;
[b3: [[t ?t][b 0] [c ?c]] => bug3_add()] ->BZB;
[b5:  [checkbottom] =>asserts([nomore])] ->BV;
[b21: [checkbottom] => bug21_check_bottom()]->BTC;
[b21c:[no_more_top] => asserts([checkbottom]) ] ->BCC;
[b6: [next_top] => asserts([processmult]); bug6_shift()] ->BSI;
[b23:[column ?lengthof ?digit] => bug23_add()] -> BP;


/* rules names for each procedures */


[SM INTO BTW NB CC CB FI AZ NX WA CO ML DA CA] ->bug_12;
[SM INTO WM NB CC CB FI AZ NX WA CO ML DA CA] ->correct;
[BZT INTO WM NB CC CB SM FI AZ NX WA CO ML DA CA] ->bug_2;
[BZB INTO WM NB CC SM CB FI AZ NX WA CO ML DA CA] ->bug_3;
[SM INTO WM NB CC CB FI NX WA CO ML DA CA minusAZ] ->bug_22;
[BT minusINTO BTRI BTDA WM NB CC CB FI AZ NX WA CO ML DA CA minusSM] ->bug_13;
[BFIF minusINTO BTRI BTDA WM NB CC CB FI AZ NX WA CO ML DA CA minusSM]
    ->bug_15;
[SM BF INTO NB CC CB FI AZ NX WA CO ML DA CA minusWM] ->bug_14;
[SM INTO WM CC CB FI NX] ->n_by_one;
[SM INTO WM BCC BTC FI NX minusNB minusCB minusCC] ->bug_21;
[BFI WM CC FI BFS minusAZ SM minusCB minusINTO] ->bug_4;
[SM INTO WM CC CB FI BV NX minusCB minusAZ CC] ->bug_5;
[SM WM CC CB FI BFI BSI minusINTO minusCB minusAZ CC] ->bug_6;
[SM INTO WM NB CC CB FI AZ NX WA CO ML BP CA minusDA] ->bug_23;
[BFI WM CC FI BFS minusAZ SM minusCB minusINTO] ->bug_4;
[SM minusINTO WM BFI CC CB FI BV NX minusCB minusAZ CC] ->bug_5;
[SM INTO WM NB CC CB FI AZ NX WA CO ML BP CA minusDA] ->bug_23;



start([6 2],  [1 3], [^^bug_15] );

