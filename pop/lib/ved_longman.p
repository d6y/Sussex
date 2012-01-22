

define ved_longman;
    vedstartwordleft();
    vars checkword = uppertolower(vednextitem());
    vedputmessage('Looking up '><checkword);
    vars tmpfile = systmpfile(false,'ved_longman','.tmp');
    sysobey('echo '><checkword><' | /csuna/home/nlcl/longmans/ldoce > '><
        tmpfile);

    vars dev = sysopen(tmpfile,0,"line"), char = inits(1);
    repeat
        sysread(dev,char,1) ->;
        quitif(char(1)=10);
    endrepeat;
    sysread(dev,char,1) ->;

    sysclose(dev);
    unless char = 'N' then
        edit(tmpfile);
        vedputmessage('DONE');
    else
        vedputmessage('Word not in dictionary');
    endunless;
    sysdelete(tmpfile) ->;
enddefine;
