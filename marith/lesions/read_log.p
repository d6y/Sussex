uses sysio;
uses sorting;

define read_log -> data;
    vars dev, data = [];
    fopen('DAMAGE_LOG',"r") -> dev;
    repeat;

        fgetstring(dev) -> line;
line =>
    quitif(line = termin);

        stringtolist(line) -> line;
        if line /= [] then
            line -> damage_type;
            [] -> collect;
            repeat;
                stringtolist(fgetstring(dev)) -> line;
                until (line matches [value = ?value]) or
                    (line matches [Deleting ?value ==]) or
                    (line matches [END]) do
                    stringtolist(fgetstring(dev)) -> line;
                enduntil;

line =>

            quitif(line matches [END]);

                until stringtolist(fgetstring(dev)) matches
                    [Total of = errors (tokens), ?error_rate ==] do ;
                enduntil;

                until stringtolist(fgetstring(dev)) matches
                    [Operand errors = ?op_rate ==] do ;
                enduntil;

                until stringtolist(fgetstring(dev)) matches
                    [Omission errors = ?om_rate ==] do ;
                enduntil;

                until stringtolist(fgetstring(dev)) matches
                    [== PRODUCT ==] do ;
                enduntil;

                stringtolist(fgetstring(dev)) --> [== r = = p ( 98) = ?prod_p ==];

                until stringtolist(fgetstring(dev)) matches
                    [== SUM ==] do ;
                enduntil;

                stringtolist(fgetstring(dev)) --> [== r = = p ( 98) = ?sum_p ==];

                [^value ^error_rate ^op_rate ^om_rate ^prod_p ^sum_p] :: collect -> collect;

            endrepeat;

            [^damage_type ^(sort_by_head_num(collect))] :: data -> data;

        endif;

    endrepeat;
    fclose(dev);



enddefine;
read_log() -> d;
