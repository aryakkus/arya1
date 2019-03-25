//Arya AKKUS
/



* Each of the functions below can be considered a start for you. They have 
* the correct specification and are set up correctly with the header file to
* be run by the tester programs.  
*
* You should leave all of the code as is, especially making sure not to change
* any return types, function name, or argument lists, as this will break
* the automated testing. 
*
* Your code should only go within the sections surrounded by
* comments like "REPLACE EVERTHING FROM HERE... TO HERE.
*
* The assignment document and the header A3_solutions.h should help
* to find out how to complete and test the functions. Good luck!
*
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "A3_provided_functions.h"

unsigned char*
bmp_open( char* bmp_filename,        unsigned int *width, 
unsigned int *height,      unsigned int *bits_per_pixel, 
unsigned int *padding,     unsigned int *data_size, 
unsigned int *data_offset                                  )
{
unsigned char *img_data=NULL;

// REPLACE EVERYTHING FROM HERE
FILE *bmpfile = fopen(bmp_filename,"rb");


char b, m;
fread (&b,1,1,bmpfile);
fread (&m,1,1,bmpfile);


fread( data_size, 1, sizeof(unsigned int), bmpfile );
rewind(bmpfile);
img_data = (unsigned char *) malloc(*data_size);
fread(img_data, 1, *data_size, bmpfile);


memcpy(data_offset,(img_data+10),sizeof(unsigned int));
memcpy(width,(img_data+18),sizeof(unsigned int));
memcpy(height,(img_data+22),sizeof(unsigned int));
*bits_per_pixel = *(unsigned short *)(img_data + 28);


int row_size = ((*width)*(*bits_per_pixel))/8;
*padding = (4-((row_size)%4))%4;

// TO HERE!  
return img_data;  
}

void 
bmp_close( unsigned char **img_data )
{
// REPLACE EVERYTHING FROM HERE
free( *img_data );
*img_data = NULL;
// TO HERE!  
}

unsigned char***  
bmp_scale( unsigned char*** pixel_array, unsigned char* header_data, unsigned int header_size,
unsigned int* width, unsigned int* height, unsigned int num_colors,
float scale )
{
unsigned char*** new_pixel_array = NULL; 
// REPLACE EVERYTHING FROM HERE

*height = (*height)*scale;
*width = (*width)*scale;


new_pixel_array = (unsigned char***)malloc( sizeof(unsigned char**) * (*height));
for( int row=0; row<*height; row++ ){
new_pixel_array[row] = (unsigned char**)malloc( sizeof(unsigned char*) * (*width) );
for( int col=0; col<*width; col++ ){
new_pixel_array[row][col] = (unsigned char*)malloc( sizeof(unsigned char) * (num_colors) );

int scaled_row = (int)(row/scale);
int scaled_col = (int)(col/scale);
new_pixel_array[row][col] = pixel_array[scaled_row][scaled_col];
}
}

memcpy(header_data+18,width,sizeof(unsigned int));
memcpy(header_data+22,height,sizeof(unsigned int));
// TO HERE! 
return new_pixel_array;
}         

int 
bmp_collage( char* background_image_filename,     char* foreground_image_filename, 
char* output_collage_image_filename, int row_offset,                  
int col_offset,                      float scale )
{
// REPLACE EVERYTHING FROM HERE

unsigned char*   background_header_data;
unsigned int     background_header_size, background_width, background_height, background_num_colors;
unsigned char*** background = NULL;
background = bmp_to_3D_array( background_image_filename,&background_header_data,
&background_header_size,  &background_width,
&background_height,       &background_num_colors   );


unsigned char*   foreground_header_data;
unsigned int     foreground_header_size, foreground_width, foreground_height, foreground_num_colors;
unsigned char*** foreground = NULL;

foreground = bmp_to_3D_array( foreground_image_filename,&foreground_header_data,
&foreground_header_size,  &foreground_width,
&foreground_height,       &foreground_num_colors   );

foreground = bmp_scale( foreground, foreground_header_data, foreground_header_size, &foreground_width, &foreground_height, foreground_num_colors,scale);

for( int row=0; row<background_height; row++ ){
for( int col=0; col<background_width; col++ ){
if(row >= row_offset && row < (row_offset + foreground_height) && col >= col_offset && col < (col_offset + foreground_width) && foreground[row-row_offset][col-col_offset][0] != 0){
background[row][col] = foreground[row-row_offset][col-col_offset];
}
}
}

bmp_from_3D_array( output_collage_image_filename, background_header_data, background_header_size, background,
background_width,   background_height, background_num_colors);
// TO HERE! 
return 0;
}              

