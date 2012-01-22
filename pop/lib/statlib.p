/*  STATLIB.P

    Richard Dallaway <richardd@uk.ac.susx.cogs>
    Some psychology statistics and neural net maths sunctions

    See also: rcg_statlib.p

    Uses: upper_t.p ~richardd/bin/sun4/beta.o ~/bin/sun4/src/beta.c



         CONTENTS - (Use <ENTER> g to access required sections)

 -- STRUCTURE_BOUNDS(s)->(b,e,l) Returns begin,end,lenght of a structure
 -- ADDUP(list): add up flat lkist, return sum
 -- MEDIAN(list): return median value of a flat list
 -- MEAN(list): Returns the mean value of a flat list
 -- MEAN_H(list): Harmonic mean
 -- SUMSQ(list): Returns the sum of the squares of a flat list
 -- VARIANCE(list): Returns the variance of a list of data
 -- SD(list): Returns the standard deviation of a list
 -- RANGE(list): Returns the range (max-min) of a list
 -- MINANDMAX(list) -> (minval,maxval)
 -- HISTOGRAM(list): returns array of frequencies
 -- FREQ_LIST(list) -> frequencies
 -- MODE(list): Returns list of modal values (BUG)
 -- MOMENT(list) -> (mean, ave dev, std dev, variance, skew, curt)
 -- Nf(X,mu,sigma2): Normal distibution round mu (vary.=sigma2) for X
 -- CHI_SQUARE_INDY(table): Chi independence (chisq, df)
 -- CHI_EXPECTED_FREQUENCIES(table) -> expected_table;
 -- PEARSON_CHI(o,e) -> (chisqr,df)
 -- LIKELIHOOD_CHI(table) -> (chisqr, df)
 -- COVARIANCE(X,Y) -> covariance;
 -- PEARSON_R(x,y) -> r; Pearson Product-Moment Correlation
 -- T_TEST_R(r,n) -> (t,df) Significance of r
 -- UPPER_T(t,v) Upper percentage points on t (2 tailed)
 -- COR(l1,l2) Prints correlation between two lists
 -- PDP CODE

*/

uses pr_array;

/*
-- STRUCTURE_BOUNDS(s)->(b,e,l) Returns begin,end,lenght of a structure
*/
define structure_bounds(s) -> (b,e,l);
    if isarray(s) then
        boundslist(s) --> [?b ?e];
        1+e-b -> l;
    else
        1 -> b;
        length(s) -> e;
        e -> l;
    endif;
enddefine;

/*
-- ADDUP(list): add up flat lkist, return sum -------------------------
*/
define constant procedure addup(list) -> sum;
    lvars sum=0, number;
    vars s,e;

    if isarray(list) then
        boundslist(list) --> [?s ?e];
    else
        1 -> s;
        length(list) -> e;
    endif;

    fast_for number from s to e do
        sum + list(number) -> sum;
    endfast_for;
enddefine;

/*
-- MEDIAN(list): return median value of a flat list -------------------
*/
define constant procedure median(list);
    vars location = (length(list)+1)/2,
        int_location = intof(location),
        sort_list = sort(list);

    if  int_location /= location then
        1.0 * ((sort_list(int_location) + sort_list(int_location+1))/2);
    else
        1.0 * sort_list(location);
    endif;
enddefine;

/*
-- MEAN(list): Returns the mean value of a flat list ------------------
*/
define constant procedure mean(list);
    1.0*(addup(list)/length(list));
enddefine;

/*
-- MEAN_H(list): Harmonic mean ----------------------------------------
*/

define mean_h(list);
    vars b,e,l,i,sum=0;
    structure_bounds(list) -> (b,e,l);
    fast_for i from b to e do
        1/list(i) + sum -> sum;
    endfast_for;
    1.0*l/sum;
enddefine;




/*
-- SUMSQ(list): Returns the sum of the squares of a flat list ---------
*/
define constant procedure sumsq(list) -> tot;
    vars item;
    0 -> tot;
    fast_for item in list do
        item * item + tot -> tot
    endfast_for;
enddefine;

/*
-- VARIANCE(list): Returns the variance of a list of data -------------
*/
define constant procedure variance(list);
    vars item, sumsqs, av=mean(list),b,e,l;
    structure_bounds(list) -> (b,e,l);
    sumsq([% fast_for item from b to e do
                (list(item) - av);
           endfast_for; %]) -> sumsqs;
    sumsqs/(l-1);
