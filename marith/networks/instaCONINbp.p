uses sysio;

;;; Connects input layer to output layer

/*

instabp(18,20,36,'thru20');
instabp(18,8,36,'thru8');
instabp(16,5,31,'thru5');

instabp(19,10,36,'thru10');

*/
define instabp(nin,nhid,nout,filename);

vars dev = fopen(filename><'.net',"w");
fputstring(dev,'definitions:');
fputstring(dev,'nunits '><(nin+nout+nhid));
fputstring(dev,'ninputs '><(nin));
fputstring(dev,'noutputs '><nout);
fputstring(dev,'end');

fputstring(dev,'network:');
fputstring(dev,'%r '><(nin+nhid)><' '><nout><' '><(0)
        ><' '><(nhid+nin));
fputstring(dev,'%r '><(nin)><' '><nhid><' 0 '><(nin));
fputstring(dev,'end');

fputstring(dev,'biases:');
fputstring(dev,'%r '><(nin)><' '><(nout+nhid));
fputstring(dev,'end');
fclose(dev);

fopen(filename><'.tem',"w") -> dev;

fputstring(dev,'define: layout 32 120');
fputstring(dev,'epoch   $       tss $');
fputstring(dev,'cpname  $       pss $');
fputstring(dev,'cycle   $\n');
fputstring(dev,'    4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 20 21 24 25 27 28 30 32 35 36 40 42 45 48 49 54 56 63 64 72 81');
fputstring(dev,'t $\n');
fputstring(dev,'o $\n');
fputstring(dev,'h $\n');
fputstring(dev,'i $\nend');
fputstring(dev,'epochno variable    1   $   n   epochno 6   1.0');
fputstring(dev,'tss floatvar    1   $       n       tss 8   1.0');
fputstring(dev,'cpname  variable    1   $   n   cpname  -6  1.0');
fputstring(dev,'pss floatvar    1   $   n   pss 8   1.0');
fputstring(dev,'cycle variable 1 $ n cycleno 5 1.0');
fputstring(dev,'targets vector 2 $  n target  h 3 100.0 0 '><nout);
fputstring(dev,'output vector 2 $  n activation h 3 100.0 '><(nin+nhid)><' '><nout);
fputstring(dev,'hidden vector 2 $ n activation h 3 100.0 '><(nin)><' '><nhid);
fputstring(dev,'input vector 2 $ n activation h 3 100.0 0 '><nin);

fclose(dev);

enddefine;
