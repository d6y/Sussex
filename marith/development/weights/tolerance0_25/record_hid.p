load ~/pop/pdp3/pdp3.p

pdp3_getweights('~/marith/networks/new10','devb-100') -> net;
pdp3_getpatterns('~/marith/patterns/NORMAL',65,17,32,true) -> pats;

pdp3_recordhidden(net,pats) ->;

lvars dev,x,y;
fopen('pats.nms',"w") -> dev;
fputstring(dev,'Zero');
for x from 2 to 9 do
    for y from 2 to 9 do
        fputstring(dev,min(x,y)><''><max(x,y));
    endfor;
endfor;
fclose(dev);
