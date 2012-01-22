
vectorclass  float  decimal;

external_load("cc_C_train_pool",
    [%'/csuna/home/richardd/pop/neural/c/train_pool.o',''%],
    [ {type procedure} [_train_pool C_train_pool] ]);

define cc_C_train_pool(pool,pool_size,nlines,noutputs,e,
        lower_inputs, size, sequence_start, epsilon,
        beta, patience, change, time_out, S, epochs, recurrent)
        -> (pool, S, highest, epochs);


    C_train_pool(arrayvector(pool), pool_size, nlines, noutputs,
        arrayvector(e), arrayvector(lower_inputs), size,
        arrayvector(sequence_start), epsilon, beta, patience, change,
        time_out, arrayvector(S), arrayvector(epochs), recurrent,
                17, "decimal") -> highest;

    if highest = -1 then
        mishap('TRAIN_POOL: Memory could not be allocated for training',
            [pool size ^pool_size noutputs ^noutputs nlines ^nlines]);
    endif;

enddefine;
