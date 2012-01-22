uses sysio;
load $pdproot/lib/pdp.p
'~richardd/pop/neural/mybp' :: popliblist -> popliblist;
'~richardd/pop/neural/mybp' :: popuseslist -> popuseslist;
uses bp


/*--- Returns a network ready to be trained on a set of hidden
      patterns stored in a COLEX file.  Training function -f- takes
      two operands to be multiplied and should return either 1 or 0.

      Returns: input stimuli, targets, and network (1000 epochs)
      NB: Ignors the "zero" pattern
*/

define bp_one_hidden(nin,nstims,clxfile,f) -> (stims,targs,network);

vars dev stims targs i p a b v;

unless issubstring('.',clxfile) then
    clxfile >< '.clx' -> clxfile;
endunless;

fopen(clxfile,"r") -> dev;
if dev = false then
    mishap('BP_ONE_HIDDEN: Cannot open file',[^clxfile]);
endif;

pdp_newarray([1 ^nin 1 ^nstims]) -> stims;

;;; ignore Zero
stringtolist(fgetstring(dev)) -> v;

fast_for p from 1 to nstims do
stringtolist(fgetstring(dev)) -> v;
fast_for i from 1 to nin do
        v(i) -> stims(i,p);
    endfast_for;
endfast_for;

fclose(dev);

pdp_makedata(stims) -> stims;

1 -> p;
pdp_newarray([1 1 1 ^nstims]) -> targs;
fast_for a from 2 to 9 do
    fast_for b from 2 to 9 do
        f(a,b) -> targs(1,p);
        p fi_+ 1 -> p;
    endfast_for;
endfast_for;

pdp_makedata(targs, 10000,true) -> targs;

bp_makenet(nin,{1},2.0,0.5,0.9) -> network;
enddefine;

;;; Example function to compute even/odd-ness

define f(a,b);
    vars prod = a*b;
    if prod/2 = intof(prod/2) then 1; else 0; endif;
enddefine;
