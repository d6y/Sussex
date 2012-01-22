/********************************************************
 *
 * prod.c
 *
 * Richard Dallaway <richardd@logcam.co.uk>
 * Last change: 3 November 1993
 *
 * Compile with: gcc -o prod prod.c
 *
 * Usage: prod <first multiplier> <num errors> <mode> <seed>
 *
 * Routines for evaluating the distribution of errors
 * produced by various kinds of error simulations.
 * (For models of memory for multiplication errors)
 *
 * First multiplier: An integer, zero to 8.
 * Num errors: An integer, the number of errors to collect per
 *	problem.
 * Seed: An intger, to seed the random number generator.
 * Modes: (methods for generating errors)
 *
 * randomproduct - for each problem, N random products
 * are randomly selected as the N recorded answers.
 *
 * sideproducts - for each problem, the errors are those
 * products "either side" of the correct product for the
 * problem.  E.g., for 3x6=18, the errors either side of
 * 18 are 16 and 20 (in the ordered list of products).
 * The <num errors> variable determines how far each
 * side. A total of <num errors> will be generated, and this
 * includes the correct answer (!). E.g., with <num_errors>
 * equal to "5", the following products would be collected
 * for 3x6=18: 15, 16, 18, 20, 21 (i.e., 5 products: 2 
 * either side plus the correct product). Of course, the
 * correct product doers not count towards the errors.
 * The <num_errors> variable MUST be an odd number.
 * 
 ********************************************************/

#include <stdio.h>

/*---------------------- CONSTANTS -------------------------------*/

/* All experiments will be upto the 9 times table */
#define LAST_MULTIPLIER 	9

/* Allocation constants */
#define MAX_NUM_MULTIPLIERS	10
#define LONGEST_STRING 		100
#define MAX_NUM_PRODUCTS	100

/* Maximum number of errors per problem to be considered */
#define MAX_NUM_ERRORS		10

typedef unsigned int Boolean;

#define true	((Boolean)1)
#define false 	((Boolean)0)

#define DEBUG false

enum MODES { RANDOM_PRODUCT, SIDE_PRODUCTS };

/*----------------------- GLOBAL VARIABLES -----------------------*/

/* Product contains an ordered list of the "valid" products. 
 * Product[0] will be the smallest product, usually 0 to 4.
 * Product[num_products-1] will be the largest product */

int	Product[MAX_NUM_PRODUCTS];

/* Error[x][y][NUM_ERRORS] is an array of the errors recorded for
 * the problem x*y.  E.g., Error[6][7][0] might be 45, indicating
 * that the first error for 6*7 was 45.  */

int	Error[MAX_NUM_MULTIPLIERS][MAX_NUM_MULTIPLIERS][MAX_NUM_ERRORS];

/* Index into the Product[] array, such that ProductIndex[x][y] 
 * returns the index into the Product[] for the problem x*y. 
 * The ProductIndex[] makes it easy to find out which product
 * is "next" after a partiular problems correct product. I.e.,
 * 1. Lookup the product index for a problem
 * 2. Add one to the index.
 * 3. Lookup the product with Product[index]
 */

int	ProductIndex[MAX_NUM_MULTIPLIERS][MAX_NUM_MULTIPLIERS];

/*------------------- SUPPORT PROCEDURES -------------------------*/

#define MIN(x,y)	( (x) < (y) ? (x) : (y) )
#define MAX(x,y)	( (x) > (y) ? (x) : (y) )

/* Random integer between zero and x-1 */
#define RANDOM(x)	((int)(random() % x))

/* Fill the Product[] array with products (and sort them into order).
 * Returns the number of products stored. */

