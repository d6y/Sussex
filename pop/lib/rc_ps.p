

lconstant basic_fonts = [
    [
    ;;; X font name     Postscript name
        [courier        Courier]
    [helvetica      Helvetica]
    [times      Times]
    [symbol         Symbol]

    ;;; X fixed width fonts Postscript equivelants
    [fixed      Courier]
    [screen         Courier]
    [terminal       Courier]
    [lucidatypewriter   Courier]

    ;;; Extra fonts     Postscript equivelants
    [charter        Times]
    [palatino       Times]
    [%"'itc bookman'"%  Times]
    [bookman        Times]
    [%"'new century schoolbook'"%   Times]

    [clean      Helvetica]
    [lucidabright       Helvetica]
    [%"'lucida+sans'"%  Helvetica]
    [%"'helvetica+narrow'"%     Helvetica]
    [%"'itc avant garde gothic'"%   Helvetica]
    [avantgarde         Helvetica]
    [default        Helvetica]
    ]
    [
    [Times {
    'Times-Roman' 'Times-Italic'
    'Times-Bold' 'Times-BoldItalic'}]
    [Helvetica {
    'Helvetica' 'Helvetica-Oblique'
    'Helvetica-Bold' 'Helvetica-BoldOblique'}]
    [Courier {
    'Courier' 'Courier-Oblique'
    'Courier-Bold' 'Courier-BoldOblique'}]
    [Symbol {
    'Symbol' 'Symbol'
    'Symbol' 'Symbol'}]
    ]
];

lconstant lw2_fonts = [
    [
    ;;; X font name     Postscript equivelant
        [courier        Courier]
        [helvetical         Helvetica]
    [%"'helvetica+narrow'"%     HelveticaNarrow]
    [times      Times]
    [symbol         Symbol]
    [%"'itc bookman'"%  Bookman]
    [%"'itc avant garde gothic'"%   AvantGarde]
    [%"'itc zapf dingbats'"%    ZapfDingbats]
    [%"'itc zapf chancery'"%    ZapfChancery]
        [avantegarde        AvantGarde]
        [bookman        Bookman]
        [zapfchancery       ZapfChancery]
        [zapfdingbats       ZapfDingbats]
    [palatino       Palatino]
    [%"'new century schoolbook'"%   NewCenturySchlbk]
    [%"'lucida+sans'"%  HelveticaNarrow]
    [lucidatypewriter   Courier]
    [lucidabright       Helvetica]
    [fixed      Courier]
    [screen         Courier]
    [terminal       Courier]
    [clean      Helvetica]
    [charter        Times]
    [default        Helvetica]
    ]
    [
        [AvantGarde {
    'AvantGarde-Book' 'AvantGarde-BookOblique'
            'AvantGarde-Demi' 'AvantGarde-DemoOblique'}]
        [Bookman {
    'Bookman-Light' 'Bookman-LightItalic'
    'Bookman-Demo' 'Bookman-DemiItalic'}]
    [Courier {
    'Courier' 'Courier-Oblique'
            'Courier-Bold' 'Courier-BoldOblique'}]
    [Helvetica {
    'Helvetica' 'Helvetica-Oblique'
            'Helvetica-Bold' 'Helvetica-BoldOblique'}]
    [HelveticaNarrow {
    'Helvetica-Narrow' 'Helvetica-Narrow-Oblique'
            'Helvetica-Narrow-Bold' 'Helvetica-BoldOblique'}]
        [NewCenturySchlbk {
    'NewCenturySchlbk-Roman' 'NewCenturySchlbk-Italic'
            'NewCenturySchlbk-Bold' 'NewCenturySchlbk-BoldItalic'}]
        [Palatino {
    'Palatino-Roman' 'Palatino-Italic'
            'Palatino-Bold' 'Palatino-BoldItalic'}]
    [Times {
    'Times-Roman' 'Times-Italic'
            'Times-Bold' 'Times-BoldItalic'}]
    [ZapfChancery {
    'ZapfChancery-MediumItalic' 'ZapfChancery-MediumItalic'
            'ZapfChancery-MediumItalic' 'ZapfChancery-MediumItalic'}]
        [ZapfDingbats {
    'ZapfDingbats' 'ZapfDingbats'
                'ZapfDingbats' 'ZapfDingbats'}]
        [Symbol {
    'Symbol' 'Symbol'
    'Symbol' 'Symbol'}]
    ]
];


