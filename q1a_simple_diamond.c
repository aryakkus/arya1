#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv){


 if(argc == 2){

int number= atoi(argv[1]);



if ( number%2==0 || number<1 ) {
	printf("ERROR:Bad argument. Height must be positive odd integer.\n");

}else{
int half=(number+1)/2;
for(int i=1; i<number+1; i++){
    if(i<half+1){
        for(int j=0; j<(number-(2*i)+1)/2; j++){
            printf(" ");
        }
        for(int k=0; k<(2*i)-1; k++){
            printf("*");
        }
        for(int l=0; l<(number-(2*i)+1)/2; l++){
            printf(" ");
        }
printf("\n");
    }
    else{
            for(int o=0; o<((2*i)-1-number)/2;o++ ){
                printf(" ");
            }
            for(int m=0; m<2*(number-i)+1; m++){
                printf("*");
            }
            for(int p=0; p<((2*i)-1-number)/2; p++){
                printf(" ");
            }
        printf("\n");
    }

}
}

}else{

	printf("ERROR:Wrong number of arguments. One required.\n");
}




}