enddefine;

/*
-- SD(list): Returns the standard deviation of a list -----------------
*/
define constant procedure SD(list);
    sqrt(variance(list));
enddefine;

/*
-- RANGE(list): Returns the range (max-min) of a list -----------------
*/
define constant procedure range(list);
    vars sort_list = sort(list);
    last(sort_list) - sort_list(1);
enddefine;

/*
-- MINANDMAX(list) -> (minval,maxval) ---------------------------------
*/

define minandmax(list) -> (m,M);
lvars b,e,l,v,m,M;
structure_bounds(list) -> (b,e,l);
list(b) ->> m -> M;
fast_for i from b+1 to e do
    list(i) -> v;
    min(m,v) -> m;
    max(M,v) -> M;
endfast_for;
enddefine;


/*
-- HISTOGRAM(list): returns array of frequencies ----------------------
*/

define histogram(list) -> freq;
lvars b,e,l,freq,v,m,M;
structure_bounds(list) -> (b,e,l);
minandmax(list) -> (m,M);
newarray([^m ^M],0) -> freq;
fast_for i from b to e do
    list(i) -> v;
    freq(v) + 1 -> freq(v);
endfast_for;
enddefine;


/*
-- FREQ_LIST(list) -> frequencies ------------------------------------
*/

define constant procedure freq_list(list) -> freq;
    vars f,i, c=0;
    sort(list) -> list;
    list(1) -> f;

    [% fast_for i in list do
            if i=f then
                c + 1 -> c;
            else
                [% f; c;%];
                1 -> c;
                i -> f;
            endif;
        endfast_for;
        [% f; c;%];
    %] -> freq;
enddefine;

/*
-- MODE(list): Returns list of modal values (BUG) ----------------------

Does not average neighbourhood values.
*/

define constant procedure mode(list) -> m;
    vars i,a,b,freq = syssort(freq_list(list),
            procedure(a,b); a(2)>b(2); endprocedure);
    length(list) -> a;
    freq(1)(2) -> b;
    [% (freq(1)(1)); %] -> m;
    2 -> i;
    while ((i<a) and (freq(i)(2) = b)) do
        (freq(i)(1)) :: m -> m;
        i + 1 -> i;
    endwhile;
enddefine;


/*
-- MOMENT(list) -> (mean, ave dev, std dev, variance, skew, curt) -----

Code adapted from "Numerical recipes", page 458.
*/

define constant procedure moment(list)
        -> (ave, ave_dev, std_dev, vary, skew, curt);
    vars j, n = length(list), s, p;

    if n < 2 then
        mishap('MOMENT: Must be at least 2 data points',[^list]);
    endif;

    addup(list) -> s;       ;;; get the mean

    1.0 * (s/n) -> ave;
    0 ->> ave_dev ->> vary ->> skew -> curt;

    ;;; Get the 1st (absolute), 2nd, 3rd, and 4th moments of the
    ;;; deviation from the mean
    fast_for j in list do

        j - ave -> s;
        ave_dev + abs(s) -> ave_dev;
        s*s -> p;
        vary + p -> vary;
        p * s -> p;
        skew + p -> skew;
        p * s -> p;
        curt + p -> curt;
    endfast_for;

    1.0 * (ave_dev / n) -> ave_dev;
    1.0 * (vary / (n-1)) -> vary;
    sqrt(vary) -> std_dev;
    if vary /= 0 then
        1.0 * (skew / (n* std_dev ** 3)) -> skew;
        1.0 * (curt / (n*vary**2)-3) -> curt;
    else
        false -> skew;
        false -> vary;
        vedputmessage('WARNING: No skew of kurtosis when zero variance');
    endif;

enddefine;

/*
-- Nf(X,mu,sigma2): Normal distibution round mu (vary.=sigma2) for X -------
*/
define constant procedure Nf(X,mu,sigma2);
   ( 1/(sigma2*sqrt(2*pi)) ) * exp(- ( (X-mu)**2 / (2*(sigma2**2))));
enddefine;

/*
-- CHI_SQUARE_INDY(table): Chi independence (chisq, df) ---------------
    Takes a contigency table and returns: chi-square measure of variable
    independence; degrees of freedom.

    NOT IMPLEMENTED: Returning: significance level; Cramer's V measure
    of association; and the contingency coefficient, C.
    The smaller the "prob" the more significant the association.
    adapted from: Numerical recipes, p.479.
*/

