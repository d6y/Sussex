;;; defines the way the outputs work

vars output_layer;
vars first_output_unit;
vars last_output_unit;

define updaterof reset_response (activity,net);
    pdp3_firstoutputunit(net) -> first_output_unit;
    net.pdp3_nunits - 1 -> last_output_unit;
    copy(activity) -> output_layer;
    fast_for o from first_output_unit to last_output_unit do
        0.0 -> output_layer(o);
    endfast_for;
enddefine;

define response_mechanism(activity) -> vector;
    lvars o;
    {% fast_for o from first_output_unit to last_output_unit do
            activity(o) -> output_layer(o);
            output_layer(o);
    endfast_for; %} -> vector;
enddefine;
