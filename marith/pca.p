/*
load graphics/rcg_gfile.p
*/


pdp3_recordhidden(net,pats)->V;


pdp3_adddot(net,'clx') -> clxfile;
pdp3_adddot(net,'pca') -> pcafile;

sysobey('rm -f '><pcafile);

vars x = 2 ,
     y = 3 ;

sysobey('pca -f '><clxfile
    ><' -x '><x><' -y '><y><
    ' -l 01_prods.nms | xgraph -t "01_norm30-1 pca('><
    x><','><y><')" -bb -tk -nl & ');

sysobey('cluster -g '><clxfile><' 01.nms | xgraph &');