global vars rcp_postscript_font_map = newproperty([], 10, false, "perm");
global vars rcp_postscript_style_map = newproperty([], 10, false, "perm");

define rcp_use_standard_fonts();
    clearproperty(rcp_postscript_font_map);
    clearproperty(rcp_postscript_style_map);
    applist(basic_fonts.hd, procedure(x); lvars x;
    x.tl.hd -> rcp_postscript_font_map(x.hd);
    endprocedure);
    applist(basic_fonts.tl.hd, procedure(x); lvars x;
    x.tl.hd -> rcp_postscript_style_map(x.hd);
    endprocedure);
enddefine;

define rcp_use_lw2_fonts();
    clearproperty(rcp_postscript_font_map);
    clearproperty(rcp_postscript_style_map);
    applist(lw2_fonts.hd, procedure(x); lvars x;
    x.tl.hd -> rcp_postscript_font_map(x.hd);
    endprocedure);
    applist(lw2_fonts.tl.hd, procedure(x); lvars x;
    x.tl.hd -> rcp_postscript_style_map(x.hd);
    endprocedure);
enddefine;

;;; MAP FROM X FONTS TO POSTSCRIPT FONTS

XptWidgetSet("Poplog")("GraphicWidget")->;
uses XptNewWindow;
include x_atoms;
include xpt_xfontstruct;

INCLUDE_constant macro (
    XLFD_FOUNDRY    = 1,
    XLFD_FAMILY_NAME    = 2,
    XLFD_WEIGHT_NAME    = 3,
    XLFD_SLANT  = 4,
    XLFD_SETWIDTH_NAME  = 5,
    XLFD_ADD_STYLE_NAME     = 6,
    XLFD_PIXEL_SIZE     = 7,
    XLFD_POINT_SIZE     = 8,
    XLFD_RESOLUTION_X   = 9,
    XLFD_RESOLUTION_Y   = 10,
    XLFD_SPACING    = 11,
    XLFD_AVERAGE_WIDTH  = 12,
    XLFD_CHARSET_REGISTRY   = 13,
    XLFD_CHARSET_ENCODING   = 14,
);

lconstant FONT_FIELDS = [
    ;;; offical names
    foundry     1
    family_name     2
    weight_name     3
    slant   4
    setwidth_name   5
    add_style_name  6
    pixel_size  7
    point_size  8
    resolution_x    9
    resolution_y    10
    spacing     11
    average_width   12
    charset_registry    13
    charset_encoding    14
];


/* =========== XLFD Utility Procedures ==================================== */

;;; Translate between an XLFD string, a 14 element POP vector, and a list
;;; of the form [fieldname value ...]

define lconstant font_field_num(name);
    lvars name;
    name.isword and (fast_lmember(name, FONT_FIELDS) ->> name) and
    fast_front(fast_back(name));
enddefine;

define lconstant get_tmp_vec;
    lconstant tmp_vec = writeable initv(14);
    repeat 14 times "*" endrepeat -> explode(tmp_vec);
    tmp_vec;
enddefine;

define lconstant is_valid_xlfd_str(str);
    lvars str, count = 0, c;
    returnunless(str.isstring and datalength(str) fi_> 13
    and fast_subscrs(1, str) == `-`)(false);
    fast_for c in_string str do
    if c == `-` then
    count fi_+1 -> count;
    endif;
    endfast_for;
    count == 14;
enddefine;

