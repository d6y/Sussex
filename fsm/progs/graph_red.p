/*
sysobey('xgraph -P -t \"Residual error\" -x \"Step\" -y \"Error\" res.plt &');
*/

vars files = [

['303a-21_12x50.txt' 'Bug 12x50']
['303a-21_12x19.txt' 'Ok 12x19']


;;;['303a-13-5_111x1.txt' 'Bug 111x1']
;;;['303a-13-5_11x1.txt' 'Ok 11x1']


;;; ['303a-3_1+19.txt' 'Bug 1+19']
;;; ['303a-3_11+1.txt' 'Bug 11+1']
;;; ['303a-3_11+11.txt' 'OK 11+11']

;;; ['303a-13_2x5.txt' 'Bug 12x5']
;;; ['303a-13_12x5.txt' 'Ok 2x5']

;;; ['303a-19_11x11.txt' 'Ok 11x11']
;;; ['303a-19_12x15.txt' 'Bug 12x15']

;;;['303a-16_11+11.txt' 'Ok 11+11']
;;;['303a-16_1x11.txt' 'Ok 1x11']
;;;['303a-16_43x11.txt' 'Bug 43x11']

;;;['303a-6_100+100.txt' 'Bug 100+100']
;;;['303a-6_11+11.txt' 'Ok 11+11']
;;;['303a-7_100+100.txt' 'Ok 100+100']

];

vars outfile = 'res.plt';


vars dev = fopen(outfile,"w");

vars file, label, data;

foreach [?file ?label] in files do

    ffile(file) -> data;

    fputstring(dev,'\"'><label><'\"');

    tl(tl(data)) -> data;

    for line in data do
        finsertstring(dev,line(1)><'\t');
        line(4) -> e;
        if e<1 then
            line(5) -> e;
        endif;
        fputstring(dev,e><'');
    endfor;

    fnewline(dev);

endforeach;


fclose(dev);
