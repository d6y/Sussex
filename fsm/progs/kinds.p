load maths/routines.p

30000000 -> popmemlim;

vars kinds = [], sequence;
vars digits = [% for i from 0 to 999 do i; endfor; %];
vars a,b;

1 -> START_ROW;

sysdaytime() =>
for a in digits do   a=>
    for b in digits do
        set_addition([^a ^b]) -> PAGE;
        [% addition(); %] -> sequence;
        unless kinds matches [==[== ^sequence]==] then
            [^PAGE ^sequence] :: kinds -> kinds;
        endunless;
    endfor;
endfor;

kinds -> datafile('/tmp/Kinds');

length(kinds)=>
sysdaytime() =>
