


uses ved_arith;
uses arithkeys; ;;; j n b

/*
Some abbreviations used in the bug labels.
=========================================
A add
X mult
O over
B blank
C carry
S subtrct
R rename
P Product
pP partial product
Q quit
N Answer
E Equals
Z Zero
*/


vars citelist = [

    [coxanal    Cox         C       show    [freq 116 + 113 x]   ]
    ;;; Ainsworth, excluding bugs 10, 11a and 16 because she never got
    ;;; round to explaining them to me.
    [shar       Ainsworth   Ai      show    [freq 76 x]         ]
    [attiexpe   Attisha     At      noshow             ]
    [buswdiag   Buswell     B       show    [freq 484 + 512 x]        ]
    [nicodesi   Nicholson   N       noshow]

];

vars buglist = [

/*
    [   key         <word> for \bug{}
        name          <string>
        description <string>
        context     <list of signs>
        examples    <list containing a list for each example>
        occurrences  <list containing each occurrence>
    ]


    The key can be used with the LaTeX style option "bugs.sty" (found
    in ~richardd/tex/inputs/) to refer to one of the bugs without
    typing the whole name.  E.g., \bug{manyZ}.  The POP-11 library
    ~richardd/pop/lib/ved_bugtex.p loads the VED command <ENTER> bugtex
    to search a .aux file for \bug entries and write a file to index the
    real bug name.  ved_bugtex assumes that it is run when you are ved-ing
    the appropriate .tex file. This is all rather like BIBTeX.

    The example list can be processed by the procedures in ved_arith.p

    Each occurrence is:
        [autorcitekey bugname frequenciesifknown]

    where the frequency data is a list containing one or more:
        [frequency label]

    frequency of all RECOGNIZED bugs
    where recognized means ignoring number-fact bugs, or bugs which are
    just 'habits'.

    The label is used to look up the divisor in the citelist for the author.
    For example, [Cox 6 [ [12 +] ] ] is the 6th bug in the Cox database,
    which occurred 12 times in addition.  IN the cite list, we have:
    [Cox [116 + 102 x] ]  indicating that there were a total of 116 addition
    bugs, meaning that Cox bug 6's frequency was 10.3448 per cent.



-----------------------------------------------------------------------
                        ADDITION BUGS START HERE
-----------------------------------------------------------------------

*/


;;; This seems too slip like.
;;; [ digitskip 'digits-skipped' [+]
;;;     'When processing a row, one or more of the digits were omitted.'
;;;     []
;;;     [
;;;         [Buswell 'a16' 52 +]
;;;     ]
;;; ]


[ skipcol 'column-skipped' [+]
    'One column is ignored and the column\'s answer is left blank.'
    [
       [+ [- 3 7 5] [- - - -] [- 2 1 2] [- - - -] [= = = =] [= = = =]
          [- 5 - 7] [- - - -] ]
    ]
    [
        [Buswell 'a20' 36 +]
    ]
]



[ Adc 'adds-disregarding-columns' [+]
    'All the digits of the problem are added, without regard for the columns,\
 i.e., 4+7+6+1+7=25.'
    [
        [ [- 4 7 6] [- - - -] [- - 1 7] [- - - -] [= = = =] [= = = =]
          [- - 2 5] [- - - -] ]
    ]
    [
        [Cox 'l12368' 15 +]
        [Attisha   'AS12-13']
        [Buswell 'a15' 55 +]
    ]
]


[ noraise 'does-not-raise-carry' [+]
    'The final carry at the end of an answer row is not raised onto the\
 answer row.'
    [
        [ + [- 7 8] [- - -] [- 7 1] [- - -] [= = =] [= = =] [- 4 9] [1 - -] ]
    ]
    [
        [Buswell 'a21' 34 +]
    ]
]


[ wrongop 'wrong-operator' [+]
    'As some stage in the problem the wrong operator was used (e.g.,\
 multiplication for addition).  Buswell was no more specific than this.'
    []
    [
        [Buswell 'a12' 79 +]
    ]
]


[ spuriousC 'spurious-carry' [+]
    'As some stage in the sum a carry was added when it was not appropriate.'
    []
    [
        [Buswell 'a12' 29 +]
    ]
]


[ subC 'subtract-carry' [+]
    'The carry was subtacted, rather than added to the addend.'
    [
        [ + [- - 7] [- - -] [- 8 9] [- - -] [= = =] [= = =] [- 7 6] [- 1 -]]
    ]
    [
        [Buswell 'a32' 1 +]
    ]
]


[ imagineC 'added-imaginary-column' [+]
    'The subject went on to write an answer for a column that did not exist.'
    [
        [ + [- 6 9] [- - -] [- 1 2] [- - -] [= = =] [= = =] [1 8 1] [- 1 -] ]
    ]
    [
        [Buswell 'a33' 1 +]
    ]
]



[ dnRsum 'does-not-rename-sum' [+]
    'During addition, digits to be carried are written on the answer row.'
    [
        [ + [- 4 8] [- - -] [- - 3] [- - -] [= = =] [= = =] [4 1 1] ]
        [ x [- - 2 8] [- - - -] [- - 1 7] [- - - -] [- = = =] [- = = =]
            [- 1 9 6] [- 1 5 -] [- 2 8 0] [- - - -] [= = = =] [= = = =]
            [3 1 7 6] ]
    ]
    [
        [Cox 'l2467' 22 +]
        [Buswell 'a27' 15 +]
        [Attisha 'AL14-13']
;;;        [Attisha 'M13-11']
    ]
]


[ dnRQ100 'does-not-rename-quits-100s' [+]
    'The carry digit from the first addition is written in the answer row\
 but the hundreds column is not processed.'
    [
        [ + [- 2 0 5] [- - - -] [- - 8 6] [- - - -] [= = = =] [= = = =]
            [- 8 1 1] [- - - -] ]
    ]
    [
        [Cox 'l6' 2 +]
    ]
]


[ dnRcopy 'does-not-rename-copy-100s' [+]
    'The sum of the first column is not renamed, the tens column is not\
 processed, and the digit in the hundreds column is copied to the answer\
 row.'
    [
        [ + [- 2 0 5] [- - - -] [- - 8 6] [- - - -] [= = = =] [= = = =]
            [- 2 1 1] [- - - -] ]
    ]
    [
        [Cox 'l7' 1 +]
    ]
]






[ singlecopy 'copies-first-addend' [+]
    'Where there is a single digit addend, that digit is copied as the\
 answer in the ones column.  The answer in the tens column is selected\
 from one of the digits in the top row.'
    [
        [ + [- 4 6] [- - -] [- - 3] [- - -] [= = =] [= = =] [- 4 3] [- - -] ]
    ]
    [
        [Cox 'l1' 1 +]
    ]
]

[ copybotadd 'copy-lower-addend' [+]
    'The addend in the second row is copied to the answer.  If there are\
 digits over empty cells, they are also copied to the answer row.'
    [
        [ + [- 4 7 6] [- - - -] [- - 1 7] [- - - -] [= = = =] [= = = =]
            [- 4 1 7] [- - - -] ]
    ]
    [
        [Cox 'l6' 1 +]
    ]
]



[ copyA 'copy-addend' [+]
    'One of the addend rows is copied to the answer row, possibly incremented\
 or decremented.'
    [
        [ + [- 3 7] [- - -] [- 5 1] [- - -] [= = =] [= = =] [- 3 8] [- - -] ]
    ]
    [
        [Cox 'l3' 1 +]
    ]
]




[ AlikeX 'adds-like-multiplication' [+]
    'Addition is performed using the pattern for multiplication \
(e.g., 3+6=9, 3+4=7).'
    [
        [+ [- 4 6] [- - -] [- - 3] [- - -] [= = =] [= = =] [- 7 9] [- - -] ]
    ]
    [
        [Cox 'l2' 4 +]
    ]
]


[ stutterA 'stutter-add' [+]
    'When there is an empty cell in the problem, the last digit in the bottom\
 row is used as the addend.'
    [
        [ + [- 4 2 1] [- - - -] [- - 3 4] [- - - -] [= = = =] [= = = =]
            [- 7 5 5] [- - - -] ]
    ]
    [
        [Buswell 'a26' 18 +]
        [Attisha 'AL14-10']
    ]
]


[ SforA  'subtracts-instead-of-adding' [+]
    'The subject uses the subtraction algorithm instead of addition algorithm.'
    [
        [+ [- 1 5] [- - -] [- - 2] [- - -] [= = =] [= = =] [- 1 3] [- - -]]
    ]
    [
        [Cox 'l1247' 11 +]
        [Attisha 'AS12-14']
    ]
]


;;; Composite bug, where the major bug is subtracts-instead-of-adding.
;;; [ Snodec 'subtracts-instead-of-adding-no-dec' [+]
;;;     'The subject subtracts instead of adding, but does not decrement the\
;;; next digit when borrowing.'
;;;     [
;;;         [+ [- 7 8 2] [- - - -] [- 3 2 5] [- - - -] [= = = =] [= = = =]
;;;            [- 4 6 7] [- - - -] ]
;;;     ]
;;;     [
;;;         [Attisha 'AS12-19']
;;;     ]
;;; ]



[ CwrongA 'carries-wrong-digit' [+]
    'When a column result  needs to be carried, the wrong digit is carried.'
    [
        [ + [- 5 1 9] [- - - -] [- - 8 6] [- - - -]
        [= = = =] [= = = =] [- 9 1 1] [- 4 5 -] ]

    ]
    [
        [Buswell 'a8' 87 +]
        [Attisha 'AM10-11']
    ]
]




[ XforA 'multiplies-instead-of-adding' [+]
    'The subject multiplies, rather than adding.'
    [
        [+[- 3 4] [- - -] [- - 2] [- - -] [= = =] [= = =] [- 6 8] [- - -]]
    ]
    [
        [Attisha 'AM10-10']
    ]
]


[ lrA 'adds-left-to-right' [+]
    'Addition is done horizontally, left to right. E.g., 2+4=6, 5+3=8.'
    [
        [+[- 2 4] [- - -] [- 5 3] [- - -] [= = =] [= = =] [- 8 6] [- - -]]
    ]
    [
        [Buswell 'a29' 3 +]
        [Attisha 'AM10-12']
    ]
]




[ noCoverB 'does-not-carry-over-blank' [+]
    'The subject does not carry to a number which is over an empty cell.'
    [
        [+[- 4 6 8] [- - - -] [- - - 9] [- - - -] [= = = =] [= = = =]
          [- 4 6 7] ]
    ]
    [
        [Attisha 'AS12-11']
    ]
]


[ Qbottom 'quit-after-last-lower' [+]
    'When the last of the numbers in the lower row has been processed, \
the subject quits.'
    [
        [+[- 2 7 3] [- - - -] [- - 2 4] [- - - -] [= = = =] [= = = =]
          [- - 9 7] [- - - -] ]
    ]
    [
        [Attisha 'AS12-12']
    ]
]


[ nCA 'does-not-carry' [+]
    'The subject does not carry.'
    [
        [ + [- 3 4 5] [- - - -] [- - 7 6] [- - - -] [= = = =] [= = = =]
            [- 3 1 1] [- - - -] ]

    ]
    [
        [Cox 'l7' 2 +]
        [Attisha 'AS12-15']
        [Buswell 'a4' 126 +]
    ]
]


[ nCAone 'does-not-carry-ones' [+]
    'If the result of the ones column is a two digit number, the tens are not\
 carried.  The rest of the addition is correct'
    [
        [ + [- 3 4 5] [- - - -] [- - 7 6] [- - - -] [= = = =] [= = = =]
            [- 4 1 1] [- 1 - -] ]
    ]
    [
        [Cox 'l24678' 41 +]
    ]
]



[ dnrecord100s 'does-not-record-100s' [+]
    'The hundreds column answer is not recorded on the answer row.'
    [
        [ + [- 5 0 5] [- - - -] [- - 7 4] [- - - -] [= = = =] [= = = =]
            [- 0 7 9] [- - - -] ]
        [ + [- 4 7 6] [- - - -] [- - 1 7] [- - - -] [= = = =] [= = = =]
            [- - 9 3] [- - 1 -] ]

    ]
    [
        [Cox 'l56' 2 +]
    ]
]


[ Rtowrongcolumn 'renames-to-wrong-column' [+]
    'When renaming, the subject renames the carry to the wrong column.  In\
 the example, the carry from the units column was renamed to the hundreds\
 column.'
    [
        [ + [- 4 7 6] [- - - -] [- - 1 7] [- - - -] [= = = =] [= = = =]
            [- 5 8 3] [- 1 - -] ]
    ]
    [
        [Cox 'l66' 4.5 +]
    ]
]

[ onetoomany 'one-one-too-many' [+]
    'The answer in the ones column is one more than it should be.'
    [
        [ + [- 5 2] [- - -] [- 8 6] [- - -] [- 1 4] [- - -] [= = =] [= = =]
            [1 5 3] [- - -] ]
    ]
    [
        [Cox 'l8' 1.5 +]
    ]
]



[ copyonesA 'copies-ones-and-increments' [+]
    'The ones addend in the second row is incremented and given as the answer\
 to the ones column.'
    [
        [ + [- 4 7 6] [- - - -] [- - 1 7] [- - - -] [= = = =] [= = = =]
            [- 4 8 8] [- - - -] ]
    ]
    [
        [Cox 'l6' 1 +]
    ]
]






[ CAtoN 'carry-added-to-column' [+]
    'The carry digit is added into the answer for the current column. In \
this example, 1+3=4, 7+8=15, 1+5=6, 2+5=7.'
    [
        [+ [- 2 7 1] [- - - -] [- 5 8 3] [- - - -] [= = = =] [= = = =]
           [- 7 6 4] [- - - -] ]
    ]
    [
        [Attisha 'AS12-16']
        [Cox 'l4' 2 +]
;;;        [Attisha 'M13-13']
    ]
]

;;; Same as above CAtoN
;;; [ ACtosum 'adds-carry-to-column-sum' [+]
;;;     'When the sum of a column is a two digit number, the carry digit is\
;;;  added to the units total, e.g., 4+7=11+1 =12.'
;;;     [
;;;         [ + [- 2 4] [- - -] [- 6 7] [- - -] [= = =] [= = =] [- 8 2] [- - -] ]
;;;     ]
;;;     [
;;;         [Cox 'l4' 2 +]
;;;     ]
;;; ]




[ ignorefirst 'ignores-first-column' [+]
    'The first column of the problem is ignored.'
    [
        [+ [- 3 2 5] [- - - -] [- 2 7 1] [- - - -] [= = = =] [= = = =]
           [- 5 9 -] [- - - -] ]
    ]
    [
        [Attisha 'AS12-17']
    ]
]


[ ignore10s 'ignores-10s-column' [+]
    'The tens column is ignored.'
    [
        [ + [- 4 8] [- - -] [- - 3] [- - -] [= = =] [= = =] [- 1 1] [- - -] ]
    ]
    [
        [Cox 'l2' 1 +]
    ]
]



[ QC 'quits-when-carry' [+]
    'When a carry is needed, the subject quits.'
    [
        [+ [- 2 7 3] [- - - -] [- 1 8 2] [- - - -] [= = = =] [= = = =]
           [- - - 5] [- - - -] ]
    ]
    [
        [Attisha 'AS12-18']
    ]
]


[ nAnEn 'N+N=N' [+]
    'The subject answers that the sum of two identical digits is just one\
 of the digits.'
    [
        [+ [- 3 2] [- - -] [- 4 2] [- - -] [= = =] [= = =] [- 7 2] [- - -]]
    ]
    [
        [Attisha 'AS12-20']
    ]
]



[ zerounits 'carry-zero-units' [+]
    'When renaming, the carry digit is correctly noted, but the subject\
 writes zero in the answer cell.'
    [
        [+ [- 7 5] [- - -] [- 1 8] [- - -] [= = =] [= = =] [- 9 0] [- 1 -]]
    ]
    [
        [Attisha 'AS12-21']
    ]
]


[ leftalign 'left-alignment' [+]
    'The subject writes the problem aligned against the left column.'
    [
        [+ [- 5 4] [- - -] [- 3 -] [- - -] [= = =] [= = =] [- 8 4] [- - -] ]
    ]
    [
        [Attisha 'AL14-11']
    ]
]

[ Cone10 'carries-one-to-10s' [+]
    'One is carried into the tens column when it is not necessary.'
    [
        [ + [- 4 6] [- - -] [- - 3] [- - -] [= = =] [= = =] [- 5 9] [- 1 -] ]
    ]
    [
        [Cox 'l13' 2 +]
    ]
]



[ Cone100 'carries-one-to-100s' [+]
    'One is carried into the hundreds column regardless of whether a carry\
 is or is not needed.'
    [
        [ + [- 5 0 5] [- - - -] [- - 7 4] [- - - -]
        [= = = =] [= = = =] [- 6 7 9] [- 1 - -] ]
    ]
    [
        [Cox 'l5' 1 +]
    ]
]


[ Ctwo 'carries-two' [+]
    'The subject carries two in every column.'
    [
        [+ [- 2 7 1] [- - - -] [- 4 1 2] [- - - -] [= = = =] [= = = =]
           [- 8 0 3] [- 2 2 -] ]
    ]
    [
        [Attisha 'AL14-12']
    ]
]


[ ConeCall  'carry-once-always-carry' [+]
    'Once the subject starts to carry a digit, it is always carried.'
    [
        [+ [- 1 2 7] [- - - -] [- 4 5 6] [- - - -] [= = = =] [= = = =]
           [- 6 8 3] [- 1 1 -] ]
    ]
    [
        [Attisha 'AL14-17']
    ]
]




[ Cten  'carries-ten' [+]
    'Ten is carried rather than one.  I.e., 7+5=12, 2+1+10=13.'
    [
        [+ [- 2 5] [- - -] [- 1 7] [- - -] [= = =] [= = =] [1 3 2] [- - -] ]
    ]
    [
        [Attisha 'AL14-14']
    ]

]

/*
-----------------------------------------------------------------------
                MULTIPLICATION BUGS START HERE
-----------------------------------------------------------------------
*/


[ dnRP 'does-not-rename-product' [x]
    'Digits carried over from a multiplication are written on the answer row.'
    [
        [ x [- 1 7] [- - -] [- - 5] [- - -] [= = =] [= = =] [5 3 5] [- - -]]
    ]
    [
        [Cox 'l6' 1 x]
        [Ainsworth 14 5 x]
    ]
]

[dnRPcopy10s 'does-not-rename-copies-10s' [x]
    'The product from the first multiplication is written in the answer row\
 without renaming, and the tens multiplicand is copied into the answer.'
    [
        [ x [- 1 6] [- - -] [- - 4] [- - -] [= = =] [= = =] [1 2 4] [- - -] ]
    ]
    [
        [Cox 'l3' 1 x]
    ]
]



[ CwrongX 'carries-wrong-digit' [x]
    'When the result of a multiplication or addition is a number that needs\
 to be carried, the wrong digit is carried.'
    [
        [x [- 7 2 4] [- - - -] [- - - 6] [- - - -] [= = = =] [= = = =]
          [4 8 1 2] [- 6 4 -]]
    ]
    [
        [Cox 'l4' 1 x]
        [Attisha 'M10-23']
        [Ainsworth 13 3 x]
        [Buswell 'm31' 9 x]
    ]
]


[ CwrongNum 'carries-wrong-number' [x]
    'A composite bug, where some number was carried, but it was the wrong\
 one (e.g., the units number as in \\bug{CwrongX}, or always a one, as in\
 \\bug{alwaysCone}).'
    []
    [
        [Buswell 'm5' 95 x]
    ]
]


[  digitomit 'digit-omitted' [x]
    'A digit in the product is not written down.  In the example, the subject\
 decided not to write down the 5 from 54 (\\x88=64, \\x86=48 + 6 = 54).'
    [
        [ x [- - - 6 8] [- - - - -] [- 9 8 7 8] [- - - - -]
            [= = = = =] [= = = = =] [- - - 4 4] [- - - 6 -] ]
    ]
    [
        [Buswell 'm25' 17 x]
    ]
]



[ nCpP 'does-not-carry-in-partial-product' [x]
    'The subject does not carry when adding the partial product.'
    [
        [x [- - 9 2 7] [- - - - -] [- - - 7 3] [- - - - -] [- - = = =]
           [- - = = =] [- 2 7 8 1] [- - - - -] [6 4 8 9 0] [- - - - -]
           [= = = = =] [= = = = =] [6 6 5 7 1] [= = = = =] ]
    ]
    [
        [Attisha 'M13-12']
    ]
]


[ nXZEn 'N$\\times$0=N' [x]
    'When N is multiplied by zero, N is the answer.'
    [
        [x [- 3 0 2] [- - - -] [- - - 3] [- - - -] [= = = =] [= = = =]
           [- 9 3 6] [- - - -] ]
    ]
    [
        [Cox 'l26810' 14 x]
        [Attisha 'M10-11']
        [Ainsworth 3 16 x]
        [Buswell 'm9,m15' 120 x]
    ]
]



[ ZXnEZCn '0$\\times$N=0-carry-N' [x]
    'When multiplying by zero, zero is written as the column\'s answer, but\
 the multiplicand is carried.'
    [
        [x [- 2 0] [- - -] [- - 3] [- - -] [= = =] [= = =] [- 9 0] [- 3 -] ]
    ]
    [
        [Ainsworth '2a' 2 x]
    ]
]




[ CAbeforeX 'carry-added-to-multiplicand' [x]
    'The carry digit is added to the multiplicand before multiplying. I.e.,\
 \\x67=42, (2+4)$\\times$6=36, (3+3)$\\times$6=36. '
    [
        [x [- 3 2 7] [- - - -] [- - - 6] [- - - -] [= = = =] [= = = =]
           [3 6 6 2] [- 3 4 -] ]
    ]
    [
        [Attisha 'M19-13']
        [Cox 'l345' 9 x]
        [Buswell 'm36' 4 x]
    ]
]


[ repX 'repeated-multiplication' [x]
    'A multiplication was repeated.'
    [
        [ x [- 4] [- -] [- 2] [- -] [= =] [= =] [8 8] [- -] ]
    ]
    [
        [Buswell 'm37' 3 x]
    ]
]



;;;[ XbyC 'multiplies-by-carry' [x]
;;;    'The carry digit is used as the multiplicand, e.g., \\x78=56, \
;;; \\x58=40, etc.'
;;;    [
;;;        [x [- 5 2 1 7] [- - - - -] [- - - - 8] [- - - - -]
;;;           [= = = = =] [= = = = =] [4 3 2 0 6] [- 3 4 5 -] ]
;;;    ]
;;;    [
;;;        [Attisha 'M10-14']
;;;    ]
;;;]

[ XCbymult 'multiplies-carry' [x]
    'When there is a carry digit in the current column, it is used for\
 multiplication instead of the multiplicand. I.e., \\x84=32, \\x34=12,\
 and so on.'
    [
        [x [- 3 0 8] [- - - -] [- - - 4] [- - - -] [= = = =] [= = = =]
           [- 4 2 2] [- 1 3 -] ]
    ]
    [
        [Cox 'l45' 6 x]
        [Attisha 'M11-16']
;;;        [Attisha 'M10-14']
    ]
]




[ XPbyC 'multiplied-product-by-carry' [x]
    'The carry digit is multiplied by the product, rather than being\
 added to it.  In this example, \\x39=27, \\x31=3, \\x32=6.'
    [
        [x [- 1 9] [- - -] [- - 3] [- - -] [= = =] [= = =]
           [- 6 7] [- 2 -] ]
    ]
    [
        [Attisha 'M10-24']
        [Cox 'l3' 2 x]
    ]
]




[ XbyCwhenZ 'multiply-by-carry-when-zero' [x]
    'When the multiplicand is zero, the subject prefers to multiply by the\
 carry digit.'
    [
        [x [- - 4 0 6] [- - - - -] [- - - 7 3] [- - - - -]
           [= = = = =] [= = = = =] [- 1 2 3 8] [- - - 1 -]
           [3 0 8 2 0] [- 2 4 - -] ]
    ]
    [
        [Cox 'l8' 2 x]
        [Attisha 'M10-15']
    ]
]

;;; Duplicated entry for XbyCwhen
;;; [ XmultiplierbyCwhenZ 'multiplier-by-carry-when-zero' [x]
;;;     'When the multiplicand is zero, the subject multiplies the carry by the\
;;;  multiplier.  In the second answer row of the example, \\x59=45, \\x54=20,\
;;;  \\x58=40.'
;;;     [
;;;         [ x [- - - 8 0 9] [- - - - - -] [- - - - 5 2] [- - - - - -]
;;;             [= = = = = =] [= = = = = =] [- - 1 6 2 8] [- - - - 1 -]
;;;             [- 4 2 0 5 0] [- 4 2 4 - -] ]
;;;     ]
;;;     [
;;;         [Cox 'l8' 2 x]
;;;     ]
;;; ]



[ XCbyremains 'multiplies-by-carry-over-blank' [x]
    'When the multiplicand is over an empty cell, the subject multiplies\
 by the carry digit.'
    [
        [x [- 7 6] [- - -] [- - 4] [- - -] [= = =] [= = =] [1 4 4] [- 2 -]]
    ]
    [
        [Attisha 'M10-16']
    ]
]


[ alwaysC 'always-carries' [x]
    'The subject always adds in the carry digit.'
    [
        [x [2 4 2 9] [- - - -] [- - - 2] [- - - -] [= = = =] [= = = =]
           [5 9 5 8] [- - 1 -] ]
    ]
    [
        [Attisha 'M10-17']
        [Buswell 'm39' 1 x]
    ]
]


[ alwaysCone 'always-carries-one' [x]
    'When a carry occurs, the subject adds one to a column answer, not the\
 real carry.'
    [
        [x [- 5 1 4] [- - - -] [- - - 7] [- - - -] [= = = =] [= = = =]
           [3 5 8 8] [- - 2 -] ]
    ]
    [
        [Attisha 'M10-18']
    ]
]

[ ConeCallX 'carry-once-always-carry' [x]
    'Once the subject starts to carry a digit, it is always carried.'
    [
        [ x [- 1 1 2] [- - - -] [- - - 7] [- - - -] [= = = =] [= = = =]
            [- 8 8 4] [- 1 1 -] ]

    ]
    [
        [Cox 'l5' 1 x]
    ]
]



[ ACtotop 'adds-carry-and-multiplicand' [x]
    'The carried digit is added to the multiplicand, and this sum is given\
 as the column answer.  E.g., \\x68=48, 3+4=7.  The final \`\`5\'\' was\
 copied.'
    [
        [x [- 5 3 6] [- - - -] [- - - 8] [- - - -] [= = = =] [= = = =]
           [- 5 7 8] [- - 4 -] ]
    ]
    [
        [Attisha 'M10-19']
    ]
]


[ ACtobot 'adds-carry-and-multiplier' [x]
    'The carried digit is added to the multiplier, and this sum is given\
 as the column answer.  I.e., \\x45=20, 4+2=6, \\x48=32. '
    [
        [ x [- 8 0 5] [- - - -] [- - - 4] [- - - -] [= = = =] [= = = =]
            [3 2 6 0] [- - 2 -] ]
    ]
    [
       [Cox 'l45' 10 x]
    ]
]



[ ACtobotZ 'adds-carry-and-multiplier-when-zero' [x]
    'When the multiplicand is a zero, the subject adds the carry digit\
 and the multiplier to obtain an answer.  In the example, \\x27=14,\
 1+2=3, \\x25=10.'
    [
        [ x [- 5 0 7] [- - - -] [- - - 2] [- - - -] [= = = =] [= = = =]
            [1 0 3 4] [- - 1 -] ]
    ]
    [
        [Cox 'l8' 1 x]
    ]
]

[ dnAC 'does-not-add-carry' [x]
    'The carry digit is not added to the column product.\
 Cox notes this error when the subject misses just one carry in a problem\
 (not necessarily every carry).'
    [
        [x [- 1 4 9] [- - - -] [- - - 4] [- - - -] [= = = =] [= = = =]
           [- 4 6 6] [- 1 3 -] ]
    ]
    [
        [Cox 'l58910' 5 x]
        [Attisha 'M10-21']
;;;        [Attisha 'M11-14']
        [Buswell 'm7' 89 x]
    ]
]


[ pPconf 'partial-product-confusion' [x]
    'A general, combination error in which the subject had difficulty when\
 the problem had two or more multipliers.  In the first example, \\x45=20,\
 \\x24=8+2=10, \\x21=2+1=3.  In the second example, the second and third\
 products are written on the same answer row.'
    [
        [ x [1 4 4] [- - -] [- 2 5] [- - -] [= = =] [= = =] [3 0 0] [1 2 -] ]
        [ x [- - - - - - 5 1 2] [- - - - - - - - -]
            [- - - - - - - 2 5] [- - - - - - - - -] [= = = = = = = = =] [= = = = = = = = =]
            [- - - - - - 5 1 2] [- - - - - - - - -]
            [- 1 0 2 4 1 5 3 6] [- - - - - - - - -] [= = = = = = = = =] [= = = = = = = = =]
        ]
    ]
    [
        [Buswell 'm19' 32 x]
    ]
]




[ QafterfirstX 'quits-after-first-multiplication' [x]
    'Only the first multiplication is completed.'
    [
        [x [- 2 4 7] [- - - -] [- - - 4] [- - - -] [= = = =] [= = = =]
           [- - 2 8] [- - - -]  ]
    ]
    [
        [Attisha 'M10-22']
    ]
]



[ Qat100s 'quits-at-100s' [x]
    'The subject quits multiplying after processing the tens column.'
    [
        [ x [- - 2 2 4] [- - - - -] [- - 1 1 8] [- - - - -]
            [= = = = =] [= = = = =] [- 1 7 9 2] [- - - - -]
            [- 2 2 4 0] [- - - - -] ]
    ]
    [
        [Cox 'l10' 1 x]
    ]
]

[ Qafterfirstbottom 'quits-after-first-multiplier' [x]
    'Only the first multiplier is used.'
    [
        [x [- 3 4 6] [- - - -] [- - 2 8] [- - - -] [= = = =] [= = = =]
           [2 7 6 8] [- 3 4 -] ]
    ]
    [
        [Attisha 'M12-16']
        [Ainsworth 5 2 x]
        [Buswell 'm12' 52 x]
    ]
]

[ AinsteadX 'adds-instead-of-multiplying' [x]
    'The addition algorithm is used instead of multiplication.'
    [
        [x [- 7 2 5] [- - - -] [- - - 3] [- - - -] [= = = =] [= = = =]
           [- 7 2 8] [- - - -] ]
    ]
    [
        [Attisha 'M11-10']
        [Cox 'l12' 3 x]
    ]
]


[ copymultiplicand 'copies-multiplicand' [x]
    'No multiplication is performed, but the multiplicand is copied to the\
 answer row.'
    [
        [x [- 2 0 0] [- - - -] [- - - 4] [- - - -] [= = = =] [= = = =]
           [- 2 0 0] [- - - -] ]
    ]
    [
        [Cox 'l2' 5 x]
        [Attisha 'M11-11']
        [Buswell 'm35' 4 x]
    ]
]


[ copymultiplicandless2 'copies-multiplicand-less-2' [x]
    'The answer is two less than the multiplicand.'
    [
        [ x [- 1 6] [- - -] [- - 4] [- - -] [= = =] [= = =] [- 1 4] [- - -] ]
    ]
    [
        [Cox 'l3' 1 x]
    ]
]


[ copymultiplicandZ 'copies-multiplicand-including-zero' [x]
    'The multiplicand is copied as the answer, but a zero is first\
 inserted into the answer.'
    [
        [ x [- 2 4 7] [- - - -] [- - 2 0] [- - - -] [= = = =] [= = = =]
            [2 4 7 0] [- - - -] ]
    ]
    [
        [Cox 'l6' 1 x]
    ]
]



[ dnRthencopy 'does-not-rename-first-then-copies' [x]
    'The first multiplication is performed, and the answer is written in the\
 answer without renaming, and remaining multiplicands are copied.'
    [
        [x [- 2 3 7] [- - - -] [- - - 4] [- - - -] [= = = =] [= = = =]
           [2 3 2 8] [- - - -] ]
    ]
    [
        [Attisha 'M12-12']
    ]
]

[ copyafterfirst 'copies-after-first-column' [x]
    'The first column of a problem is solved correctly, but the\
 remaining multiplicands are copied to the answer row.'
    [
        [x [- 3 1 3] [- - - -] [- - - 3] [- - - -] [= = = =] [= = = =]
           [- 3 1 9] [- - - -] ]
    ]
    [
        [Attisha 'M10-12']
        [Cox 'l1' 9 x]
    ]
]


[ copy100 'copies-multiplicand-at-100s' [x]
    'When processing the hundreds multiplier, the subject inserts two \
 zeros and copies the multiplicand.'
    [
        [ x [- - 5 1 9] [- - - - -] [- - 4 0 2] [- - - - -]
            [= = = = =] [= = = = =] [- 1 0 3 8] [- - - - -]
            [5 1 9 0 0] [- - - - -] ]
    ]
    [
        [Cox 'l10' 1 x]
    ]
]


[ noCfor10s 'does-not-carry-to-10s' [x]
    'The carried digit is not added to the product in the tens column.'
    [
        [ x [- 2 1 6] [- - - -] [- - - 6] [- - - -] [= = = =] [= = = =]
            [1 2 6 6] [- - 3 -] ]

    ]
    [
        [Attisha 'M11-13']
        [Cox 'l4' 1 x]
        [Ainsworth 18 3 x]
    ]

]

;;; [ dnAC10s 'does-not-add-carry-in-10s' [x]
;;;     'The subject does not add in the carry digit in the tens column.'
;;;     [
;;;         [ x [- 8 4 2] [- - - -] [- - - 7] [- - - -] [= = = =] [= = = =]
;;;             [5 8 8 4] [- - 1 -] ]
;;;     ]
;;;     [
;;;         [Cox 'l4' 1 x]
;;;     ]
;;; ]

[ workslr 'works-left-to-right' [x]
    'The subject starts at the left, adding carries to the right. In the\
 example, \\x53=15, \\x23=6+1=7.'
    [
        [ x [- 5 2] [- - -] [- - 3] [- - -] [= = =] [= = =] [- 5 7] [- - 1] ]
    ]
    [
        [Buswell 'm40' 1 x]
    ]
]



[ AinXpattern 'adds-using-multiplication-pattern' [x]
    'The subject uses the pattern for multiplication, but adds the digits.'
    [
        [ x [- 3 2 0] [- - - -] [- - - 4] [- - - -] [= = = =] [= = = =]
            [- 7 6 4] [- - - -] ]
    ]
    [
        [Cox 'l5' 2 x]
        [Attisha 'M11-15']
    ]
]


[ lrN   'answers-left-to-right' [x]
    'The subject writes the answer left to right.  In the example, \\x29=18,\
 subject writes 8 carries 1, and so on.'
    [
        [ x [- 7 1 2] [- - - -] [- - - 9] [- - - -] [= = = =] [= = = =]
            [8 0 6 4] [- 1 1 -] ]
    ]
    [
        [Attisha 'M11-17']
    ]

]



[ ACtomultiplicands 'adds-carry-to-multiplicands' [x]
    'A column\'s answer is the sum of the carry digit and the multiplicand.\
 E.g., \\x68=48, 3+4=7, 5+4=9.'
    [
        [ x [- 5 3 6] [- - - -] [- - - 8] [- - - -] [= = = =] [= = = =]
            [- 9 7 8] [- - 4 -] ]
    ]
    [
        [Attisha 'M11-18']
    ]
]


[ Zin100s 'spurious-zero-in-100s' [x]
    'A zero is inserted in the hundreds column for no apparent reason.'
    [
        [ x [- - 9 0 5] [- - - - -] [- - - 4 6] [- - - - -]
            [= = = = =] [= = = = =] [5 4 0 3 0] [- - - - -]
            [3 6 0 2 0] [- - - - -] ]
    ]
    [
        [Cox 'l8' 1 x]
    ]
]



[ firstZ 'zero-in-first-row' [x]
    'A zero is inserted at the start of the first row.  Subsequent rows have\
 the correct number of zeros.'
    [
        [ x [- - - 4 3 6] [- - - - - -] [- - - - 5 1] [- - - - - -]
            [= = = = = =] [= = = = = =] [- - 4 3 6 0] [- - - - - -]
            [- 2 1 8 0 0] [- - 1 3 - -] [= = = = = =] [= = = = = =]
            [- 2 6 1 6 0] [- - 1 - - -] ]
    ]
    [
        [Cox 'l10' 1 x]
        [Attisha 'M11-19']
    ]
]


[ XlikeA 'multiplies-using-addition-pattern' [x]
    'Uses the addition pattern, but multiplies.'
    [
        [x [- 5 2 4] [- - - -] [- 7 3 1] [- - - -] [= = = =] [= = = =]
           [3 5 6 4] [- - - -] ]
    ]
    [
        [Cox 'l6' 5 x]
        [Attisha 'M12-10']
        [Ainsworth 4 9 x]
    ]
]



[ revpP 'partial-product-reversed' [x]
    'The order of the digits is reversed in  the partial product. In the\
 example, the \`\`219\'\' should be \`\`912\'\'.'
    [
        [ x [- 4 5 6] [- - - -] [- 2 5 1] [- - - -] [= = = =] [= = = =]
            [- 4 5 6] [- - - -] [2 2 8 0] [- - - -] [- 2 1 9] [- - - -] ]
    ]
    [
        [Cox 'l9' 1 x]
        [Buswell 'm33' 6 x]
    ]
]


[ ignoreZX 'ignores-zero-multiplier' [x]
    'The first multiplier is ignored when it\'s a zero, and no \
 zero is inserted in the answer row.'
    [
        [ x [- 5 3] [- - -] [- 2 0] [- - -] [= = =] [= = =] [1 0 6] [- - -] ]
    ]
    [
        [Cox 'l6' 4 x]
        [Attisha 'M12-12']
    ]
]


[ manyZ 'too-many-annex-zeros' [x]
    'Too many zeros are inserted into the answer row when\
 multiplying by a multiple of ten.'
    [
        [ x [- - - - 5 5 3] [- - - - - - -] [- - - - - 2 0] [- - - - - - -]
            [= = = = = = =] [= = = = = = =] [1 1 0 6 0 0 0] [- - - - - - -] ]
    ]
    [
        [Cox 'l6' 1 x]
        [Attisha 'M12-13']
    ]
]


[ wrongleadingZ 'incorrect-number-of-annex-zeros' [x]
    'An incorrect number of zeros are inserted into one of the\
 answer rows.'
    [
        [ x [- - 4 5 6] [- - - - -] [- - 2 5 1] [- - - - -]
            [= = = = =] [= = = = =] [- - 4 5 6] [- - - - -]
            [2 2 8 0 0] [- - - - -] [9 1 2 0 0] [- - - - -] ]
    ]
    [
        [Cox 'l9910' 7 x]
    ]
]


[ nolead3 'no-annexing-in-third' [x]
    'No zeros were inserted for the third answer row.'
    [
    ]
    [
        [Cox 'l10' 3 x]
    ]
]




[ skipsZmultiplicand 'skips-zero-multiplicand' [x]
    'When the multiplicand contains a zero, the multiplication is skipped\
 and the reminding digits of the multiplicand are multiplied by the\
 multiplier directly under the zero.  In the example, \\x29=18, \\x85=40.'
    [
        [ x [- 8 0 9] [- - - -] [- - 5 2] [- - - -] [= = = =] [= = = =]
            [4 0 1 8] [- - - -] ]
    ]
    [
        [Attisha 'm12-14']
    ]
]


[ SpP 'subtracts-partial-product' [x]
    'The subject subtracts the partial product rather than adding.  In this\
 example the subject also subtracts the smaller number from the larger.'
    [
        [ x [- - 5 3] [- - - -] [- - 7 4] [- - - -] [= = = =] [= = = =]
            [- 2 1 2] [- - - -] [3 7 1 0] [- - - -] [= = = =] [= = = =]
            [3 5 0 2] [- - - -] ]
    ]
    [
        [Cox 'l7' 1 x]
        [Attisha 'M13-10']
    ]
]


[ incorrectApP 'partial-product-incorrectly-summed' [x]
    'The addition of the partial product is incorrect.  Cox apparently\
 used this category to cover a number of addition bugs.'
    [
        [ x [- - - 5 3] [- - - - -] [- - - 7 4] [- - - - -]
            [= = = = =] [= = = = =] [- - 2 1 2] [- - - - -]
            [- 3 7 1 0] [- - - - -] [= = = = =] [= = = = =]
            [- 4 4 2 2] [- - - - -] ]
    ]
    [
        [Cox 'l7910' 5 x]
    ]
]




[ Xlasttopwrites10 'multiplies-last-multiplicand-and-writes-10' [x]
    'The only multiplication performed is to multiply the multiplier by the\
 last multiplicand (\\x36 in the example).  The product is written in\
 the answer row, and ten is written after it.'
    [
        [ x [- - 3 0] [- - - -] [- - - 6] [- - - -] [= = = =] [= = = =]
            [1 0 1 8] [- - - -] ]
    ]
    [
        [Cox 'l2' 1 x]
    ]
]





[ Xmultiplicands 'multiplies-multiplicands' [x]
    'The first multiplication is correct, but the subject then multiplies the\
 multiplicands.  In this example, \\x14=4, \\x24=8.'
    [
        [ x [- 2 4] [- - -] [- 3 1] [- - -] [= = =] [= = =] [- 8 4] [- - -] ]
    ]
    [
        [Ainsworth 6 1 x]
    ]
]


[ crossX 'cross-multiplies' [x]
    'The digits of the problem are cross multiplied, e.g., \\x14=4, \\x32=6.'
    [
        [ x [- 4 2] [- - -] [- 3 1] [- - -] [= = =] [= = =] [- 6 4] [- - -] ]
    ]
    [
        [Ainsworth 7 1 x]
    ]
]


[ Xbyfirstdigit 'multiplies-all-by-first-multiplier' [x]
    'The first multiplier is used to multiply all the other digits.  In this\
 example, \\x12=2, \\x14=4, \\x13=3.'
    [
        [ x [- 4 2] [- - -] [- 3 1] [- - -] [= = =] [= = =] [3 4 2] [- - -] ]
    ]
    [
        [Ainsworth 8 3 x]
    ]
]


[ lastXlast 'last-digits-multiplied' [x]
    'The last multiplicand is multiplied by the last multiplier, rather than\
 multiply each multiplier by each multiplicand.  In the example, \\x27=14,\
 \\x20=0+1=1, then \\x53=15.'
    [
        [ x [- 5 0 7] [- - - -] [- - 3 2] [- - - -] [= = = =] [= = = =]
            [1 5 1 4] [- - 1 -] ]
    ]
    [
        [Cox 'l8' 2 x]
    ]
]


[ notwotwo 'last-multiplication-skipped' [x]
    'The second multiplicand is not multiplied by the second multiplier.'
    [
        [ x [- 3 2] [- - -] [- 4 1] [- - -] [= = =] [= = =] [- 3 2] [- - -]
            [- 8 0] [- - -] [= = =] [= = =] [1 1 2] [- - -] ]
    ]
    [
        [Ainsworth 9 1 x]
    ]
]


[ weird 'weird-order' [x]
    'The digits are multiplied in a strange order.  In this example, the\
 order is: \\x41=4, \\x21=2, \\x23=6, \\x24=8.'
    [
        [ x [- - 1 3] [- - - -] [- - 2 4] [- - - -] [= = = =] [= = = =]
            [8 6 2 4] [- - - -] ]
    ]
    [
        [Ainsworth 11 1 x]
    ]
]



[ Cnotraised 'carry-not-raised' [x]
    'The carry digit is not raised at the end of a answer row in \
the partial product.'
    [
        [ x [- - 4 2] [- - - -] [- - 4 1] [- - - -] [= = = =] [= = = =]
            [- - 4 2] [- - - -] [- 6 8 0] [1 - - -] [= = = =] [= = = =]
            [- 7 2 2] [- 1 - -] ]
    ]
    [
        [Ainsworth 17 1 x]
    ]
]

[ CAtotens 'carry-added-to-tens' [x]
    'When adding a carry digit to a product, the carry is added to the\
 tens part, e.g., \\x46=24, \\x42=8, 2+8=28.'
    [
        [ x [- - 2 6] [- - - -] [- - 1 4] [- - - -] [= = = =] [= = = =]
            [- 2 8 4] [- - 2 -] [- 2 6 0] [- - - -] [= = = =] [= = = =]
            [- 5 4 4] [- 1 - -] ]
    ]
    [
        [Ainsworth 19 1 x]
    ]
]


[ Nonerow 'answer-on-one-row' [x]
    'All the partial products are written on one answer row.'
    [
        [ x [- - 2 3] [- - - -] [- - 4 8] [- - - -] [= = = =] [= = = =]
            [9 3 8 4] [1 1 2 -] ]
    ]
    [
        [Ainsworth 21 21 x]
    ]
]


[ noleadingZ 'forgets-annex' [x]
    'The zero is forgotten.  In the example, a zero should\
 have been inserted into the second answer row.'
    [
        [ x [- - 4 5] [- - - -] [- - 2 9] [- - - -] [= = = =] [= = = =]
            [- 4 0 5] [- - 4 -] [- - 9 0] [- - 1 -] [= = = =] [= = = =]
            [- 4 9 5] [- - - -] ]
    ]
    [
        [Cox 'l8' 4 x]
        [Ainsworth 22 3 x]
        [Buswell 'm17' 39 x]
    ]
]


[ XpP 'multiplies-partial-product' [x]
    'The partial product is multiplied, not added, with the bug\
 \\bug{XlikeA}.'
    [
        [ x [- 3 2] [- - -] [- 2 1] [- - -] [= = =] [= = =]
            [- 3 2] [- - -] [6 4 0] [- - -] [= = =] [= = =]
            [7 2 0] [1 - -] ]
    ]
    [
        [Ainsworth 23 2 x]
    ]
]


[ multAtoN 'adds-multiplicand-to-answer' [x]
    'A multiplicand is not multiplied, but instead is added to the answer. \
I.e., \\x36=18, 7+1=8.'
    [
        [ x [- 7 6] [- - -] [- - 3] [- - -] [= = =] [= = =] [- 8 8] [- 1 -] ]
    ]
    [
        [Buswell 'm22' 28 x]
    ]
]


[ dnApP 'does-not-add-partial-product' [x]
    'The subject does not add the partial product, leaving the sum as shown\
 in the example.'
    [
        [ x [- - - 5 3] [- - - - -] [- - 3 2 1] [- - - - -] [= = = = =] [= = = = =]
            [- - - 5 3] [- - - - -] [- 1 0 6 0] [- - - - -]
            [1 5 9 0 0] [- - - - -] ]
    ]
    [
        [Buswell 'm29' 12 x]
    ]
]



[ ACtoP 'adds-carry-to-product' [x]
    'When the result of a multiplication is a two digit number, those\
 numbers are added, e.g., \\x35=15=6.'
    [
        [ x [- - 5 2] [- - - -] [- - 1 3] [- - - -] [= = = =] [= = = =]
            [- - 6 6] [- - - -] [- 5 2 0] [- - - -] [= = = =] [= = = =]
            [- 5 8 6] [- - - -] ]
    ]
    [
        [Ainsworth 12 1 x]
    ]
]




/*
-----------------------------------------------------------------------
                        END OF BUG LIST
-----------------------------------------------------------------------
*/

];


