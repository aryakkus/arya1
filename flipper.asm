#name:Rozerin Akkus
#studentID:260775633

.data
#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "flipped.pgm"	#used as output
axis: .word 1 # 0=flip around x-axis....1=flip around y-axis
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048


#any extra data you specify MUST be after this line 
bufferspace: .space 2048
write_input: .asciiz "P2 \n 24 7 \n 15  \n" 

	.text
	.globl main

main:
    la $a0,input	#readfile takes $a0 as input
    jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
	la $a2,axis        #either 0 or 1, specifying x or y axis flip accordingly
	jal flip


	la $a0, output		#writefile will take $a0 as file location we wish to write to.
	la $a1,newbuff		#$a1 takes location of what data we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall
	


readfile:
	li   $v0, 13       # opening the file(13)
	li   $a1, 0        
	li   $a2, 0        
	syscall		   
	move $s0, $v0	   # copying the file descriptor

	li $v0, 14	   # reading the file
	move $a0, $s0	   # copying file descriptor to $a0
	la $a1, buffer	   # $a1 is address of buffer
	li $a2, 2048	  
	syscall		   

	li   $v0, 16       # closing the file
	move $a0, $s0      # file descriptor
	syscall		   

	jr $ra
#done in Q1

	la $s2, bufferspace 	# loading bufferspace
	la $s3, buffer 		# pointer for the array 
	
outerloop:
	lb $s4, 0($s2)	  	
	li $t2, 0 		# setting counter for 0

condition:
	beq $s4, $zero, stopmode # if char == 0, sleep mode
	slti $t0, $s4, 48
	bne $t0, $zero, integer 	#
	slti $t0, $s2, 58 # char < 58
	beq $t0, $zero, integer # if false (char >= 58), not an ascii number, check if padding is needed
	
	addi $t2 ,$t2, 1 # increment counter
	sb $s4, 0($s3) # store the number into formatted buffer
	addi $s2, $s2, 1 # advance the pointers
	addi $s3,$s3, 1 
	lb $s4, 0($s2) # load new character 
	j condition
integer:
	bne $t2, $zero, space # use padding to create space
	addi $s2,$s2, 1 # else increse pointer
	j outerloop
space:
	subi $t2, $t2, 4
	sub $t2, $zero, $t2 # t2 is now the number of spaces we need to pad to fill a word
spaceLoop:
	li $t1, 32 # load space character
	sb $t1, 0($s1) # store space char. in buffer as padding
	subi $t2, $t2, 1 # decrease count
	addi $s3, $s3, 1 # move printer pointer
	bne $t2, $zero, spaceLoop # repeat until we need no more padding
	add $s2,$s2,1 # 
	j outerloop
stopmode:
	li $t1, 32
	jr $ra
	
	
flip:
	#Can assume 24 by 7 again for the input.txt file
	#Try to understand the math before coding!
	lw $t0, 0($a2) # load axis value
	bne $t0, $zero, flip_y # if axis == 0, goto flipX; otherwise, continue to flipY
flip_x: 
	li $s5, 0 # col = 0
	li $s6, 24 # const width = 24 (for mul op.)
resetRows:
	li $s2, 0 # row_s = 0
	li $s3, 24 # row_d = 24

flip_x_loop:
	
	# compute source word address
	mul $t0, $s0, $s6 # row_s * 24
	add $t0, $t0, $s5 # + col
	add $t0, $t0, $a0 # + base address
	
	
	# compute destination word address
	mul $t1, $s1, $s6 # row_d * 24
	add $t1, $t1, $s5 # + col
	add $t1, $t1, $a1 # + base address
	
	
	lw $t2, 0($t0) # copy from source
	sw $t2, 0($t1) # to destination
	addi $s2, $s2, 4 # move forward row pointer by a word (4 bytes)
	subi $s3, $s3, 4 # move back
	slt $t2, $s3, $zero
	beq $t2, $zero, flip_x_loop # if row_d < 0, reached the end of a col and continue; otherwise, loop again
	addi $s5, $s5, 4 # increment col by 4 bytes
	slti $t2, $s5, 93 # 93 = 23 (width) * 4 (bytes) + 1
	beq $t2, $zero, exit # if col is outside of width, exit
	j resetRows # otherwise, reset the columns 

flip_y: 
	li $s5, 0 # row = 0
	li $s6, 24 # const width = 24 (for mul op.)
resetCols:
	li $s2, 0 # col_s = 0
	li $s3, 92 # col_d = 92 = 23 * 4
flip_y_loop:
	# compute source word address
	mul $t0, $s5, $s6 # row * 24
	add $t0, $t0, $s2 # + col
	add $t0, $t0, $a0 # + base address
	
	# compute destination word address
	mul $t1, $s5, $s6 # row * 24
	add $t1, $t1, $s3 # + col
	add $t1, $t1, $a1 # + base address
	
	lw $t2, 0($t0) # copy from source
	sw $t2, 0($t1) # to destination
	addi $s2, $s2, 4 # move forward column pointer by a word
	subi $s3, $s3, 4 # move back col
	slt $t2, $s3, $zero
	beq $t2, $zero, flip_y_loop # if col_d < 0, reached the end of a row so continue; otherwise, loop again
	addi $s5, $s5, 4 # increment row
	slti $t2, $s5, 25 # 6 * 4 + 1
	beq $t2, $zero, exit # if row is outside of height, exit
	j resetCols # otherwise, reset the columns
 
exit:
	addi $t0, $a1, 95 # address to insert the first newline
	li $t2, 7 # number of iterations = number of rows
	li $t1, 10 # newlines ascii code
	
	jr $ra
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!

writefile:	li $v0, 13
		la $a0, output #open file to be written to, using $a0.
		li $a1, 1
		syscall
		move $s1, $v0
	
		li $v0, 15
		la $a1, write_input #write the content stored at the address in $a1.
		li $a2, 2048
		move $a0, $s1
		syscall

		li $v0, 15
		la $a1, newbuff 
		li $a2, 2048
		move $a0, $s1
		syscall
	
	
		li $v0, 16
		move $a0, $s1
		syscall
	
		jr $ra
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