define lconstant is_valid_xlfd_vec(vec);
    lvars vec, val, ok = true;
    returnunless(vec.isvector and datalength(vec) fi_<= 14)(false);
    fast_for val in_vector vec do
    val.isword or val.isnumber -> ok;
    returnunless(ok)(false);
    endfast_for;
    true;
enddefine;

define lconstant is_valid_xlfd_list(list);
    lvars list, name, val, ok = true;
    returnunless(list.islist and listlength(list) mod 2 == 0)(false);
    until list == [] do
    dest(list) -> list -> name;
    dest(list) -> list -> val;
    fast_lmember(name, FONT_FIELDS) and (val.isword or val.isnumber)-> ok;
    returnunless(ok)(false);
    enduntil;
    true;
enddefine;

define lconstant xlfd_str_explode(str);
    lvars str, c, isnum, count, i = 2, max_i = datalength(str) fi_+1;

    /* converts num numeric ASCII characters into an integer */
    define lconstant consint(num) -> accum;
        lvars accum = 0, shift = 1, num;
        fast_repeat num times
            (() fi_- `0`) fi_* shift fi_+ accum -> accum;
    shift fi_* 10 -> shift;
        endfast_repeat;
    enddefine;

    until i fi_>= max_i do
    true -> isnum;
    i -> count;
    until i == max_i or (fast_subscrs(i, str) ->> c) == `-` do
    c; i fi_+ 1 -> i; isnum and isnumbercode(c) -> isnum;
    enduntil;
    i fi_- count -> count; i fi_+1 -> i;
    if count == 0 then "-"
    elseif isnum then consint(count)
    else consword(count)
    endif;
    enduntil;
enddefine;

define lconstant xlfd_vec_explode(vec);
    lvars vec;
    explode(vec); repeat 14 fi_- datalength(vec) times "*" endrepeat;
enddefine;

define lconstant xlfd_list_explode(list);
    lvars list, vec = get_tmp_vec(), val, field;
    until list == [] do
    fast_destpair(list) -> list -> field;
    fast_destpair(list) -> list -> val;
    val -> fast_subscrv(font_field_num(field), vec);
    enduntil;
    explode(vec);
enddefine;

define global XptIsValidFontSpec(spec);
    lvars spec;
    spec.isstring and is_valid_xlfd_str(spec)
    or spec.isvector and is_valid_xlfd_vec(spec)
    or spec.islist and is_valid_xlfd_list(spec);
enddefine;

/* converts from one XLFD representation to another */

