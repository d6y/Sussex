vars c;
vars a,b,dev=fopen('01_NORM.nms',"w");
fputstring(dev,'Zero');
for b from 0 to 9 do
for a from 0 to 9 do
;;;fputstring(dev,''><a><'x'><b);
fputstring(dev,''><min(a,b)><'x'><max(a,b));
;;;fputstring(dev,''><a*b);

endfor;
endfor;
fclose(dev);

sysobey('rm -f pcafile');
sysobey('pca -f 01_norm30-1.clx -l 01_NORM.nms -x 0 -y 1 > pcafile');
sysobey('xgraph -nl -bb -tk  pcafile &');
