30000000 -> popmemlim;

vars kinds = [], sequence;
vars top_digits = [% for i from 0 to 12 do i; endfor; %];
vars bot_digits = [% for i from 0 to 99 do i; endfor; %];
vars a,b, problems=[];

done -> addition;

sysdaytime() =>
for a in top_digits do   [^a ^(length(kinds))] =>
    for b in bot_digits do
        set_multiplication(a,b) -> PAGE;
        [% multiplication(); %] -> sequence;
        unless kinds matches [==[== ^sequence]==] then
            [^PAGE ^sequence] :: kinds -> kinds;
            [x ^a ^b] :: problems -> problems;
        endunless;
    endfor;
endfor;

;;;kinds -> datafile('/tmp/xKinds');
problems -> datafile('xprobs.list');

length(problems)=>
sysdaytime() =>
