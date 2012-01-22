30000000 -> popmemlim;
vars i, page, seq, k, top_s, bot_s, top_n, bot_n, j;

datafile('/tmp/xKinds') -> kinds;
rev(kinds) -> k;

pr('Multiplication kinds (0-999)\n\n');

[%
for i from 1 to length(k) do
pr_field('',60,'-',false); nl(1);
pr_field(i><'.',5,false,' ');

k(i)(2) -> seq;
k(i)(1) -> page;

prnum(length(seq),4,0); pr(' steps. ');

'' -> top_s; '' -> bot_s;
for j from length(page(1)) by -1 to 1 do
    if page(1)(j) = "-" then quitloop; endif;
    page(1)(j) >< top_s -> top_s;
endfor;

for j from length(page(1)) by -1 to 1 do
    if page(3)(j) = "-" then quitloop; endif;
    page(3)(j) >< bot_s -> bot_s;
endfor;

strnumber(bot_s) -> bot_n;
strnumber(top_s) -> top_n;
prnum(top_n,3,0); pr(' x '); prnum(bot_n,3,0); pr(' = ');
prnum(top_n * bot_n,8,0); pr('  ');
pr(length(top_s)); pr('/'); pr(length(bot_s)); nl(1);


page ==> nl(1);
seq => nl(2);

[% length(top_s); length(bot_s);
    top_n; bot_n; top_n*bot_n; length(seq); page; seq; %];


endfor;
%] -> datafile('mult_dataset.lst');
