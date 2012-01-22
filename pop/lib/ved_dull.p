define ved_dull;
    lvars col;
    'OldLace' -> col;

    if vedargument /= 'current' then
        unless vedargument = '' then vedargument -> col; endunless;
        'black', col -> xved_value("defaultWindow",
            [foreground background]);
        'black', col -> xved_value("defaultWindow",
            [statusForeground statusBackground]);
    endif;

    'black', col -> xved_value("currentWindow",
        [foreground background]);
    'black', col -> xved_value("currentWindow",
        [statusForeground statusBackground]);
enddefine;
