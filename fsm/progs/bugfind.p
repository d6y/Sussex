uses pr_list_line;
uses net_solve.p

[PDP3_MULTIPLY HAS BEEN CHANGED in BUGFIND.P]=>

define pdp3_multiply(a,w);
;;;lvars a,w, r = abs(w/15); run1
    a * w + (random(r)-r/2);
enddefine;

define bugfind(network,problems,threshold);
    vars problem, answer, sequence, end_state, timeout=100, PAGEsave;

    for problem in problems do

        correct_solve(problem) -> (PAGE, end_state, answer);
        copytree(PAGE) -> PAGEsave;

    repeat 20 times

        net_solve(network, timeout, threshold) -> sequence;

        shorten_seq(answer)-> answer;
        shorten_seq(sequence) -> sequence;

        if sequence /= answer then
            pr([^^problem DIFFERENT ------------- ]); nl(1);
            if length(sequence) >= (timeout-1) then
                [TIMOUT] =>
            else
                pr_list_line(PAGE);
                pr(sequence); nl(1);
                pr(answer); nl(1);
            endif;
        else
            pr([^^problem ok]); nl(1);
        endif;

    copytree(PAGEsave) -> PAGE;

    endrepeat;

    endfor;


enddefine;
