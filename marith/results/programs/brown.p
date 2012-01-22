
vars brown = [
[2 2 y 7]
[2 4 y 27]
[2 5 y 19]
[3 7 y 17]
[3 8 y 24]
[3 9 y 19]
[4 2 y 11]
[4 5 y 21]
[4 6 y 24]
[4 8 nr 60]
[4 9 y 36]
[5 2 y 9]
[5 7 nr 60]
[5 8 y 33]
[6 3 nr 60]
[6 4 y 29]
[6 5 y 33]
[6 6 n 43]
[6 7 n 39]
[6 8 nr 60]
[7 3 y 29]
[7 4 y 21]
[7 5 y 33]
[7 6 y 23]
[7 7 nr 60]
[7 8 nr 60]
[8 3 y 37]
[8 4 n 35]
[8 6 y 35]
[8 7 y 33]
[8 8 nr 60]
[8 9 y 41]
];

[%foreach [= = y ?t] in brown do t; endforeach; %] -> bsb;


fopen('ones.rt',"r") -> dev;
[% for a from 2 to 9 do
     for b from 2 to 9 do
     stringtolist(fgetstring(dev)) -> line;
     if brown matches [== [^a ^b y ==]==] then
            hd(line);
     endif;
    endfor;
endfor; %] -> bsb;
fclose(dev);


for file in [ 'c&gA85.rt' 'miller_adjx.rt' 'aikenx.rt'] do
fopen(file,"r") -> dev;
[% for a from 2 to 9 do
     for b from 2 to 9 do
     stringtolist(fgetstring(dev)) -> line;
     if brown matches [== [^a ^b y ==]==] then
            hd(line);
     endif;
    endfor;
endfor; %] -> human;
fclose(dev);

pearson_r(bsb,human) -> (r,sx,sy);
t_test_r(r,length(human)) -> (t,df);
upper_t(t,df) -> p;

[^file r = ^r p = ^p] =>

endfor;