define author_totals(author,freq,context,a_totals) -> a_totals;
    vars tfreq;

    if a_totals matches [== [^author ^^context ?tfreq] ==] then
        delete([^author ^^context ^tfreq],a_totals) -> a_totals;
        tfreq + freq -> freq;
    endif;
    [^author ^^context ^freq] :: a_totals -> a_totals;


enddefine;


define add_bug(c,w);
    vars n, total=1;

    if bug_count matches [==[^^c ^w ?n]==] then
        delete([^^c ^w ^n],bug_count) -> bug_count;
        n + total->total;
    endif;
    [^^c ^w ^total] :: bug_count -> bug_count;
enddefine;

define latex_list();
    vars
        ltt_center = false, author, acode, line, entry,
        adev, mdev, dev, freqs, freq, flabel, all_occur,
        freq_info, pc, a_cox_total = 0, m_cox_total = 0, bugkeys = [],
        name, context, des, egs, cites, eg, negs, s, example, key,
        a_totals = [], total_freq, bug_count = [], flist, lowercasename;



    fopen('~/papers/dphil/addlist.tex',"w") -> adev;
    fopen('~/papers/dphil/multlist.tex',"w") -> mdev;

    finsertstring(adev,'\\par\\bigskip\\par');
    finsertstring(mdev,'\\par\\bigskip\\par');


    for entry in buglist do

        entry --> [?key ?name ?context ?des ?egs ?cites];

        if member(key,bugkeys) then
            mishap('Conflicting keys',[^key ^name]);
        else
            key :: bugkeys -> bugkeys;
        endif;

        ''><name -> lowercasename;
        lowertoupper(name(1)) -> name(1);

        if context = [+] then
            adev -> dev;
        elseif context = [x] then
            mdev -> dev;
        else
            mishap('Unrecognized context',[^context]);
        endif;

        '' -> freq_info;



        [%        for line in cites do

                line --> [?author ?acode ??freqs];

                unless citelist matches [== [= ^author ==] ==] then
                    [Author ^author unknown for bug ^name] =>
                endunless;

                0 -> total_freq;

                unless freqs = [] then

                    freqs --> [?freq ?flabel];
                    citelist --> [== [= ^author == [freq == ?all_occur ^flabel ==]==]==];
                    (freq/all_occur)*100.0 -> pc;
                    round(pc*100)/100.0 -> pc;
                    freq_info ><author><': '><pc><'\\% ('><freq><' of '><all_occur
                    ><') ' -> freq_info;
                    [%
                        pc;
                        author; ;;; ><' ('><acode><')';
                        ;;;                        pc><'\\% ('><freq><' of '><all_occur><')';
                        pc><'\\%';
                    %];


                    freq + total_freq -> total_freq;

                    if hd(context) /= flabel then
                        [The statistics label ^flabel does not match context ^^context for ^name] =>
                    endif;

                else
                    [% -100+(author(1)); author >< ''; ''; %];

                endunless;

                author_totals(author,total_freq,context,a_totals) -> a_totals;


            endfor;
        %] -> f_list;


        syssort(f_list, procedure(a,b);
                a(1) > b(1);
            endprocedure) -> f_list;


        if freq_info = '' then
            'No frequency data' -> freq_info;
            add_bug(context,'Without');
        else
            add_bug(context,'With');
        endif;



        fputstring(dev,
            '\\bugitem{'><key><'}{'><lowercasename><'} \\nopagebreak '
            ;;;            '\\noindent{\\bf '><name><'} ('><key><'). \\nopagebreak '
            ><des ><
            '\\nopagebreak\\par\\nopagebreak\\medskip\\nopagebreak ');
