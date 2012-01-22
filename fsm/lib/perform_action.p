
define perform_action(op);
    if op = "mark_carry" then
        tens();
    endif;
    popval([^op(); ]);
enddefine;
