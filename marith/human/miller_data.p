
vars miller_adjplus = {
{ 177 197 223 203 181 150 292 260}
{ 224 242 240 204 201 244 311 489}
{ 238 215 202 148 180 206 340 285}
{ 228 222 204 164 220 196 402 353}
{ 225 182 156 182 146 258 250 355}
{ 188 165 239 210 291 156 265 370}
{ 207 291 288 318 244 311 286 420}
{ 231 288 260 272 285 315 386 307}
};

vars miller_adjx = {
{ 212 266 280 224 292 220 357 250}
{ 260 243 212 202 261 217 392 416}
{ 322 213 209 229 286 301 358 379}
{ 227 285 223 244 278 255 382 410}
{ 324 282 226 256 214 303 372 433}
{ 228 249 252 194 298 193 423 483}
{ 339 419 420 359 343 269 370 404}
{ 245 502 340 289 499 402 421 293}
};


;;; Campbell & Graham measure (excludes TIES)

vars rt = [% fast_for a from 1 to 8 do
mean([%fast_for b from 1 to 8 do
    unless a = b then
        ;;;miller_adjplus(a)(b);
        miller_adjplus(b)(a);
    endunless;
endfast_for; %]);
endfast_for %];

rc_graphplot({2 3 4 5 6 7 8 9},'',rt,'') -> region;
rt =>

rc_print_at(1.5,420,'Campbell & Graham measure of Miller et al.\'s data');
rc_print_at(1.5,415,'Mean of median RT excluding ties');
rc_print_at(1.5,410,'(for problems AxB and BxA)');

plot_zrt('c&gA85');
rc_print_at(1,2,'Campbell & Graham x mean of mean RT');
"line" -> rcg_pt_type;
newgraph();
plot_zrt('miller_adj+') =>
rc_print_at(1.5,2,'Miller et al.\'s adjusted + data (inc. ties)');

plot_zrt('aikenx.rt');
rc_print_at(1.5,2,'Aiken and Williams\' multiplication data');

plot_zrt('aiken+.rt');
rc_print_at(1.5,2,'Aiken and Williams\' addition data');

vars net = pdp3_getweights('thru8','thru8-1');
vars pats = pdp3_getpatterns('plus8',65,18,36);
cascade_rt(net,pats);
plot_zrt(net);
