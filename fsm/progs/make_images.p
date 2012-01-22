vars init_loaded;
unless init_loaded then
    load ~/pop/init.p
endunless;

load programs.p
load progs/record_net_solution.p

define make_filename(n);
    '~/fsm/weights/dev/350-'><n><'.wts';
enddefine;

vars PCA1 = 0, PCA2 = 1;

vars problems;

[ [+ 1 1] [+ 11 11] [+ 11 1] ] -> problems;

vars i, file_identifiers = [% for i from 1 to 70 do i; endfor; %];

vars pictures_save = '~/pic350.lst';

vars
    main_pca_file = sysfileok('~/fsm/weights/main.act'),
    pca_file = sysfileok('/tmp/hid.pca'),
    hidden_file = sysfileok('/tmp/hid.act');

define record_solutions(net,timeout,threshold,probs) -> (seqs,labels);
    vars prob, dont_record = false;
    [] -> seqs; [] -> labels;
    for prob in probs do

        record_net_solution(net,timeout,threshold,prob) -> seq;
        foreach [?name ?vector] in seq do

            [%  for i in vector using_subscriptor subscrv do
                    i; endfor; %] :: seqs -> seqs;

            ;;; ** ** SPECIAL ** **
            if prob = [+ 11 1] then
                name >< 'X' -> name;
            endif;

            name :: labels -> labels;

        endforeach;
    endfor;
enddefine;



;;; Create standard set of PCs

vars filename, seq;

make_filename(last(file_identifiers)) -> filename;

;;; Record hidden activations

pdp3_getweights('~/fsm/networks/fsm35.net',filename) -> net;

vars seqs, labels;
record_solutions(net,100,0.00,problems) -> (seqs,labels);

;;; Compute pca

sysobey('rm -f '><pca_file><' '><main_pca_file><'.pr* ');

seqs -> ffile(main_pca_file);
sysobey('pca -f '><main_pca_file><' -x '><PCA1><' -y '><PCA2><
    ' > '><pca_file);

;;; APPLY FOR ALL FILES

sysdaytime()=>
vars item, pcs, x, y, pictures = [];

for item in file_identifiers do

    make_filename(item) -> filename;
    [Processing ^filename] ==>

    pdp3_getweights('~/fsm/networks/fsm35.net',filename) -> net;
    record_solutions(net,120,0.0,problems) -> (seqs,labels);


    sysobey('rm -f '><pca_file><' '><hidden_file><'.principal*');
    ;;; sysobey('ls '><pca_file><' '><hidden_file><'.principal*');

    seqs -> ffile(hidden_file);

/*
    ;;; Recompute PCs for each file.
    sysobey('pca -f '><hidden_file><
            ' -x '><PCA1><' -y '><PCA2>< ' > '><pca_file);
*/

    ;;; Project PCs onto a single PCA space
    sysobey('pca -f '><main_pca_file><' -i '><hidden_file><
        ' -x '><PCA1><' -y '><PCA2>< ' > '><pca_file);

    ;;; READ BACK X,Ys

    ffile(pca_file) -> pcs;

    [% foreach [?x ?y] in pcs do
            [% x; y; fast_destpair(labels) -> labels; %]
        endforeach; %] :: pictures -> pictures;

    endfor;

sysdaytime()=>

pictures -> datafile(pictures_save);

sysobey('cp /tmp/hid.pca  /csuna/home/richardd/hid350.pca');

pictures -> datafile('/tmp/pictures');

[FILES IN /tmp/pictures AND ^pictures_save] =>
