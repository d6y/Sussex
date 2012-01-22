uses propsheet;
propsheet_init();

lvars sul_box, categories, active_sheet=false;

lvars font_list = [
'Times New Roman'
'Times New Roman (no MathTime)'
'Avant Garde Book'
'Bookman Light'
'New Century Schoolbook'
'Palatino'
'Charter'
'Computer Modern Roman'
'Helvetica'
'Gill-Sans'
'Computer Modern Sans'
'Rockwell'
'Courier'
'Computer Modern Typewriter'];

lvars font_size = [
normalsize
large
Large
LARGE
huge
Huge
small
footnotesize
scriptsize
tiny];

define main_buttons(propbox, button) -> accept;
    false -> accept;
    if button = "Quit" then
        propsheet_destroy(sul_box);
    elseif button = "Save" then
        ;;; Save
    elseif button = "Load" then
        ;;; Load
    elseif button = "View" then
        ;;; View
    endif;
enddefine;

define whole_document(sheet, field, value) -> value;

propsheet_new('Document layout', sul_box, [

    [Font   menuof  ^font_list]
    + [Size menuof  ^size_list]
    + ['Auto scale' true]

    [Bold false]
    + [Italic false]
    + ['Small caps' false]
    + [Underlined false]
    + [Slanted false]

    ['Text width'   12]
    ['Text height'  14]

    [OK command (nolabel)]

    ]) -> active_sheet;


propsheet_show(active_sheet);

enddefine;



define sul_start;

propsheet_new_box('Style-U-Like',false, main_buttons,
        [View Save Load Quit]) -> sul_box;

propsheet_new('Categories', sul_box, [
    [Messages       message 'Welcome to Style-U-Like!' ]

    ['Whole document'   command     (nolabel,accepter=whole_document) ]
    + ['Title page' command (nolabel) ]
    + [Sections      command     (nolabel) ]

    ]) -> categories;


propsheet_show([% categories, sul_box %]);

enddefine;

sul_start();