int generate_products(int first_multiplier)
{
int	x, y, product, temp_product, i, num_products;
Boolean	found;

num_products = 0;

for(x=first_multiplier; x<=LAST_MULTIPLIER; x++)
  for(y=first_multiplier; y<=LAST_MULTIPLIER; y++) {
      product = x*y;
      found = false;
      for(i=0; i<num_products; i++) 
	  if (Product[i]==product) {
	      found=true;
	      break;
	  }
      if (found==false)
	  Product[num_products++] = product;
} 

/* Sort the products into assending order */

for(x=0; x<num_products-1; x++)
  for(y=x+1; y<num_products; y++)
    if (Product[x] > Product[y]) {
	temp_product = Product[x];
	Product[x] = Product[y];
	Product[y] = temp_product;
    }

/* Build the ProductIndex */

for(x=first_multiplier; x<=LAST_MULTIPLIER; x++)
  for(y=first_multiplier; y<=LAST_MULTIPLIER; y++) {
      product = x*y;
      for(i=0; i<num_products; i++)
	if (Product[i] == product) {
	    ProductIndex[x][y] = i;
	    product = -1;
	    break;
	}
      if (product != -1) { /* safe guard..to esnure we do find every product */
	  fprintf(stderr,"STRANGE ERROR: Product (%dx%d) not found in Product[]\n", x,y);
	  exit(-1);
      }
  }
      


return num_products;
}


/* The guts of detecting operand errors: returns "true" if the
 * "test_product" lies within +/- "range" of the correct answer.
 * NB: This procedure assumes that correct answers have been
 * removed already, so that this procedure is only called with
 * incorrect answers. Otherwise, a correct answer would be
 * flagged as an operand error by this code.
 */

Boolean is_in_cross(int test_product, int x, int y, int range, 
		    int first_multiplier)
{
int	z;

for(z=MAX(first_multiplier,x-range); z<=MIN(LAST_MULTIPLIER,x+range); z++)
  if (z*y==test_product)
    return true;

for(z=MAX(first_multiplier,y-range); z<=MIN(LAST_MULTIPLIER,y+range); z++)
  if (x*z==test_product)
    return true;

return false;
}


/* Returns true if the "test_product" is an operand error in the context of
 * the problem x*y. */

Boolean is_operand_error(int test_product, int x, int y, int first_multiplier)
{
return is_in_cross(test_product, x, y, MAX_NUM_MULTIPLIERS, first_multiplier);
}


/* Returns true if the "test_product" is a CLOSE operand error (within +/- 2
 * operands) in the context of the problem x*y. */

Boolean is_close_operand_error(int test_product, int x, int y, 
			       int first_multiplier)
{
return is_in_cross(test_product, x, y, 2, first_multiplier);
}


/* Returns true if the test_product is a product recorded in the
 * Product[] array. */

Boolean is_table_error(int test_product, int num_products)
{
int	i;

for (i=0; i<num_products; i++)
  if (Product[i] == test_product) 
    return true;

return false;
}

/* Returns true if the test_product is one of the "frequent
 * products */

Boolean is_frequent(int test_product)
{

if (test_product == 12 ||
    test_product == 16 ||
    test_product == 18 ||
    test_product == 24 ||
    test_product == 36)
  return true;
else
  return false;
}


