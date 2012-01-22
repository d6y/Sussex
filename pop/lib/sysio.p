/*
    SYSIO.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>

    6 April 1990
    Update: Wednesday 2 December 1992

    Routines for opening, closing, reading, and writing to
    files in POP.

         CONTENTS - (Use <ENTER> g to access required sections)

 -- fstringsize(device, N);
 -- fclose(device)
 -- fputchar(device, char);
 -- fputstring(device, string); ---- (adds newline)
 -- fgetchar(device) -> char is same as getc(device)
 -- fgetstring(device) -> string;
 -- fopen(file, access_mode) -> device
 -- finsertstring(dev,string) --- (does NOT add newline)
 -- finsertstring_left(device, string, width)
 -- fputvector(device, list/vector/array, start, end)
 -- fnewline(device);
 -- addprefix(filename, prefix)
 -- ffile(filename) -> list
 -- list -> ffile(filename);
 -- FREADITEMS(file) -> list
 -- no_freaditems_exceptions;
 -- freaditems_exceptions(r);

 */

uses stringtolist;
uses listtostring;
vars fast_fgetstring;

/* By default, fopen(..."r") will setup -fast_fgetstring- using
   the value sysio_default_string_size as the string size */

vars sysio_default_string_size;
unless isinteger(sysio_default_string_size) then
    300 -> sysio_default_string_size;
endunless;


/*
-- fstringsize(device, N); --------------------------------------------

Defines -fast_fgetstring- based on the size of the largest
possible string, N.   Once -fstringsize- has been called,
-fgetstring- uses -fast_fgetstring-.

Later calls to -fstringsize- override previous calls.

*/

define fstringsize(dev, n);
    line_repeater(dev, inits(n) ) -> fast_fgetstring;
enddefine;


/*
-- fclose(device) -----------------------------------------------------
*/

define fclose(device);
    sysclose(device);
    undef -> fast_fgetstring;
enddefine;


/*
-- fputchar(device, char); --------------------------------------------
*/

define fputchar(device,char);
    syswrite(device,''><char,1);
enddefine;

/*
-- fputstring(device, string); ---- (adds newline) --------------------
*/

define fputstring(device,string);
    syswrite(device,string,length(string));
    fputchar(device,'\n');
enddefine;

/*
-- fgetchar(device) -> char is same as getc(device) -------------------
*/

vars fgetchar = getc;
/*
    define fgetchar(device) -> char;
    ;;; '0' indicates end of file
        vars char = inits(1), dummy;
        sysread(device,char,1) -> dummy;
    enddefine;
*/

/*
-- fgetstring(device) -> string; --------------------------------------

Reads a string terminated by '\n', or returns termin.
Uses fast_fgetstring if -fstringsize- has been called.


*/

define fgetstring(device) -> string;

    if isprocedure(fast_fgetstring) then
        fast_fgetstring() -> string;
    else

        vars string = '', char;
        getc(device) -> char;
        if char = termin then
            termin -> string;
        else
            until char = termin or char=`\n` do
                string >< consstring(char,1) -> string;
                getc(device) -> char;
            enduntil;
        endif;
    endif;
enddefine;



/*
-- fopen(file, access_mode) -> device ---------------------------------

Returns a device or <false>

Access modes:

    "r"  read -- if file is not found, look for a compressed version (.Z)
         Also calls -fstringsize- if file is opened for fast access.
    "w"  write (will overwrite)
    "wm" write, but mishap if file exists
    "wc" write, but ask for confirmation if file exists
    "ws" write, but adds "-" (recursively) to the START of
         the filename if the file exists
    "a"  append to the file (or create)

*/

define fopen(file,access_mode) -> device;
    vars reply, compressed_file, tmpfile, tmpdev, line;

    if isdevice(file) then
        file -> device;
        return;
    endif;

    sysfileok(file) -> file;

    if access_mode = "r" then
        sysopen(file,0,"line") -> device;

        if device = false then  ;;; file not found
            ;;; try for compressed version

            file >< '.Z' -> compressed_file;
            sysopen(compressed_file,0,"line") -> device;

            unless device = false then
                sysclose(device);
                pr('Compressed version of file found ('><compressed_file><')');
                nl(1); pr('Uncompressing...');
                sysobey('uncompress '><file);
                pr('Done.\n');
                sysopen(file,0,"line") -> device;
            endunless;
        endif;

        unless device = false then
            fstringsize(device, sysio_default_string_size);
        endunless;

    elseif access_mode = "a" then
        if readable(file) then
            systmpfile('/tmp','fopen','.tmp') -> tmpfile;
            sysobey('cat '><file><' > '><tmpfile);
            fopen(tmpfile,"r") -> tmpdev;
            fopen(file,"w") -> device;
            while (fgetstring(tmpdev)->>line) /= termin do
                fputstring(device,line);
            endwhile;
            fclose(tmpdev);
            sysdelete(tmpfile)->;
        else
            fopen(file,"w") -> device;
        endif;


    elseif access_mode = "w" then
        syscreate(file,1,"line") -> device;

    elseif access_mode = "wm" or access_mode = "wc"
    or access_mode = "ws" then

        readable(file) -> device;

        if device /= false then
            sysclose(device);
            if access_mode = "wm" then
                mishap('FOPEN - File already exists',[^file]);
            elseif access_mode = "wc" then
                pr(file><' exists.\n');
                requestline('Clobber? [y or n] ') -> reply;
                if hd(reply) isin [y yes Y YES] then
                    fopen(file,"w") -> device;
                else
                    false -> device;
                endif;
            elseif access_mode = "ws" then
                sys_fname_path(file) >< '-' >< sys_fname_name(file) -> file;
                fopen(file,"ws") -> device;
            endif;
        else
            fopen(file,"w") -> device;
        endif;

    else
        mishap('FOPEN - Unknown access mode',[^file ^access_mode]);
    endif;