;;;            '\\nopagebreak\\par\\nopagebreak\\medskip\\nopagebreak\\noindent');



        length(egs) -> negs;

        for eg from 1 to negs do    ;;; for each example...

            egs(eg) -> example;
            hd(example) -> s;

            if member(s,[x +]) then ;;; if explicitly specified sign...
                tl(example) -> example;
            else ;;; else use the "context" entry
                context(1) -> s;
            endif;

            list_to_tabular(s,example,dev);
            finsertstring(dev,'\\hfil');
        endfor;

;;;        finsertstring(dev,'\\hfil ');

        unless f_list = nil then
            finsertstring(dev,'\\begin{tabular}[t]{lr}');  ;;; update here
            foreach [= ?author ?pc] in f_list do
                finsertstring(dev,author><'&'><pc><'\\\\');
            endforeach;
            finsertstring(dev,'\\end{tabular}');
        endunless;



        finsertstring(dev,'\\par\\bigskip');


    endfor;

    fclose(adev);
    fclose(mdev);


    vars s, wf, wof, name, s, a_freq, a_wf, a_wof, gwf, gwof;

    for s in [+ x] do
        foreach [?name ^s ?a_freq] in a_totals do

            pr_field(name,15,false,' ');  pr(a_freq); pr(' '); pr(s);
            pr(' bugs.');

            unless citelist matches [ == [= ^name == [freq == ^a_freq ^s ==]==]==] then
                pr(' <--- TOTALS MISMATCH');
            endunless;

            nl(1);
        endforeach;

    endfor;


    vars gt;
    0 -> gt;
    for w in ['With' 'Without'] do
        0 -> t;
        foreach [?s ^w ?n] in bug_count do
            [^s ^w ^n] =>
            n+t->t;
        endforeach;
        [Total ^w ^t] =>
        gt + t -> gt;
    endfor;
    [Grand total ^gt bugs] =>

    vars Tx, Txw, Tp, Tpw;

    bug_count --> [==[x 'With' ?Tx]==];
    bug_count --> [==[x 'Without' ?Txw]==];
    Tx + Txw -> Tx;
    bug_count --> [==[+ 'With' ?Tp]==];
    bug_count --> [==[+ 'Without' ?Tpw]==];
    Tp + Tpw -> Tp;

    vars dev = fopen('~/papers/dphil/totals.tex',"w");
    fputstring(dev,'\\def\\Tbgs{'><gt><'} % Total all bugs');
    fputstring(dev,'\\def\\Tx{'><Tx><'} % Total x bugs ');
    fputstring(dev,'\\def\\Tp{'><Tp><'} % Total + bugs');
    fputstring(dev,'\\def\\Txw{'><Txw><'} % Total x bugs without freq data');
    fputstring(dev,'\\def\\Tpw{'><Tpw><'} % Total + bugs without freq data');
    fputstring(dev,'\\typeout{TOTALS.TEX x '><Tx><'-'><Txw><', + '><
                Tp><'-'><Tpw><' = '><gt><'}');
    fclose(dev);