main (int argc, char **argv)
{
int	first_multiplier;
int	seed;
int	mode;
int	num_products, num_errors;
int	x,y,i,n;
int	error, index, correct, error_index;
int	num_operand_errors, num_close_operand_errors, total_num_errors;
int	num_correct, num_table_errors, num_frequent_errors;
int	num_operation_errors;

/* Parse command line arguments */

if (argc < 5) {
    fprintf(stderr,"Usage: %s <first multiplier> <num errors> <mode> <seed>\n", argv[0]);
    fprintf(stderr,"Modes: randomproduct, sideproducts\n");
    exit(-1);
}

first_multiplier = atoi(argv[1]);

if (first_multiplier < 0 || first_multiplier > 9) {
    fprintf(stderr,"%s: First multiplier must be between 0 and 8\n", argv[0]);
    exit(-1);
}

num_errors = atoi(argv[2]);
if (num_errors < 1) {
    fprintf(stderr,"%s: You must want to record at least one error\n", argv[0]);
    exit(-1);
}
if (num_errors > MAX_NUM_ERRORS) {
    fprintf(stderr,"%s: The maximum number of errors is %d\n", argv[0], MAX_NUM_ERRORS);
    exit(-1);
}

/* Set the random seed */
seed = atoi(argv[4]);
srandom(seed);

if (strcmp(argv[3], "randomproduct")==0)
  mode = RANDOM_PRODUCT;
else if (strcmp(argv[3],"sideproducts")==0) /* must be an odd number */
  mode = SIDE_PRODUCTS;
else {
    fprintf("%s: Unknown mode \"%s\"\n", argv[0], argv[3]);
    exit(1);
}

/* Generate all the products */

num_products = generate_products(first_multiplier);

if (DEBUG) {
    /* Print the products out -- for reassurance */
    for (x=0; x<num_products; x++)
      printf("%4d %4d\n", x, Product[x]);
}

/* Simulate errors */

if (mode==RANDOM_PRODUCT) 
  for (x=first_multiplier; x<=LAST_MULTIPLIER; x++)
    for(y=first_multiplier; y<=LAST_MULTIPLIER; y++)
      for(n=0; n<num_errors; n++)
	Error[x][y][n] = Product[RANDOM(num_products)];
else
  if (mode==SIDE_PRODUCTS)
    for (x=first_multiplier; x<=LAST_MULTIPLIER; x++)
      for(y=first_multiplier; y<=LAST_MULTIPLIER; y++) {
	  index = (ProductIndex[x][y]) - ((num_errors-1)/2);
	  correct = x*y;
	  for (n=0; n<num_errors; n++) {
	      error_index = index+n; 
	      if (error_index < 0 || error_index > num_products) 
		Error[x][y][n] = correct; /* If we run out of errors, use the correct answer */
	      else {
		Error[x][y][n] = Product[error_index];
	    }
	  }
      }


/* Categorize errors */

num_operand_errors = 0;
num_close_operand_errors = 0;
num_correct = 0;
total_num_errors = 0;
num_table_errors = 0;
num_frequent_errors = 0;
num_operation_errors = 0;

for (x=first_multiplier; x<=LAST_MULTIPLIER; x++)
  for(y=first_multiplier; y<=LAST_MULTIPLIER; y++)
    for(n=0; n<num_errors; n++) {

	error = Error[x][y][n];

	if (error==x*y) /* Correct answer */
	  num_correct++; 
	else { /* Incorrect answer */

	    total_num_errors++;

	    /* Operand errors */

	    if (is_close_operand_error(error,x,y,first_multiplier)==true) {
		num_close_operand_errors++;
		/* A close-operand error is an operand error */
		num_operand_errors++;
	    } else 	
	      if (is_operand_error(error,x,y,first_multiplier)==true) 
		num_operand_errors++;
	      else {
		  /* If it's not an operand error, maybe it's a table error */
		  if (is_table_error(error, num_products)==true)
		    num_table_errors++;
	      }
	   
	    /* Frequent product error */
	    if (is_frequent(error)==true)
	      num_frequent_errors++;

	    /* Operation errors */
	    if (error==x+y)
	      num_operation_errors++;


      }/*end of "else incorrect answer"*/		
    } /*endfor*/


/* Print out error summary */

printf("Mode: %s, Seed: %d\n", argv[3], seed);
printf("%d errors recorded per problem\n", num_errors);
printf("For problems %dx%d to %dx%d\n", first_multiplier, first_multiplier,
       LAST_MULTIPLIER, LAST_MULTIPLIER);

printf("\nTotal of %d errors (%d correct)\n", total_num_errors, num_correct);

if (total_num_errors==0) 
  exit(1);

printf("\tOperand errors:       %3.2f%% (%4d)\n", 
       100.0*((float)num_operand_errors/(float)total_num_errors),
       num_operand_errors);

printf("\tClose operand errors: %3.2f%% (%4d)\n",
       100.0*((float)num_close_operand_errors/(float)total_num_errors), 
       num_close_operand_errors);

printf("\tTable errors:         %3.2f%% (%4d)\n",
       100.0*((float)num_table_errors/(float)total_num_errors),
       num_table_errors);

printf("\tFrequent products:    %3.2f%% (%4d)\n",
       100.0*((float)num_frequent_errors/(float)total_num_errors),
       num_frequent_errors);

printf("\tOperation errors:     %3.2f%% (%4d)\n",
       100.0*((float)num_operation_errors/(float)total_num_errors),
       num_operation_errors);

}

