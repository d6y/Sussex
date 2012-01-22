uses sysio
uses statlib

vars dev = fopen('LOG',"r");
vars string,e,tss;
vars s_tss_list = [], s_e_list = [];
vars e_tss_list = [], e_e_list = [];

repeat

    fgetstring(dev) -> string;
    quitif(string=termin);
    stringtolist(string) -> string;
    string --> [?e ?tss];
    e :: s_e_list -> s_e_list;
    tss :: s_tss_list -> s_tss_list;

    fgetstring(dev) -> string;
    stringtolist(string) -> string;
    string --> [?e ?tss];
    e :: e_e_list -> e_e_list;
    tss :: e_tss_list -> e_tss_list;




endrepeat;

pr(length(s_e_list));
pr(' Skewed networks:\n');
pr('    Epochs: '); pr(mean(s_e_list)); nl(1);
pr('       Tss: '); pr(mean(s_tss_list)); nl(2);

pr(length(e_e_list));
pr(' Equalized networks:\n');
pr('    Epochs: '); pr(mean(e_e_list)); nl(1);
pr('       Tss: '); pr(mean(e_tss_list)); nl(2);

fclose(dev);
