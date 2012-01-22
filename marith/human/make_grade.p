
define insert(q,w,list);
    list((w-1)+((q-2)*8));
enddefine;

vars p=1,tr = [% for a from 2 to 9 do
for b from a to 9 do
[^a ^b ^p];
p+1 ->p;
endfor;
endfor; %];


define make_grade_files;
    foreach [?grade ?name ?file] in [[^g3a 'Grade 3a' 'grade_3a']
            [^g3b 'Grade 3b' 'grade_3b']
            [^g3c 'Grade 3c' 'grade_3c']
            [^g4 'Grade 4' 'grade_4'] [^g5 'Grade 5' 'grade_5']] do

        fopen(file><'.dat',"w") -> dev;
        fputstring(dev,'"'><name><'"');

        for a from 2 to 9 do
            fputstring(dev,a><' '><mean([%
                for b from 2 to 9 do
                unless tr matches [==[^a ^b ?p]==] then
                    tr --> [==[^b ^a ?p]==];
                endunless;
                grade(p);
            endfor;%]));
        endfor;

        fclose(dev);

    endforeach;
enddefine;
make_grade_files();