enddefine;




define sort_buglist;

    syssort(buglist,false, procedure(a,b);

            vars
                line, data, total, author,
                name1, cite1, data_for_1 = false, biggest_1 = 0,
                name2, cite2, data_for_2 = false, biggest_2 = 0;

            a --> [= ?name1 = = = ?cite1];
            for line in cite1 do
                line --> [?author = ??data];
                if data /= nil then
                    citelist --> [== [= ^author == [freq == ?total ^(data(2)) ==] ==] ==];
                    biggest_1 + data(1)/total -> biggest_1;
                    true -> data_for_1;
                endif;
            endfor;

            b --> [= ?name2 = = = ?cite2];
            for line in cite2 do
                line --> [?author = ??data];
                if data /= nil then
                    citelist --> [== [= ^author == [freq == ?total ^(data(2)) ==] ==] ==];
                    biggest_2 +  data(1)/total  -> biggest_2;
                    true -> data_for_2;
                endif;
            endfor;

            if data_for_1 then
                if data_for_2 then  ;;; Both have data
                    ;;; Pick largest freq
                    if biggest_1 = biggest_2 then
                        alphabefore(name1,name2);
                    else
                        biggest_1 > biggest_2;
                    endif;
                else
                    ;;; Select 1
                    true;
                endif;
            elseif data_for_2 then
                ;;; No data for 1 so...
                false;
            else
                ;;; No data for either, use alphabetic order
                alphabefore(name1,name2);
            endif;

        endprocedure) -> buglist;

