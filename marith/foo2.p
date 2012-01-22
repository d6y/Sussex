datafile('~/marith/weights/no-skew/ns10-.meanE') -> fff;
datafile('~/marith/weights/12_prob-.E') -> E;
mean_matrix(E) -> E;
count_errors(E,false,25*170*10);

list_pec() -> pec;


ascii_performance(fff,'No-skew, mean of 10 nets 2-9',25*64) ->;


latex_matrix(fff,'No-skew, mean of 10 nets 2-9');
sysobey('latex et');

cor(pec,sv_prod);