define global XptConvertFontSpec(src, dst);
    lvars src, field, val, dst, procedure explode_p, i;

    returnunless(XptIsValidFontSpec(src))(false);

    if src.isstring then xlfd_str_explode
    elseif src.islist then xlfd_list_explode
    elseif src.isvector then xlfd_vec_explode
    endif -> explode_p;

    explode_p(src); [] -> src;

    if dst.isstring or dst == "string" then
    dlocal cucharout=identfn;

    define lconstant conslowerstring(n);
    lvars n;
    fast_for i from 1 to n do
    uppertolower(subscr_stack(i)) -> subscr_stack(i);
    endfast_for;
    consstring(n);
    enddefine;
    conslist(14) -> src;
    conslowerstring(#|
    fast_for val in src do
    `-`,
    if val /== "-" then
        syspr(val);
    endif;
    endfast_for |#);
    elseif dst.islist or dst == "list" then
    conslist(14) -> src;
    [%fast_for field in FONT_FIELDS do
    nextif(field.isinteger);
    fast_destpair(src) -> src -> val;
    if val /== "*" then field, val endif;
    endfast_for;%]
    elseif dst.isvector or dst == "vector" then
    unless dst.isvector then initv(14) -> dst endunless;
    datalength(dst) -> i;
    if i fi_> 14 then
    false -> dst(i+1); ;;; should mishap
    elseif i fi_< 14 then
    erasenum(14 fi_- datalength(dst));
    endif;
    fill(dst);
    else
    mishap(dst,1,'STRING, LIST or VECTOR needed');
    endif;
    sys_grbg_list(src); ;;; free any temporary lists
enddefine;

define global rcp_postscript_font(xfont) -> (family, size);
    lvars xfont,f,x,fixedwidth, size, family, weight, slant, fixedwidth, style;
    xfont -> x;
    if (x.isstring and XptIsValidFontSpec(x)) or
    ((XptGetFontProperty(x, XA_FONT, true) ->> x)
    and XptIsValidFontSpec(x sys_>< '' ->> x)) then
    ;;; We can use the XLFD
    XptConvertFontSpec(x, #_< writeable initv(14) >_#) -> f;
    ;;; (f(XLFD_RESOLUTION_Y) * f(XLFD_POINT_SIZE)) / 722.7 -> size;
    f(XLFD_PIXEL_SIZE) -> size;
    uppertolower(f(XLFD_FAMILY_NAME)) -> family;
    uppertolower(f(XLFD_WEIGHT_NAME)) -> weight;
    if (uppertolower(f(XLFD_SETWIDTH_NAME)) ->> x) /== "normal" and
    x /== "-" then
    consword(#| family.explode, `+`, x.explode |#) -> family;
    endif;
    if (uppertolower(f(XLFD_ADD_STYLE_NAME)) ->> x) /== "normal" and
    x /== "-" then
    consword(#| family.explode, `+`, x.explode |#) -> family;
    endif;
    uppertolower(f(XLFD_SLANT)) -> slant;
    rcp_postscript_font_map(family)  -> family;
    ;;; slant true if italic, weight true if bold
    weight == "demi" or weight == "bold" or weight == "demibold" -> weight;
    not(slant == "r") -> slant;
    if family and rcp_postscript_style_map(family) ->> family then
    if slant and weight then 4
    elseif weight then 3
    elseif slant then 2
    else 1
    endif -> style;
    family(style) -> family;
    return;
    endif;
    endif;

    if xfont.isstring then
    rcp_postscript_font_map("default") -> family;
    10 -> size;
    else
    ;;; didn't find a valid font XLFD - need to make a best guess
    ;;; this is very simple: if its fixed width, use Courier, otherwise
    ;;; use the "default" font.

    l_typespec xfont :XFontStruct;

    exacc (exacc xfont.min_bounds).width ==
    exacc (exacc xfont.max_bounds).width -> fixedwidth;

    exacc xfont.ascent + exacc xfont.descent -> size;

    if fixedwidth then
    'Courier'
    else
    rcp_postscript_font_map("default") sys_>< ''
    endif -> family;
    endif;
enddefine;


;;; RC_POSTSCRIPT - main code

define lconstant macro LSTR;
    dlocal pop_longstrings = true;
    readitem();
enddefine;

vars
    ;;; forward declarations
    rc_window,
    rc_window_xsize = 500,
    rc_window_ysize = 500,
    active rc_linewidth,
    active rc_linestyle,
;

vars
    rcp_output_stream = false,

    ;;; whether to use Encapsulated Postscript
    rcp_use_eps = false,

    ;;; size of lines of rc_linewidth 0
    rcp_thin_line_size = 0.1,

    ;;; [WIDTH HEIGHT LEFT_OFFSET BOTTOM_OFFSET] (measured in inches)
    rcp_picture_scale = [8 10 0.5 0.5],
;

lvars
    last_linewidth, last_linestyle, last_font, fonts,
;

define lconstant defn_ellipse;
    npr(LSTR '/ellipsedict 8 dict def
ellipsedict /mtrx matrix put
/positive_ellipse
  { ellipsedict begin
    /endangle exch def
    /startangle exch def
    /yrad exch def
    /xrad exch def
    /y exch def
    /x exch def
    /savematrix mtrx currentmatrix def
    x y translate
    xrad yrad scale
    0 0 1 startangle endangle arc
    savematrix setmatrix
    end
  } def
/negative_ellipse
  { ellipsedict begin
    /endangle exch def
    /startangle exch def
    /yrad exch def
    /xrad exch def
    /y exch def
    /x exch def
    /savematrix mtrx currentmatrix def
    x y translate
    xrad yrad scale
    0 0 1 startangle endangle arcn
    savematrix setmatrix
    end
  } def');
enddefine;

define defn_scaletext;
    npr(LSTR '/scaletextdict 8 dict def
scaletextdict /mtrx matrix put
/scale_text
  { scaletextdict begin
    /thesize exch def
    /savematrix mtrx currentmatrix def
    dup stringwidth pop thesize exch div 1 scale show
    savematrix setmatrix
    end
  } def');
enddefine;


define lconstant check_font;
    lvars f, family, size;
    lconstant ptr = writeable copy(null_external_ptr);
    if (fast_XptValue(rc_window, XtN font) ->> f) /== last_font then
    f -> last_font;
    f -> exacc ^uint ptr;
    rcp_postscript_font(ptr) -> (family, size);
    ;;; 5 -> size; ;;; XpwFontHeight(rc_window) -> size;
    printf(size, family, '\n/%P findfont %P scalefont setfont\n');
    unless member(family, fonts) then
    conspair(family, fonts) -> fonts
    endunless;
    endif;
enddefine;

define lconstant check_linewidth;
    dlocal cucharout = rcp_output_stream;
    lvars l;
    if last_linewidth /== rc_linewidth then
    if rc_linewidth == 0 then
    if rcp_thin_line_size then
    rcp_thin_line_size
    else
    1
    endif
    else
    rc_linewidth
    endif -> l;
    printf(l, '\n%P setlinewidth\n\n');
    rc_linewidth -> last_linewidth;
    endif;
enddefine;

define lconstant check_linestyle;
    dlocal cucharout = rcp_output_stream;
    lvars l;
    if last_linestyle /== rc_linestyle then
    if rc_linestyle /== LineSolid then
    npr('[3] 0 setdash\n');
    else
            npr('[] 0 setdash\n');
    endif;
    rc_linestyle -> last_linestyle;
    endif;
enddefine;

;;; POSTSCRIPT HEADER

define global rcp_preamble;
    lvars x_scale, y_scale;
    dlocal cucharout = rcp_output_stream;
    if length(rcp_postscript_font_map) == 0 then
    rcp_use_standard_fonts();
    endif;

    if rcp_use_eps then
    npr('%! output.ps');
    else
    npr('%!PS-Adobe-1.0');
    npr('%%Creator: Poplog RC-GRAPHIC Output File');
    npr('%%CreationDate: ' >< sys_convert_date(sys_real_time(),false));
    npr('%%For: ' >< sysgetusername(popusername));
    npr('%%DocumentFonts: (atend)');
    npr('%%Pages: (atend)');
    npr('%%EndComments');
    npr('\nsave\n');
    endif;

    ;;; setup the coordinate space
    printf(72.0 * rcp_picture_scale(4), 72.0 * rcp_picture_scale(3),
    '\n%P %P translate\n');

    (72.0 * rcp_picture_scale(1)) / rc_window_xsize  -> x_scale;
    (72.0 * rcp_picture_scale(2)) / rc_window_ysize  -> y_scale;
    printf(y_scale, x_scale, '%P %P scale\n');

    ;;; set state variables
    false -> last_linewidth;
    false -> last_linestyle;
    false -> last_font;
    [] -> fonts;

    pr('\n');
    defn_ellipse();
    defn_scaletext();
    pr('\n');
    check_linewidth();
    check_linestyle();

    unless rcp_use_eps then
    npr('\n%%EndProlog');
    npr('\n%%Page: 1');
    endunless;
enddefine;

;;; POSTSCRIPT FOOTER

define global rcp_endamble;
    lvars f;
    dlocal cucharout = rcp_output_stream;
    npr('\nshowpage\n');
    unless rcp_use_eps then
    npr('%%Trailer');
    npr('\nrestore\n');
    pr('%%DocumentFonts: '); for f in fonts do spr(f) endfor;
    npr('\n%%Pages: 1');
    endunless;
enddefine;

;;; POSTSCRIPT DRAWING PRIMITIVES

define global rcp_draw_point(x,y);
    lvars x,y;
    dlocal cucharout = rcp_output_stream;
    printf(rc_window_ysize - (y-0.5), x - 0.5,
'\nnewpath\n%P %P moveto \ 0 1 rlineto 1 0 rlineto 0 -1 rlineto closepath fill\n');
enddefine;

define global rcp_draw_line(x1,y1,x2,y2);
    lvars x1,y1,x2,y2;
    dlocal cucharout = rcp_output_stream;
    printf(rc_window_ysize - y2, x2, rc_window_ysize - y1, x1,
    'newpath %P %P moveto %P %P lineto stroke\n');
enddefine;

define global rcp_draw_rectangle(x1,y1,width,height);
    lvars x1,y1,width,height,x2,y2;
    dlocal cucharout = rcp_output_stream;
    printf(height, 0, 0, width, -height, 0, rc_window_ysize - y1, x1,
    'newpath %P %P moveto %P %P rlineto %P %P rlineto %P %P rlineto closepath stroke\n');
enddefine;

define global rcp_fill_rectangle(x1,y1,width,height);
    lvars x1,y1,width,height,x2,y2;
    dlocal cucharout = rcp_output_stream;
    printf(height, 0, 0, width, -height, 0, rc_window_ysize - y1, x1,
    'newpath %P %P moveto %P %P rlineto %P %P rlineto %P %P rlineto closepath fill\n');
enddefine;

define lconstant draw_arc(x,y,width,height,a1,a2, isfilled);
    lvars x,y,width,height,a1,a2, positive_direction, isfilled;

true -> isfilled;
    dlocal cucharout = rcp_output_stream;
    a1 / 64.0 -> a1; a2 / 64.0 -> a2;
    width / 2.0 -> width; height / 2.0 -> height;
    x + width -> x; y + height -> y;
    while a1 < 0 then a1 + 360 -> a1 endwhile;
    a2 > 0 -> positive_direction;
    a1 + a2 -> a2; while a2 < 0 then a2 + 360 -> a2 endwhile;

    if positive_direction then
    printf(a2, a1, height, width, rc_window_ysize - y, x,
    'newpath %P %P %P %P %P %P positive_ellipse ');
    else
    printf(a2, a1, height, width, rc_window_ysize - y, x,
    'newpath %P %P %P %P %P %P negative_ellipse ');
    endif;
;;;    if isfilled then pr('fill\n'); else pr('stroke\n'); endif;
pr('fill\n');
enddefine;

define global rcp_draw_arc = draw_arc(%false%); enddefine;
define global rcp_fill_arc = draw_arc(%true%); enddefine;


;;; POSTSCRIPT TEXT OUTPUT (primitive at the moment)

define global rcp_draw_string(x, y, string);
    lvars x, y, string, width;
    dlocal cucharout = rcp_output_stream;

    ;;; need to check if the X font has changed
    check_font();

    ;;; we draw the string using a postscript font, making sure that
    ;;; it fits into the same bounding box
    XpwTextWidth(rc_window, string) -> width;
    printf(width, string, rc_window_ysize - y, x,
    '%P %P moveto (%P) %P scale_text\n');
enddefine;


;;; INTERFACE TO Xpw and RC_GRAPHIC (very hacky at the moment)


#_IF not(DEF o_XpwDrawPoint)
constant
    o_XpwDrawPoint = XpwDrawPoint,
    o_XpwDrawLine = XpwDrawLine,
    o_XpwDrawString = XpwDrawString,
    o_XpwDrawRectangle = XpwDrawRectangle,
    o_XpwDrawArc = XpwDrawArc,
    o_XpwClearWindow = XpwClearWindow,
    o_XptDestroyWindow = XptDestroyWindow,
    o_XptNewWindow = XptNewWindow,
    ;

applist([
    XpwDrawPoint
    XpwDrawLine
    XpwDrawString
    XpwDrawRectangle
    XpwDrawArc
    XpwClearWindow
    XptDestroyWindow
    XptNewWindow
    ], syscancel);

vars
    XpwDrawPoint
    XpwDrawLine
    XpwDrawString
    XpwDrawRectangle
    XpwDrawArc
    XpwClearWindow
    XptDestroyWindow
    XptNewWindow
;
#_ENDIF

lib rc_graphic;

vars
    o_rc_linewidth = updater(nonactive rc_linewidth),
    o_rc_linestyle = updater(nonactive rc_linestyle),
;

compile_mode :vm -prmprt;


;;; POSTSCRIPT <-> X SWITCHING MECHANISM

lvars enabled = false;

define active rcp_enabled;
    enabled;
enddefine;

define updaterof active rcp_enabled(v);
    lvars v;
    v and true ->   enabled;
    if v then
    rcp_draw_point <> erase -> XpwDrawPoint,
    rcp_draw_line <> erase -> XpwDrawLine,
    rcp_draw_string <> erase -> XpwDrawString,
    rcp_draw_rectangle <> erase -> XpwDrawRectangle,
    rcp_draw_arc <> erase -> XpwDrawArc,

    erase -> XpwClearWindow,
    erase -> XptDestroyWindow,
    erasenum(%3%) -> XptNewWindow,
    updater(nonactive_idval(ident rc_linewidth)) <> check_linewidth
    -> updater(nonactive_idval(ident rc_linewidth));
    updater(nonactive_idval(ident rc_linestyle)) <> check_linestyle
    -> updater(nonactive_idval(ident rc_linestyle));
    else
    o_XpwDrawPoint -> XpwDrawPoint,
    o_XpwDrawLine -> XpwDrawLine,
    o_XpwDrawString -> XpwDrawString,
    o_XpwDrawRectangle -> XpwDrawRectangle,
    o_XpwDrawArc -> XpwDrawArc,

    o_XpwClearWindow -> XpwClearWindow,
    o_XptDestroyWindow -> XptDestroyWindow,
    o_XptNewWindow -> XptNewWindow,
    o_rc_linewidth -> updater(nonactive_idval(ident rc_linewidth));
    o_rc_linestyle -> updater(nonactive_idval(ident rc_linestyle));
    endif;
enddefine;

;;; HIGH LEVEL INTERFACE PROCEDURE

define global rc_postscript(fname, code);
    lvars fname, code, iseps = false, margins = [8 10.5 0.5 1];

    if code.isboolean then
    (fname, code) -> (fname, code, iseps);
    endif;

    if code.islist then
    (fname, code, iseps) -> (fname, code, margins, iseps);
    endif;

    if length(margins) = 2 then
    [%  explode(margins),
    if iseps then
    0,0
    else
    max(0, (8-margins(1))/2), max(0, (10.5-margins(2))/2),
    endif;
    %] -> margins;
    endif;

    dlocal  rcp_output_stream,
    rcp_enabled = true,
    rcp_use_eps = iseps,
    rcp_picture_scale = margins;

    if fname then
    (fname.isprocedure and fname or discout(fname)) -> rcp_output_stream;
    else
    cucharout -> rcp_output_stream;
    endif;

    rcp_preamble(); code(); rcp_endamble();

    if fname then rcp_output_stream(termin); endif;
enddefine;

define rc_postscript_inline(string);
    if rcp_output_stream then
    dlocal cucharout = rcp_output_stream;
    pr(string);
    endif;
enddefine;

false -> rcp_enabled;
