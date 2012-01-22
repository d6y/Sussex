define ved_ghost;
    lvars
        dir = sys_fname_path(vedpathname),
        rootfile = dir dir_>< sys_fname_nam(vedpathname),
        psfile = rootfile sys_>< '.ps';

    sysobey('gspreview '><psfile><' &');
enddefine;