enddefine;




define sort_buglist_alpha;
    syssort(buglist,false, procedure(a,b);
            alphabefore(uppertolower(a(2)),uppertolower(b(2)));
        endprocedure) -> buglist;
enddefine;


define process_freq_author(author_abrv,f) -> string;
    lvars i,n=length(author_abrv);
    vars author;
    ''->string;
    for i from 1 to n do
        author_abrv(i) --> [?author =];
        if f matches [== ^author ?pc ==] then
            string >< ' \\dec '>< pc >< ' ' -> string;
        else
            string >< ' ' -> string;
        endif;

        unless i==n then
            string >< '&' -> string;
        endunless;
    endfor;
enddefine;




define latex_freq(n);
    vars dev, entry, name, f_list, add_count=1,mult_count=1,adds=[],mult=[], line, cites,
        flabel, all_occur,pc,author,freq,authorLs,author_abrv=[],abrv;

    fopen('~/papers/dphil/freqlist.tex',"w") -> dev;

    vars a_string, m_string, a_authors, m_authors, a_list, m_list;

    [ [Ainsworth A] [Buswell B] [Cox C]] -> m_authors;
    'l|l|l|' -> m_string;
    length(m_string)/2 -> m_cols;
    'A&B&C' -> m_list;

    [ [Buswell B] [Cox C] ] -> a_authors;
    'l|l|' -> a_string;
    length(a_string)/2 -> a_cols;
    'B&C' -> a_list;


