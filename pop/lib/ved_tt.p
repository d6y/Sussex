/*
	<ENTER> TT

	Tidy-up TeX text. Like JP only recognises lines
	that start with '\' or '%'

	This is the code for ved_jjp with a few changes.

	Richard Dallaway, March 20th, 1989
	richard@cogs.sussex.ac.uk

 */

vedputmessage('Loading TeX Tidy...');

section;

define global ved_tt();
	vars vvedmarkprops;
	vedmarkpush();
	vedpositionpush();
	false -> vvedmarkprops;
	until vedline == 1
			or vvedlinesize == 0
			or vedlinestart('.')
			or vedlinestart('%')
			or vedlinestart('\\')
			or (vedscreenleft(); vedcurrentchar() = ` `) do
		vedcharup();
	enduntil;
	if vvedlinesize = 0 or vedlinestart('.') or vedlinestart('%') or
			vedlinestart('\\') then
					vedchardown()
	endif;
	vedline -> vvedmarklo;
	if (vedscreenleft(); vedcurrentchar() = ` `) then
		vedchardown();
	endif;
	until vedline == vvedbuffersize
			or vvedlinesize == 0
			or vedlinestart('.')
			or vedlinestart('%')
			or vedlinestart('\\')
			or (vedscreenleft(); vedcurrentchar() = ` `) do
		vedchardown();
	enduntil;
	if vvedlinesize == 0 or vedlinestart('.') or vedlinestart('%') or
			vedlinestart('\\') then
				vedcharup()
	endif;
	vedline -> vvedmarkhi;
	ved_j();
	vedpositionpop();
	vedmarkpop();
enddefine;

endsection;

vedputmessage('TeX Tidy Loaded');
