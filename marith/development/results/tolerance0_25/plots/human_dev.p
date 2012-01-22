uses sysio;

vars data = [

;;; NOTE grade 3a-b-c have been replaced with a grade 3 mean score


['C&G Table related'
    [46 49 47.6 68.5 79.1] ]

['C&G Recall errors'
    [32.59 23.066667 25.31 16.77 7.65] ]

];


vars e,scale,i,t,d,dev = fopen('human.dat',"w");

(7587.8-738)/length(data(1)(2)) -> scale;

foreach [?t ?d] in data do
fputstring(dev,'\"'><t><'\"');
738 -> e;
for i in d do
    fputstring(dev,e><' '><i);
    e + scale -> e;
endfor;
fnewline(dev);
endforeach;
fclose(dev);