;;;uses gamma;

define constant procedure chi_square_indy(table) -> (chisq, df);
    vars expctd, ni, nj, sum=0, nni, nnj, sumi, sumj, tiny=1e-30;

    boundslist(table) --> [1 ?ni 1 ?nj];    ;;; assume running from 1
    ni -> nni;
    nj -> nnj;

    newarray([1 ^ni],0) -> sumi;
    newarray([1 ^nj],0) -> sumj;

    fast_for i from 1 to ni do
        0 -> sumi(i);
        fast_for j from 1 to nj do
            sumi(i) + table(i,j) -> sumi(i);
            sum + table(i,j) -> sum;
        endfast_for;
        if sumi(i) = 0 then
            nni fi_- 1 -> nni;  ;;; remove zero rows
        endif;
    endfast_for;

    fast_for j from 1 to nj do
        0 -> sumj(j);
        fast_for i from 1 to ni do
            sumj(j) + table(i,j) -> sumj(j);
        endfast_for;
        if sumj(j) = 0 then
            nnj fi_- 1 -> nnj;     ;;; remove zero columns
        endif;
    endfast_for;

    nni*nnj-nni-nnj+1 -> df;
    0 -> chisq;

    fast_for i from 1 to ni do  ;;; chi-square sum
        fast_for j from 1 to nj do
            sumj(j)*sumi(i)/sum -> expctd;
            chisq + ( table(i,j)-expctd)**2 / (expctd+tiny) -> chisq;
        endfast_for;
    endfast_for;

    1.0 * chisq -> chisq;

    ;;; gamma_q(0.5*df,0.5*chisq) -> prob;
    ;;; sqrt(chisq/(sum*min(nni-1,nnj-1))) -> cramer_v;
    ;;; sqrt(chisq/(chisqr+sum)) -> c;
enddefine;

/*
-- CHI_EXPECTED_FREQUENCIES(table) -> expected_table; -----------------
    Returns a table of expected frequencies (null hypothesis).
*/
define constant procedure chi_expected_frequencies(table) -> expected;
    vars ni, nj, rt, ct, N=0, i, j;

    boundslist(table) --> [1 ?ni 1 ?nj];

    newarray([1 ^ni],0) -> rt;
    newarray([1 ^nj],0) -> ct;

    fast_for i from 1 to ni do
        fast_for j from 1 to nj do
            table(i,j) + rt(i) -> rt(i);
        endfast_for;
        rt(i) + N -> N;
    endfast_for;

    fast_for j from 1 to nj do
        fast_for i from 1 to ni do
            table(i,j) + ct(j) -> ct(j);
        endfast_for;
    endfast_for;

    newarray([1 ^ni 1 ^nj], procedure(i,j); rt(i)*ct(j)/N; endprocedure)
        -> expected;
enddefine;

/*
-- PEARSON_CHI(o,e) -> (chisqr,df) ----------------------------------------
    o - observed frequencies
    e - expected frequencies
*/

define constant procedure pearson_chi(o,e) -> (chisqr,df);
    vars ni,nj,i,j;
    boundslist(o) --> [1 ?ni 1 ?nj];
    0 -> chisqr;
    fast_for i from 1 to ni do
        fast_for j from 1 to nj do
            chisqr + (((o(i,j)-e(i,j))**2)/e(i,j)) -> chisqr;
        endfast_for;
    endfast_for;
    1.0 * chisqr -> chisqr;
    (ni-1)*(nj-1) -> df;
enddefine;



/*
-- LIKELIHOOD_CHI(table) -> (chisqr, df) ------------------------------
*/

define constant procedure likelihood_chi(table) -> (chisqr, df);
    vars ni, nj, rt, ct, N=0, i, j, sum=0, Rsum=0, Csum=0;

    boundslist(table) --> [1 ?ni 1 ?nj];

    newarray([1 ^ni],0) -> rt;
    newarray([1 ^nj],0) -> ct;

    fast_for i from 1 to ni do
        fast_for j from 1 to nj do
            table(i,j) + rt(i) -> rt(i);
            table(i,j)*log(table(i,j)) + sum -> sum;
        endfast_for;
        rt(i) * log(rt(i)) + Rsum -> Rsum;
        rt(i) + N -> N;
    endfast_for;

    fast_for j from 1 to nj do
        fast_for i from 1 to ni do
            table(i,j) + ct(j) -> ct(j);
        endfast_for;
        ct(j) * log(ct(j)) + Csum -> Csum;
    endfast_for;

    2*N*log(N) + 2*sum - 2*Rsum - 2*Csum -> chisqr;
    (ni-1)*(nj-1) -> df;
