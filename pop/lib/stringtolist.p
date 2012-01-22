/* Usage: stringtolist(string) -> list; */

define stringtolist(string) -> list;
    lvars items, item, string, list;
    incharitem(stringin(string)) -> items;
    [%until (items() ->> item) == termin do item enduntil%] -> list;
enddefine;
