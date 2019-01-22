#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef enum
{
    true = 1, false = 0
} bool;


bool* makeFrac( int height,int width );
void printFrac( bool* fr,int height,int width );
void incFrac( bool* fr,int row,int column,int heightTriangle,int width );

int main( int argc,char* argv[] )
{
    int height = atoi( argv[ 1 ] );
    int lvl = atoi( argv[ 2 ] );
    int half = ( height + 1 ) / 2;
    
    if( argc != 3 )
    {
        printf( "ERROR: Wrong number of arguments. Two required.\n" );
        return 0;
    }
    
    if( !( ( height + 1 ) && !( ( height + 1 ) & ( height ) ) ) ) 
    {
        printf( "ERROR: Height does not allow evenly dividing requested number of levels.\n" );
        return 0;
    }
    
    if( ( int )(log( height + 1 )/log(2)) < lvl || lvl < 1 ) 
    {
        printf( "ERROR: Height does not allow evenly dividing requested number of levels.\n" );
        return 0;
    }
    
    
    bool* fractal = makeFrac( half,height );
    
    int fractalHeight = half; 
    
    for( int i = 1; i < lvl; i++ )
    {
        incFrac( fractal,0,half - 1,fractalHeight,height );
        fractalHeight /= 2; 
    }
    
    printFrac( fractal,half,height );
    
    
    free( fractal );
    fractal = NULL;
    return 0;
}

bool* makeFrac( int height,int width ) 
{
    
    bool ( *fractal )[ width ] = malloc( height * sizeof( *fractal ) ); 
    
    int stars = 1; 
    
    for( int i = 0; i < height; i++ )
    {
        int offset = 0;
        for( int j = 0; j < height - 1 - i; j++,offset++ ) fractal[ i ][ offset ] = false;  
        for( int j = 0; j < stars; j++,offset++ )          fractal[ i ][ offset ] = true;   
        for( int j = 0; j < height - 1 - i; j++,offset++ ) fractal[ i ][ offset ] = false;  
        
        stars += 2; 
    }
    return *fractal; 
}

void printFrac( bool* fr,int height,int width )
{
    for( int i = 0; i < height; i++ ) 
    {
        for( int j = 0; j < width; j++ )
        {
            
            printf( *( ( fr + i * width ) + j ) == true ? "*" : " " );
           
        }
        printf( "\n" );
    }
    
    for( int i = height - 2; i >= 0; i-- )
    {
        for( int j = 0; j < width; j++ )
        {
            printf( *( ( fr + i * width ) + j ) == true ? "*" : " " );
        }
        printf( "\n" );
    }
}

void incFrac( bool* fr,int row,int column,int heightTriangle,int width )
{
    int spaces = 1; 
    int leftIndex = column;
    
    for( int i = 0; i < heightTriangle / 2; i++ )
    {
        for( int j = 0; j < spaces; j++ )
        {
            *( ( fr + ( row + ( heightTriangle - 1 ) - i ) * width ) + ( leftIndex + j ) ) = false;
        }
        leftIndex--; 
        spaces += 2; 
    }
    
    if( row + heightTriangle - 1 != ( ( width + 1 ) / 2 ) - 1 ) 
    {
        
        incFrac( fr,row + heightTriangle,column - heightTriangle,heightTriangle,width );
        incFrac( fr,row + heightTriangle,column + heightTriangle,heightTriangle,width );
    }
}