'\\cline{1-'><(2+a_cols) ><'}'><
'\\cline{'><(4+a_cols)><'-'><(4+a_cols+m_cols)><'}'
        -> cstring;

    fputstring(dev,'\\setdec 00.00');
    fputstring(dev,'\\begin{tabular}{|l||l|'><a_string><
        'l@{\\hspace{5mm}}|l|'><m_string><'}');

    fputstring(dev,cstring><'\\multicolumn{'><(2+a_cols)><
        '}{|c|}{Addition}&&\\multicolumn{'
        ><(m_cols+1)><'}{|c|}{Multiplication}\\\\');

    fputstring(dev,cstring><'Rank&Bug&'><a_list><'&&Bug&'><m_list><'\\\\');


    for entry in buglist do

        entry --> [= ?name ?context ?des ?egs ?cites];

        name><'' -> lowercasename;

        [% for line in cites do
                line --> [?author = ??freqs];
                unless freqs = [] then
                    freqs --> [?freq ?flabel];
                    citelist --> [== [= ^author == [freq == ?all_occur ^flabel ==]==]==];
                    (freq/all_occur)*100.0 -> pc;
                    round(pc*100)/100.0 -> pc;
                    author; pc;
                endunless;
            endfor; %] -> f_list;

        if context = [+] then
            [^add_count ^name ^f_list] :: adds -> adds;
            add_count + 1 -> add_count;
        elseif context = [x] then
            [^mult_count ^name ^f_list] :: mult -> mult;
            mult_count + 1 -> mult_count;
        endif;
    endfor;

    for i from 1 to n do
        adds --> [==[^i ?aname ?af]==];
        mult --> [==[^i ?mname ?mf]==];
        process_freq_author(a_authors,af) -> a_freq;
        process_freq_author(m_authors,mf) -> m_freq;
        fputstring(dev,cstring><i><'&'><aname><'&'><a_freq><
            ' &&'><mname><'&'><m_freq><' \\\\');
    endfor;

    fputstring(dev,cstring><'\\end{tabular}');
/*
    fputstring(dev,'\\par\\bigskip\\noindent{\\bf Key: }');

    [^^m_authors ^^a_authors] -> all;

    until all = [] do
        dest(all) -> all -> aa;
        while aa isin all do
            delete(aa,all) -> all;
        endwhile;
        aa --> [?author ?abrv];
        finsertstring(dev,abrv><'='><author><'\ \ \ ');
    enduntil;

*/
    fclose(dev);

enddefine;



/*



;;; ved flib.tex

;;;sort_buglist();


;;; TO GENERATE FILES
sort_buglist_alpha();
latex_list();
;;; re-load then...
sort_buglist(); ;;; frequency order
latex_freq(28);
;;; END OF TO GENERATE FILES



sysobey('latex ftest');

sysobey('xdvi ftest &');

sysobey('dvips -Pspb ftest');
*/
