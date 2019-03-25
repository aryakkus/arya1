#name:Rozerin Akkus
#studentID:260775633

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test2.txt" #used as input
output:	.asciiz "copy.pgm"	#used as output
error1: .asciiz "Error: File not found"
error2: .asciiz "Error: Could not read file"
error3: .asciiz "Error: Could not write to file"
write_input: .asciiz "P2\n24 7\n15\n"

buffer:  .space 2048		# buffer for upto 2048 bytes

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile

	la $a0, output		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
	jal writefile

exit:	li $v0,10		# exit
	syscall

readfile:	li $v0, 13	#open file for reading (13 for reading)
		li $a1, 0
		li $a2, 0
		syscall 
		move $s0, $v0
		
		bgez $s0, read		#if s0 is not negative(file found), continue
		li $v0, 4		#if s0 is negative, printing error message
		la, $a0, error1
		syscall
		j exit			#going to exit
	
read:		li $v0, 14 		#read file into buffer		
		move $a0, $s0		#copying file descriptor to $a0
		la $a1, buffer		#a1 has buffer adress
		li $a2, 2048		#a2 is max number of characters to read
		syscall
		move $s2, $v0		#moving number of characters read to $s2
		
		bgtz $s2, close		#if s0 is greater than zero, continue
		li $v0, 4		#if s0 is zero or less, printing error message
		la, $a0, error2
		syscall
		
close:	        li $v0, 16		#closing the file (16 for closing) 
		move $a0, $s0		#closing the file descriptor
		syscall
		jr $ra			#going back to main
	
#Open the file to be read,using $a0
#Conduct error check, to see if file exists

# You will want to keep track of the file descriptor*

# read from file
# use correct file descriptor, and point to buffer
# hardcode maximum number of chars to read
# read from file

# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)


writefile:	li $v0, 13		#open file 
		la $a0, output		#a0 is adress of output file
		li $a1, 1		#to write
		li $a2, 0
		syscall			
		move $s3, $v0		#v0 is file descriptor 
		
		bgez $s3, write		#if s0 is positive or zero, dont print error
		li $v0, 4		#if s0 is negative, print error message
		la, $a0, error1
		syscall
		j exit			#jump to exit
		
write:		li $v0, 15		#writing to file (15 for writing)
		move $a0, $s3		#a0 is file descriptor
		la $a1, write_input	#loading the address of what we write
		li $a2, 2090		#umber of of characters to write = write_input+2048
		syscall
		move $s4, $v0
		
		bgez $s4, close_file	#if s0 is greater than zero, dont print error
		li $v0, 4		#if s0 is zero or less, print error message
		la, $a0, error3
		syscall
		
		li $v0, 16		#closing the file 
		move $a0, $s3
		syscall
		j exit			#going to exit
		
					
		
close_file:	li $v0, 16		#closing the file 
		move $a0, $s0		#closing the file descriptor
		syscall
		
		jr $ra                  #going back to function call

#open file to be written to, using $a0.
#write the specified characters as seen on assignment PDF:
#P2
#24 7
#15
#write the content stored at the address in $a1.
#close the file (make sure to check for errors)
