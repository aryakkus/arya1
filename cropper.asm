#name:
#studentID:

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 1
x2: .word 2
y1: .word 3
y2: .word 4
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line 

location: .asciiz ""
hashtag: .asciiz "#"

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
	jal crop

	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:


	li   $v0, 13       # system call for open file
	li   $a1, 0        # open for reading (flags are 0: read, 1: write)
	li   $a2, 0        # mode is ignored
	syscall		   # open the file
	move $s0, $v0	   # save the file descriptor

	li $v0, 14	   # system call for read from file
	move $a0, $s0	   # file descriptor
	la $a1, buffer	   # address of buffer to which to read
	li $a2, 2048	   # hardcoded buffer length
	syscall		   # read from file

	li   $v0, 16       # system call for close file
	move $a0, $s0      # file descriptor to close
	syscall		   # close file

	jr $ra

#done in Q1


crop:

	la $t4, buffer
	la $t5, newbuff
	
	addi $t7, $0, 71	# character count in each line

	lw $t0, y1
	lw $t1, y2
	
	yLoop:	bgt $t0, $t1, endyLoop
		
		lw $t2, x1
		lw $t3, x2
		
		xLoop:	bgt $t2, $t3, endxLoop
			
			
			mul $t6, $t0, $t7
			
			addi $t9, $0, 3
			mul $t9, $t9, $t2
			
			add $t6, $t6, $t9
			add $t6, $t6, $t4
			
			lb $t8, ($t6)
			sb $t8, ($t5)
			
			beq $t2, $t3, skip1
			
			lb $t8, 1($t6)
			sb $t8, 1($t5)
			
			lb $t8, 2($t6)
			sb $t8, 2($t5)
			
			skip1:
			
			#li $v0, 4
			#la $a0, hashtag
			#syscall
			
			#la $a0, location
			#sb $t8, ($a0)
			
			#li $v0, 4
			#syscall
			
			addi $t5, $t5, 3
			
			addi $t2, $t2, 1
			
			j xLoop
			
		endxLoop:
		
		addi $t8, $0, 10
		sb $t8, ($t5)
		
		addi $t5, $t5, 1
		
		addi $t0, $t0, 1
		
		j yLoop
	
	endyLoop:
	
	jr $ra

#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#Try to understand the math before coding!
#There are more than 4 arguments, so use the stack accordingly.

writefile:

	la $t3, headerbuff
	
	addi $t0, $0, 80   # Ascii value for P is 80
	sb $t0, 0($t3)	   # Add P to headerbuff
	addi $t0, $0, 50   # Ascii value for 2 is 50
	sb $t0, 1($t3)	   # Add 2 to headerbuff
	addi $t0, $0, 32   # Ascii value for space
	sb $t0, 2($t3)	   # Add space
	addi $t0, $0, 10   # Ascii value for \n
	sb $t0, 3($t3)	   # Add new line
	
	addi $t3, $t3, 4   # We added 4 characters
	
	la $t0, x1	   # pointer to x1
	lb $t1, ($t0)	   # load the word x1
	
	la $t0, x2	   # pointer to x2
	lb $t2, ($t0)	   # load the word x2
	
	sub $t2, $t2, $t1  # the width is x2 - x1
	addi $t2, $t2, 1
	
	bgt $t2, 9, twodigitwidth
	
	addi $t2, $t2, 48 
	
	sb $t2, 0($t3)	   # Add the width
	addi $t3, $t3, 1   # Add 1 byte
	
	j widthdone
	
	twodigitwidth: 
	
		addi $t6, $0, 10
		div $t2, $t6
		mflo $t4
		mfhi $t5
		
		addi $t4, $t4, 48
		addi $t5, $t5, 48
		
		sb $t4, 0($t3)
		addi $t3, $t3, 1
		
		sb $t5, 0($t3)
		addi $t3, $t3, 1
		
	
	widthdone:
	
	addi $t0, $0, 32
	sb $t0, 0($t3)	   # Add space
	addi $t3, $t3, 1
	
	la $t0, y1	   # pointer to y1
	lb $t1, ($t0)	   # load the word y1
	
	la $t0, y2	   # pointer to y2
	lb $t2, ($t0)	   # load the word y2
	
	sub $t2, $t2, $t1  # the length is y2 - y1
	addi $t2, $t2, 1
	
	bgt $t2, 9, twodigitlength
	
	addi $t2, $t2, 48 
	
	sb $t2, 0($t3)	   # Add the width
	addi $t3, $t3, 1   # Add 1 byte
	
	j lengthdone
	
	twodigitlength: 
	
		addi $t6, $0, 10
		div $t2, $t6
		mflo $t4
		mfhi $t5
		
		addi $t4, $t4, 48
		addi $t5, $t5, 48
		
		sb $t4, 0($t3)
		addi $t3, $t3, 1
		
		sb $t5, 0($t3)
		addi $t3, $t3, 1
		
	
	lengthdone:
	
	addi $t0, $0, 32
	sb $t0, 0($t3)	   # Add space
	addi $t3, $t3, 1
	
	addi $t0, $0, 10
	sb $t0, 0($t3)	   # Add \n
	addi $t3, $t3, 1
	
	addi $t0, $0, 49
	sb $t0, 0($t3)	   # Add 1
	addi $t3, $t3, 1
	
	addi $t0, $0, 53
	sb $t0, 0($t3)	   # Add 5
	addi $t3, $t3, 1
	
	addi $t0, $0, 32
	sb $t0, 0($t3)	   # Add space
	addi $t3, $t3, 1
	
	addi $t0, $0, 32
	sb $t0, 0($t3)	   # Add space
	addi $t3, $t3, 1
	
	addi $t0, $0, 10
	sb $t0, 0($t3)	   # Add \n
	addi $t3, $t3, 1


	li   $v0, 13       # system call for open file
	la   $a0, output   # file name
	li   $a1, 1        # open for writing (flags are 0: read, 1: write)
	li   $a2, 0        # mode is ignored
	syscall		   # open the file
	move $s1, $v0	   # save the file descriptor

	li $v0, 15	   # system call for write to file
	move $a0, $s1	   # file descriptor
	la $a1, headerbuff # write text 
	li $a2, 2048	   # hardcoded buffer length
	syscall		   # write to file

	li $v0, 15
	move $a0, $s1
	la $a1, newbuff
	li $a2, 2048
	syscall

	li $v0, 16
	move $a0, $s1
	syscall
	
	jr $ra

#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
