
/*
    ERRRT.C

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Wednesday 22 January 1992

    C code used by POP11 for recording errors and RT

    Explicit return value: -1 if malloc failed, otherwise
    returns the number of patterns on which the time_limit
    was reached (number of "no_response"s made)

    See: c_errrt.p
    Uses "logistic" function taken from bp.c

    Compile: cc -O -c errrt.c -lm
*/


#include <stdio.h>
#include <stdlib.h>
#include <math.h>

float  logistic (x)
float  x;
{
    double  exp ();

/* .99999988 is very close to the largest single precis value
   that is resolvably less than 1.0 -- jlm */
      if (x > 15.935773)
    return(.99999988);
      else
  if (x < -15.935773)
        return(.00000012);
    else
       return(1.0 / (1.0 + (float) exp( (double) ((-1.0) * x))));
}


int errrt(weights, biases, senders, nunits, nin, nout,
            stims, targs, first_pattern, last_pattern,
            time_limit, crate, minimum_threshold, maximum_threshold,
            seed, nblocks, errors, rt, omissions)
float   *weights;       /* [nunits][nunits] sender, receiver */
float   *biases;        /* [nunits] */
float   *senders;       /* [nunits][nunits]  senders to a unit */
int     nunits;
int     nin;
int     nout;

float   *stims;         /* [npats][nin] */
float   *targs;         /* [npats][nout] */
int     first_pattern;
int     last_pattern;

int     time_limit;
float   crate;
float   minimum_threshold;
float   maximum_threshold;
int     seed;
int     nblocks;

float   *errors;        /* [pattern][product] */
float   *rt;            /* [npats] */
float   *omissions;     /* [npats] */
{
float       logistic();
double      drand48();
void        srand48();
float       drate = (1.0-crate);
register    p,u,i;
int         b;
float       *activity;
float       threshold;
float       response_threshold;
float       *netinput;
float       netin;
int         *rt_count;
int         s, time, pat_index, target_unit, index;
int         first_product, first_output;
int         quitloop;
int         no_response = 0;
float       sum;
float       threshold_diff = maximum_threshold - minimum_threshold;

/* When called with seed other than -1, the random number
   generator is seeded, and the procedure ends */

if (seed != -1) {
    srand48((long)seed);
    return(0);
}

activity = (float *)calloc(nunits,sizeof(float));
netinput = (float *)calloc(nunits,sizeof(float));
rt_count = (int *)calloc(last_pattern,sizeof(int));

if (activity==NULL || netinput==NULL)
    return(-1);

first_output = nunits-nout;
first_product = first_output+1; /* DON'T KNOW isn't a product */

for(p=first_pattern; p<=last_pattern; p++)
        rt_count[p] = 0;


for(b=0; b<nblocks; b++) {

    for(p=first_pattern; p<=last_pattern; p++) {

    /* Find target output unit */

    pat_index = p*nout;
    target_unit = 0;
    for(u=1; u<nout; u++)
        if (targs[pat_index+u] > targs[pat_index+target_unit])
            target_unit = u;

    target_unit += first_output;

    /* Activation for all-ZEROs-in */

    for(i=0; i<nin; i++)
        activity[i] = 0;

        /* Full, normal, forward propagation */

        for(u=nin; u<nunits; u++) {
            netin = biases[u];
            i=1;
            index = u*nunits;
            while ((s=(int)(senders[index+i])) != -1) {
                netin += (activity[s] * weights[s*nunits+u] );
                i++;
            }
            netinput[u] = netin;
            activity[u] = logistic(netin);
        }

    /* Set stimulus */

    pat_index = p*nin;
    for(i=0; i<nin; i++)
        activity[i] = stims[pat_index+i];

    /*----------------  Cascade ---------------*/

    time = 0;
    quitloop = 0;
    pat_index = (p*nout)-first_product;

    /* Select a threshold for this trial */
    response_threshold = minimum_threshold + (drand48() * threshold_diff);

    while ( (time<time_limit) && (quitloop==0) ) {
        time++;

        for(u=nin; u<nunits; u++) {
            netin = biases[u];
            i=1;
            index = u*nunits;
            while ((s=(int)(senders[index+i])) != -1) {
                netin += (activity[s] * weights[s*nunits+u] );
                i++;
            }
            netin = (crate*netin) + ((netinput[u])*drate);
            netinput[u] = netin;
            activity[u] = logistic(netin);
        }

        /* Normalize output */
        sum = 0.0;
        for(u=first_output; u<nunits; u++)
            sum += activity[u];

        for(u=first_output; u<nunits; u++)
            activity[u] /= sum;

        /*-- Check for a response --*/

        threshold = activity[first_output];

        if (threshold < response_threshold)
                threshold = response_threshold;

        for(u=first_product; u<nunits; u++)
            if (activity[u] > threshold) {
                quitloop=1;
                if (u==target_unit) {   /* winner is correct product */
                    rt[p] += time;
                    rt_count[p]++;
                }
                else { /* genuine error */
                    (errors[pat_index+u])++;
                }
            }

    }/* endwhile */

    if (quitloop==0) { /* if net failed to respond */
        omissions[no_response] = (float)p;
        no_response++;
        }

 } /* end pattern loop */
} /* end of blocks loop */


/* Mean RT is returned */
for(p=first_pattern; p<=last_pattern; p++)
    if (rt_count[p] != 0)
        rt[p] /= rt_count[p];

free(activity);
free(netinput);
free(rt_count);
return(no_response);
}
