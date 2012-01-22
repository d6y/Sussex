uses rcg;
uses rc_arrow;

define fsmdl(commands);
    vars
        nodes = [],
        x_base = -100, y_base = 0,
        x_step = 25, y_step = 20,
        radius = 8
        ;
    rc_start();
    fsmdl_run(commands);
enddefine;

define nodelink(data);
    vars node1, node2, x1, x2, y1, y2, label=false,
        point1 = "front", point2 = "back", arc = false;

    if hd(data) = "arc" then
        true -> arc;
        tl(data) -> data;
    endif;


    unless data matches [?node1 ?node2] then
        unless data matches [?node1 ?node2 ?label] then
            mishap('NODELINK: Parameter format wrong',data);
        endunless;
    endunless;

    if islist(node1) then
        node1(1) -> point1;
        node1(2) -> node1;
    endif;

    if islist(node2) then
        node2(1) -> point2;
        node2(2) -> node2;
    endif;


    nodes --> [== [?x1 ?y1 ^node1] ==];
    nodes --> [== [?x2 ?y2 ^node2] ==];

    coords(x1,y1,point1)->(x1,y1);
    coords(x2,y2,point2)->(x2,y2);

    if arc = false then
        if label = false then
            rc_arrow_line(x1,y1,x2,y2,0.5);
        else
            rc_arrow_line(x1,y1,x2,y2,0.5,label);
        endif;
    else

        rc_add_arrow(x1+((x2-x1)/1.15),y1+radius*2,x2,y2,0.5,label);
        y1 + radius*2 -> y1;
        y2 + radius*2 -> y2;

    if x1 > x2 then (x1, x2) -> (x2, x1); endif;

        rc_draw_arc(x1,3+y1,x2-x1,y_step+y2-y1,0,64*180);

    endif;

enddefine;

define coords(x,y) -> (x,y);
vars place = "bottom";
    if isword(y) then
        (x,y) -> (x,y,place);
    endif;

    x_base + x*x_step -> x;
    y_base + y*y_step -> y;


    switchon place

    case = "front" then
        x+radius -> x;
        y+radius -> y;

    case = "back" then
        x-radius -> x;
        y+radius -> y;

    case = "middle" then
        x+radius -> x;

    case = "top" then
        y+radius*2 -> y;

    endswitchon;

enddefine;




define newnode(data);
    vars x,y,label;
    unless data matches [?x ?y ?label] then
        gensym("node") -> label;
        unless data matches [?x ?y] then
            mishap('NEWNODE: Parameter format wrong',data);
        endunless;
    endunless;
    [^x ^y ^label] :: nodes -> nodes;
    coords(x,y) -> (x,y);
    rc_jumpto(x,y);
    rc_arc_around(radius,360);
    rc_jumpby(-radius/2,radius/3);
    rc_print_here(''><label);
enddefine;


define fsmdl_run(commands);
    vars line;
    for line in commands do
        switchon hd(line)

        case = "newnode" then
            newnode(tl(line));

        case = "link" then
            nodelink(tl(line));

        case = "scale" then
            x_step * line(2) -> x_step;
            y_step * line(2) -> y_step;

        endswitchon;
    endfor;
enddefine;

fsmdl([
[scale 2]
[newnode 0 0 a]
[newnode 1 0 b]
[link [front a]  [back b] ]
[newnode 2 2 c]
[link b [bottom c]]
[link [back c] [top a]]
[newnode 2 0 d]
[link arc [top d] [top a]]
[link arc [top a] [top d]]
[link d [bottom c]]
]);
