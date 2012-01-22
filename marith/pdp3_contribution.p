
define pdp3_contribution(net) -> contrib;
    lvars i,h,o,sum;
    vars w = pdp3_weights(net);
    newarray([^First_input_unit ^Last_input_unit
            ^First_output_unit ^Last_output_unit]) -> contrib;

    fast_for i from First_input_unit to Last_input_unit do
        fast_for o from First_output_unit to Last_output_unit do
            0 -> sum;
            fast_for h from First_hidden_unit to Last_hidden_unit do
                w(i,h)*w(h,o) + sum -> sum;
            endfast_for;
            sum -> contrib(i,o);

        endfast_for;
    endfast_for;

enddefine;
