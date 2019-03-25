#name:
#studentID:

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "transposed.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 


	.text
	.globl main

main:	la $a0,input 		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
    jal transpose


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall
	
exit:	li $v0,10		# exit
	syscall


readfile:	li $v0, 13		#opening the file for reading
		li $a1, 0
		li $a2, 0
		syscall 
		move $s1, $v0           #copyýng file descriptor to $s1
		
		bgez $s1, read		#if s1 is not negative the file is found
		li $v0, 4		#if s1 is negative, printing error message
		la, $a0, error1
		syscall
		j exit			#go to exit
	
read:		li $v0, 14 		#reading file into buffer		
		move $a0, $s0		#copying file descriptor to $a0
		la $a1, buffer		#loading address of the buffer to $a1
		li $a2, 2048		#loading max number of characters to read
		syscall
		move $s2, $v0		#s2 is the number of characters read
		
		bgtz $s2, close_continue	#if s2 is greater than zero, dont print error and continue to writing the file
		li $v0, 4			#if s2 is zero or less, print error message
		la, $a0, error2
		syscall
		
		li $v0, 16		#close the file 
		move $a0, $s0
		syscall
		j exit			#go to to exit
		

		
close_continue:	li $v0, 16		#closing the file
		move $a0, $s0
		syscall
		
		jr $ra
#done in Q1


transpose:
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!

writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