enddefine;


/*
-- COVARIANCE(X,Y) -> covariance; -------------------------------------
   Takes a list, vector or 1-d array of numbers and returns the
   covariance.
*/

define constant procedure covariance(x,y) -> c;
    vars n,b,e,xsum,ysum,sumsqr,i;
    0 ->> xsum ->> ysum -> sumsqr;
    structure_bounds(x) -> (b,e,n);
    fast_for i from b to e do
        sumsqr + x(i)*y(i) -> sumsqr;
        xsum + x(i) -> xsum;
        ysum + y(i) -> ysum;
    endfast_for;
    (sumsqr-((xsum*ysum)/n))/(n-1)*1.0 -> c;
enddefine;

/*
-- PEARSON_R(x,y) -> r; Pearson Product-Moment Correlation ----

   Takes two data sets and computes the correlation (r).
*/

define constant procedure old_pearson_r(x,y) -> (r,sx,sy);
    vars c;
    covariance(x,y) -> c;
    SD(x) -> sx;
    SD(y) -> sy;
    unless sx = 0 or sy = 0 then
        c/(sx*sy) -> r;
    else
        nl(1);
        [PEARSON_R: Standard deviation is zero] =>
        [x ^sx y ^sy] =>
        false -> r;
        nl(1);
    endunless;
enddefine;

define procedure pearson_r(x,y) -> r;
    vars b,e,l,i, ysum=0, xsum=0, xdev, ydev, cor=0,
        xdevsum=0,ydevsum=0;
    structure_bounds(x) -> (b,e,l);
    fast_for i from b to e do
        xsum + x(i) -> xsum;
        ysum + y(i) -> ysum;
    endfast_for;
    xsum/l -> xsum;
    ysum/l -> ysum;
    fast_for i from b to e do
        (x(i)-xsum) -> xdev;
        (y(i)-ysum) -> ydev;
        (xdev * ydev) + cor -> cor;
        (xdev*xdev) + xdevsum -> xdevsum;
        (ydev*ydev) + ydevsum -> ydevsum;
    endfast_for;
    if cor = 0 then 0 -> r; else
        1.0 * (cor/(sqrt(xdevsum)*sqrt(ydevsum))) -> r;
    endif;
enddefine;




/*
-- T_TEST_R(r,n) -> (t,df) Significance of r ----------------------
   Given N and the correlation, returns the t score and the d.f.
*/

uses float_parameters;

define constant procedure t_test_r(r,n) -> (t,df);
    abs(r) -> r;
    if r = 1.0 then
        [t_test_r: Perfect correlation] =>
        pop_most_positive_decimal -> t;

    else;
        (r*sqrt(n-2))/(sqrt(1-(r**2))) -> t;
    endif;
    n-2 -> df;
enddefine;

/*
-- UPPER_T(t,v) Upper percentage points on t (2 tailed) ---------------
*/
uses upper_t;


/*
-- COR(l1,l2) Prints correlation between two lists --------------------
*/

define cor(l1,l2);
    vars r,df,t,p;
    pearson_r(l1,l2) -> r;
    t_test_r(r,length(l1)) -> (t,df);
    upper_t(t,df) -> p;
    ['r=' ^r 'p(' ^df ')=' ^p] =>
enddefine;


define r_and_p(l1,l2) -> (r,p);
    vars r,df,t,p;
    pearson_r(l1,l2) -> r;
    t_test_r(r,length(l1)) -> (t,df);
    upper_t(t,df) -> p;
enddefine;



/*
-- PDP CODE -----------------------------------------------------------
*/


/*
"ddecimal" -> popdprecision;    ;;; double precision loading
;;; compile('~harryb/pop/VM/vm_package.p');
uses vec_mat
*/


define dp(x,y);
lvars b,e,n,i;
structure_bounds(x) -> (b,e,n);
addup([% fast_for i from b to e do
    x(i)*y(i); endfast_for; %]) / n *1.0;
enddefine;


vars statlib = true;
