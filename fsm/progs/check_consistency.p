uses io_mapping;

define compare_seqs(seqs,a,b);
    vars seq_len, i, s1, s2, ok = false;

    seqs(a) -> s1;
    seqs(b) -> s2;

    min(length(s1),length(s2)) -> seq_len;

[testing ^a ^b]=>

    fast_for i from 1 to seq_len do

        if s1(i)(1) = s2(i)(1) then ;;; Same inputs
            if s1(i)(2) /= s2(i)(2) then ;;; but outputs differ!
                [Inconsitency at step ^i in seq ^a and ^b] =>
                [Difference is ^(s1(i)(2)) and ^(s2(i)(2))]=>
                true -> ok;
                quitloop;
            else
                ;;; Same inputs up to this point, so keep looking
                ;;; for an inconsistency.
            endif;
        else ;;; different inputs, can't be inconsistent
            true -> ok;
            quitloop;
        endif;

    endfast_for;


    if (length(s1) /= length(s2)) and not(ok) then
        [Inconsistency at last step of seq ^a or ^b]=>
        [One pattern continues; one pattern stops] =>
    endif;

enddefine;

define check_consistency(probs);
    vars prob, seqs, i, j, nprobs;

    [%  for prob in probs do
            [building ^^prob] =>
            io_list(prob);
        endfor; %] -> seqs;

    length(seqs) -> nprobs;

    fast_for i from 1 to nprobs-1 do
        fast_for j from i+1 to nprobs do
            compare_seqs(seqs,i,j);
        endfast_for;
    endfast_for;

enddefine;

check_consistency([
[+ 1 1]
[+ 1 1 1]
[+ 11 11]
[+ 11 1]
[+ 1 9]
[+ 1 19]
[+ 100 100]
[+ 101 109]
[+ 101 99]
[+ 101 899]
[x 1 1]
[x 2 5]
[x 11 1]
[x 111 1]
[x 12 5]
[x 12 9]
[x 1 11]
[x 11 11]
[x 1 111]
[x 12 15]
[x 12 19]
[x 12 50]
[x 12 55]
[x 12 59]
[x 12 90]
[x 12 95]
[x 12 99]
[x 111 11]
[x 111 111]
]);
