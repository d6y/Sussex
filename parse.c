
#include <stdio.h>

/*---------------------- CONSTANTS -------------------------------*/

int	num_operand_errors, num_close_operand_errors, total_num_errors;
int	num_correct, num_table_errors, num_frequent_errors;
int	num_operation_errors;

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

#define DEBUG true

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

void read_error(FILE *fp, int x, int y, int first_multiplier, int num_products)
{
char	c;
int	i;
int	error;
int 	num;

if (DEBUG) printf("Reading for %dx%d\n", x, y);

for(i=0; i<10; i++)
  c = fgetc(fp);

if (c != '$') printf("DOLLAR EXPECTED found %c\n", c);

c = getc(fp);

for(i=0; i<num_products; i++) {
  fscanf(fp,"%d&",&num);
printf("%d\n", num);
  if (num>0) {

      error = Product[i];
 
      total_num_errors += num;

	    if (is_close_operand_error(error,x,y,first_multiplier)==true) {
		num_close_operand_errors += num;
		/* A close-operand error is an operand error */
		num_operand_errors+=num;
	    } else 	
	      if (is_operand_error(error,x,y,first_multiplier)==true) 
		num_operand_errors+=num;
	      else {
		  /* If it's not an operand error, maybe it's a table error */
		  if (is_table_error(error, num_products)==true)
		    num_table_errors+=num;
	      }
	   
	    /* Frequent product error */
	    if (is_frequent(error)==true)
	      num_frequent_errors+=num;

	    /* Operation errors */
	    if (error==x+y)
	      num_operation_errors+=num;

  }

}
c=fgetc(fp);
}


main (int argc, char **argv)
{
int	first_multiplier;
int	seed;
int	mode;
int	num_products, num_errors;
int	x,y,i,n;
int	error, index, correct, error_index;
FILE	*fp = fopen("29_emat.tex", "r");

/* Parse command line arguments */


first_multiplier = 2;

num_errors = MAX_NUM_ERRORS;



/* Generate all the products */

num_products = generate_products(first_multiplier);

if (DEBUG) {
    /* Print the products out -- for reassurance */
    for (x=0; x<num_products; x++)
      printf("%4d %4d\n", x, Product[x]);
}

/* Simulate errors */

num_operand_errors = 0;
num_close_operand_errors = 0;
num_correct = 0;
total_num_errors = 0;
num_table_errors = 0;
num_frequent_errors = 0;
num_operation_errors = 0;

for (x=2; x < 10 ; x++)
  for (y=x; y < 10; y++) {
    read_error(fp, x,y, first_multiplier, num_products);
    if (x != y) read_error(fp, y,x, first_multiplier, num_products);
}


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

