#include <stdio.h>
#include <string.h>

int main (int argc, char *argv[]) {
    FILE *fptr = fopen(argv[1] , "r");

    fseek (fptr, 0, SEEK_END);
    int i = ftell(fptr);
    rewind(fptr);

    char array [i+1];
    fread(array, 1, i+1, fptr);

    int arrPos = 0;
    char *ptr = array;

    while (arrPos <= i) {
        char *ptr1 = strstr(ptr, "<a href=\"/wiki/");
        if (ptr1 == NULL) {
            break;
        }
        char *ptr2 = strstr(ptr1, "title=");
        char *ptr3 = strstr(ptr1, "</a>");

        temp = ptr3;
         if (ptr1 < ptr2 && ptr2 < ptr3) {
             ptr1 = ptr1 + 15;
             while (*ptr1 != '\"'){

                 printf ("%c" , *ptr1);
                 ptr1++;
             }
             printf("\n");

         }
            arrPos++;
             }
         }






