/*
load ~/marith/product_code.p
uses rcg
*/

vars a,b,ra,product;

[% for a from 2 to 9 do
        for b from 2 to 9 do

            a*b -> product;
            0 ->> enemies -> friends;

            for n from 2 to 9 do
                for m from 2 to 9 do

                    unless (n=a and m=b) or (n=b and m=a) then
                        if n*m = product then
                             if
                                friends + 1 -> friends;
                            else
                                enemies + 1 -> enemies;
                            endif;
                        endif;
                    endunless;

                endfor;
            endfor;

            1.0 * (enemies/friends);
            ;;;    enemies;
            ;;;    friends;
            ;;;    enemies-friends;

        endfor;
    endfor; %] -> ra;

rc_graphplot(1,1,64, 'Problem', ra ,'Ratio')->;
ra==>
