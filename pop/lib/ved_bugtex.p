uses sysio;
vars buglist;
unless islist(buglist) then
    load /csuna/home/richardd/fsm/buglist.p
endunless;

define bug_tex(dev,list) -> (errors,found);

    vars
        line, sublist, file, bugkey, name, errors=0, found=0,e,f;

    for line in list do

        if line matches [\ @ input = ?file =] then

            if readable(file) then
                vedputmessage('Reading '><file);
                ffile(file) -> sublist;
                bug_tex(dev,sublist) -> (e,f);
                errors + e -> errors;
                found + f ->found;
            endif;

        elseif line matches [\ bugcite = ?bugkey = ] then

            if buglist matches [ == [^bugkey ?name ==] ==] then
                fputstring(dev,'\\bugdef{'><bugkey><'}{'><name><'}');
                found + 1 -> found;
            else
                pr('Key \"'><bugkey><'\" not found.\n');
                errors + 1 -> errors;
            endif;

        endif;

    endfor;

enddefine;


define ved_bugtex;

    lvars
        dir = sys_fname_path(vedpathname),
        rootfile = dir dir_>< sys_fname_nam(vedpathname),
        auxfile = rootfile sys_>< '.aux',
        dev, found, errors;

    vars auxlist;

    readable(auxfile) -> dev;
    if dev = false then
        vederror('cannot open '><auxfile);
    endif;
    fclose(dev);

    ffile(auxfile) -> auxlist;

    fopen(auxfile,"a") -> dev;

    bug_tex(dev,auxlist) -> (errors, found);

    fclose(dev);

    vedputmessage('Found: '><found><', Errors: '><errors);

enddefine;