enddefine;

/*
-- finsertstring(dev,string) --- (does NOT add newline) ---------------
*/

define finsertstring(dev,string);
    syswrite(dev,''><string,length(''><string));
enddefine;

/*
-- finsertstring_left(device, string, width) --------------------------

Pads -string- to length -width- by adding spaces
to the end of the string (flush left)
*/

define finsertstring_left(dev,string,width);
    string >< '' -> string;
    if length(string) > width then
        substring(1,width,string) -> string;
    endif;
    finsertstring(dev,string);
    repeat width-length(string) times finsertstring(dev,' '); endrepeat;
enddefine;

/*
-- fputvector(device, list/vector/array, start, end) ------------------

Insert -vector- (list, array) to -dev- starting at
position -f- and ending at -t-
*/

define fputvector(dev,vector,f,t);
    vars i;
    fast_for i from f to t do
        finsertstring(dev,vector(i)><' ');
    endfast_for;
    finsertstring(dev,'\n');
enddefine;

/*
-- fnewline(device); --------------------------------------------------
*/

define fnewline(dev);
    fputstring(dev,'');
enddefine;

/*
-- addprefix(filename, prefix) ----------------------------------------

    Adds a prefix to the filename (not the path).
    Given the file name '/usr/local/foo.p' and the prefix 'new_', this
    procedure will return '/usr/local/new_foo.p'.
*/

define addprefix(file, fix);
    sysfileok(file) -> file;
    sys_fname_path(file) >< fix >< sys_fname_name(file);
enddefine;

/*
-- ffile(filename) -> list --------------------------------------------
-- list -> ffile(filename); -------------------------------------------

    Reads each line of a file, and turns it into a list, then returns
    a list of these lists.

    As an updater, takes a list of the said format and creates a file.

    E.g.,

        [ [The first Line] [The second file] [Third Line] ]
            -> ffile('foo');

    Creates the file 'foo' which will contain:

        The first line
        The second line
        Third line

    In another form:
        (list, '\t') -> ffile('foo');
    Each string in LIST will have a TAB appended, rather than
    the default space.  This can be made default by assigning:
        '\t' -> ffile_string_appendage;

    Using the above example, the resultant file would be:

        The first   line
        The second  line
        Third   line

*/

define ffile(file) -> list;
lvars device, line;

    fopen(file,"r") -> device;

    if device = false then
        mishap('FFILE: Cannot open file',[^file]);
    endif;

    [%
        while (fgetstring(device) ->> line) /= termin do
            stringtolist(line);
        endwhile;
    %] -> list;

    fclose(device);
enddefine;

vars ffile_string_appendage;
unless isstring(ffile_string_appendage) then
    ' '->ffile_string_appendage;
endunless;

define updaterof ffile(list,filename);
lvars line, device, end_string;

    if isstring(list) then
        (list,filename) -> (list,end_string,filename);
    else
        ffile_string_appendage -> end_string;
    endif;

    fopen(filename,"w") -> device;

    for line in list do
        fputstring(device,listtostring(line,end_string));
    endfor;

    fclose(device);

enddefine;


/*
-- FREADITEMS(file) -> list -------------------------------------------
-- no_freaditems_exceptions; ------------------------------------------
-- freaditems_exceptions(r); ------------------------------------------

Uses the POP11 itemizer to read words from a file.  Returns a flat
list containing those words.  E.g., if the file "foo" is:

    The cat sat
    on the
    mat

Then

    freaditems('foo') -> list;
    list =>
    ** [The cat sat on the mat]
    length(list) =>
    ** 6

The item repeater is fussy about certain quotes.  I.e., If the
file to be read by -freaditems- contains...
    don't
then the mishap "Unterminated string" will occur, but not with...
    don't touch my dog's bowl
However, in the latter case -freaditems- will produce a list containing
the word "don", the string 't touch my dog', the word "s" and the word "bowl".

To turn this "feature" off, disable the string quote's category code
temporarily.  This can be done with the following code:

    ;;; 39 is the ASCII code for the string quote character (')
    ;;; and 1 is the item class "Alphabetic"
    ;;; The effect is that the quote chatacter will be treated like
    ;;; an alphabetic character.
    1 -> item_chartype(39,r);

...where r is an active item repeater.

In the case of -freaditems-, the repeater "r" is created in the middle
of the procedure.  Hence, to have access to the repeater, the user MUST
do the "item_chartype" exceptions (any number) in a special procedure called
-freaditems_exceptions-

The macro "no_freaditems_exceptions" turns all exceptions off.


For example:  to read the file...

    please don't touch
    my dog.

...and process the "don't" as a single word, you can say:

    define freaditems_exceptions(r);
        1 -> item_chartype(39,r);
    enddefine;

    freaditems('test') -> list;
    list ==>
    ** [please don't touch my dog]
    length(list) ==>
    ** 5

    no_freaditems_exceptions();

See also: REF * ITEMISE and HELP * INCHARITEM and HELP *ITEM_CHARTYPE

*/


vars freaditems_exceptions;

define no_freaditems_exceptions;
    procedure(r); endprocedure -> freaditems_exceptions;
enddefine;

no_freaditems_exceptions();

define freaditems(file) -> list;
    lvars line, itemrep;

    if not(readable(file)) then
        mishap('FREADITEMS: Cannot open file',[^file]);
    endif;

    ;;; Make an item repeater
    incharitem(discin(file)) -> itemrep;

    ;;; Process exceptions
    freaditems_exceptions(itemrep);

    [%
        while (itemrep() ->> line) /= termin do
            line;
        endwhile;
    %] -> list;

enddefine;


vars sysio = true;
