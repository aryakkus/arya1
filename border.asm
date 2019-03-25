#name:Rozerin Akkus
#studentID:260775633

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded1.pgm"	#used as output

borderwidth: .word 9    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 
plain : .asciiz "P2\n"
space: .asciiz " "
newLine: .asciiz "\n"
stringEnd: .ascii "\n15\n"
intermediate: .space 2048
errorMsg: 	.asciiz "An error occurred.\n"
one:	.asciiz "1"
five:	.asciiz "5"

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile

	li $s1, 1
	la $s2, buffer		#load address of buffer for pointer
	la $s7, intermediate		#load address of where to store the numbers
	jal convert

	la $a0,intermediate		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord

	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
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
		
				
convert: 
	
	
	lbu $s0, 0($s2)		#load byte at buffer pointer
	addi $s2, $s2, 1	#increment buffer pointer by 1
	
	beq $s0, $0, finished	#if the byte that was loaded is a null char, we exit
	blt $s0, 48, convert	#if it is less than 48 
	bgt $s0, 57, convert	#or greater than 57, it is not a number and we convert next value
	addi $s0, $s0, -48	#convert ascii number to dec value
	
	li $t0, 1		#set t0 to 1
	beq $t0, $s1, oneDig	#checking if pointer is at the begining, if it is we go to fail
	
	lbu $t2, -2($s2)	#loading byte at previous value in buffer 
	blt $t2, 48, oneDig	#if previous byte is not a number,
	bgt $t2, 57, oneDig	# we go to previousNotNumber
	
	#From here on, we treat value as a 2 digit value 
	#addi $s2, $s2, 1	#if previous value is a number, we increment buffer pointer by 1
	lbu $t3, -1($s7)	#load previous byte in intermediate buffer
	li $t4, 10		#set t4 = 10
	mul $t5, $t3, $t4		#multiply previous byte by 10
	add $t5, $t5, $s0	#add new digit to this value, store in t5
	addi $s1, $s1, 1	#increment pointer counter by 1
	sb $t5, -1($s7)		#replace previous number with new 2 digit number in intermediate
	j convert
	
oneDig:
	addi $s1, $s1, 1	#increment pointer counter
	sb $s0, 0($s7)		#store one digit number in intermediate buffer directly
	addi $s7, $s7, 1	#increment intermediate buffer pointer by 1
	j convert

finished:
	jr $ra		


bord:
#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.
	
	la $a0, intermediate
	la $a1, newbuff

	la $a2, borderwidth	#borderwidth
	lw $a2, 0($a2)
	
	li $s1, 2
	mul $s2, $a2, $s1	#border * 2
	
	addi $s3, $s2, 24 	#width + (border * 2) = new width
	addi $s4, $s2, 7	#height + (border * 2) = new height  

	la $s5, space		#s5 = space
	lb $s5, 0($s5)
	
	la $s0, newLine		#s0 = newLine
	lb $s0, 0($s0)
	
	li $t5, 24
	#li $t7, 7 
	
	#loading 15
	la $s1, one
	lb $s1, 0($s1)	#don't use again
	
	la $s2, five	#don't use again 
	lb $s2, 0($s2)
	#Border1
	li $t3, 1
	li $t0, 1		#celement counter
	mul $t1, $s3, $a2	#t1 = new width * borderwidth / border1_max -->

	#border2
	li $t4, 1
	#fill row
	li $t6, 1
	#border3
	li $t7, 1	#element counter
	li $t8, 1	#row counter	
	li $t9, 7	#row max
	#border 4
	li $s6, 1
	li $s7, 1

border1:
	mul $t1, $s3, $a2	#t1 = new width * borderwidth 
	bgt $t3, $s3, inc1	#if we are past new width, load newLine
	sb $s1, 0($a1)		#loading 1  
	addi $a1, $a1, 1	#inc newbuff pointer 
	sb $s2, 0($a1)		#loading 5
	addi $a1, $a1, 1	#inc newbuff pointer 
	sb $s5, 0($a1)		#loading space
	addi $a1, $a1,1  	#incrementing newbuff pointer by 1
	
	addi $t0, $t0, 1	# incrementing element counter
	addi $t3, $t3, 1	#incrementing column counter
	j border1 

inc1:		
	sb $s0, 0($a1)		#store newLine
	addi $a1, $a1, 1	#increment newbuff pointer
	bgt $t0, $t1, border2	#if t0 elemnent (counter) > border1_max --> done
	li $t3, 1		#reset col counter
	j border1	  	#jump back to boarder 

border2:
	li, $t6, 1
	
	bgt $t4, $a2, fillRow	#if t4(counter) > border
	sb $s1, 0($a1)		#loading 1 into border
	addi $a1, $a1, 1	#incrementing newbuff pointer by 1 
	sb $s2, 0($a1)		#loading 5 into newbuff
	addi $a1, $a1, 1	#inc pointer
	sb $s5, 0($a1)		#load space
	addi $a1, $a1, 1	#inc pointer
	addi $t4, $t4, 1	#incrementing counter
	j border2

fillRow:
	li $t7, 1
	
	li $t5, 24
	bgt $t6, $t5, border3 
	lb $t0, 0($a0)
	addi $t6, $t6, 1	#increment element counter
	#convert
	li $t3, 10		# storing value 10 
	div $t0, $t3		# dividing loaded bit by 10	
	mfhi $t0		# least significant
	mflo $t3		# most significant
	addi $t0, $t0, 48	# ls + 48
	addi $t4, $t3, 48	# ms + 48
	blez $t3, oneDigitVal	# if ms is =/ less than 0, it is a one digit
	j twoDigitVal
		
oneDigitVal: 
	sb $s5, 0($a1)
	addi $a1, $a1, 1
	sb $t0, 0($a1)	#storing byte in newbuff
	addi $a1, $a1, 1
	sb $s5, 0($a1)
	addi $a1, $a1, 1
	addi $a0, $a0, 1	#increment intermediate pointer
	j fillRow
	
twoDigitVal:
	sb $t4, 0($a1)
	addi $a1, $a1, 1
	sb $t0, 0($a1)
	addi $a1, $a1, 1
	sb $s5, 0($a1)
	addi $a1, $a1, 1
	addi $a0, $a0, 1	#increment intermediate pointer
	j fillRow
		

border3:
	bgt $t7, $a2, incRow	#if t7(counter) > borderwidth
	sb $s1, 0($a1)		#loading 1 into border
	addi $a1, $a1, 1	#incrementing newbuff pointer by 1
	sb $s2, 0($a1)		#loading 5 into border
	addi $a1, $a1, 1	#increment newbuff pointer
	sb $s5, 0($a1)		#storing space
	addi $a1, $a1, 1	#increment pointer
	addi $t7, $t7, 1	#increment counter
	j border3

incRow:
	sb $s0, 0($a1)		#load new line
	addi $a1, $a1, 1	#increment newbuff pointer
	addi $t8, $t8, 1	#inc Row 
	
	li $t4, 1
	bgt $t8,$t9, border4
	j border2	
	
border4:
	mul $t1, $s3, $a2	#t1 = new width * borderwidth
	bgt $s6, $t1, done	#if t0 (counter) > border1 max
	bgt $s7, $s3, inc4
	sb $s1, 0($a1)		#loading 1 into border
	addi $a1, $a1, 1	#incrementing newbuff pointer by 1
	sb $s2, 0($a1)		#loading 5 into border
	addi $a1, $a1, 1	#inc newbuff pointer
	sb $s5, 0($a1)		#loading space
	addi $a1, $a1, 1	#inc newbuff pointer
	addi $s6, $s6, 1	# incrementing element counter
	addi $s7, $s7, 1
	j border4
	
inc4:
	sb $s0, 0($a1)
	addi $a1, $a1, 1
	li $s7, 1
	j border4
done:
	jr $ra


writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
header:
	lw $s0, borderwidth	#borderwidth
	li $s1, 2
	mul $s2, $s0, $s1	#border * 2
	addi $s3, $s2, 24 	#width + (border * 2) = new width
	addi $s4, $s2, 7	#height + (border * 2) = new height 
			
		
	la $s5, headerbuff	
	la $t1, plain
	la $t3, stringEnd 
	j Plain
			
	Plain:
		lb $t2, 0($t1)
		beq $t2, $0, width
		sb $t2, 0($s5)
		addi $t1, $t1, 1
		addi $s5, $s5, 1
		j Plain 
	width:

		li $t5, 10		# storing value 10 
		div $s3, $t5		# dividing loaded bit by 10	
		mfhi $t4		# least significant
		mflo $t5		# most significant
		addi $t4, $t4, 48	# ls + 48
		blez $t5, oneDigWidth	# if ms is =/ less than 0, it is a one digit
		addi $t5, $t5, 48	# ms + 48
		sb $t5, 0($s5)		# store ms in newbuff
		addi $s5, $s5, 1	# move newbuff pointer by 1
		
	oneDigWidth: 
		sb $t4, 0($s5)	#storing byte in newbugg
		 addi $s5, $s5, 1	#incrementing newbuff pointer
		
		j blank
		
	blank:
		la $s6, space
		lb $s6, ($s6)
		sb $s6, 0($s5)
		addi $s5, $s5, 1
		
		j height
		
	height:
		li $t5, 10		# storing value 10 
		div $s4, $t5		# dividing loaded bit by 10	
		mfhi $t4		# least significant
		mflo $t5		# most significant
		addi $t4, $t4, 48	# ls + 48
		blez $t5, oneDigHeight	# if ms is =/ less than 0, it is a one digit
		addi $t5, $t5, 48	# ms + 48
		sb $t5, 0($s5)		# store ms in newbuff
		addi $s5, $s5, 1	# move newbuff pointer by 1
		
	oneDigHeight: 
		sb $t4, 0($s5)	#storing byte in newbugg
		addi $s5, $s5, 1	#incrementing newbuff pointer
			  
		j intensity
		
	intensity:
		lb $t2, 0($t3)
		beq $t2, $0, null
		sb $t2, 0($s5)
		addi $s5, $s5, 1
		addi $t3, $t3, 1	  
		j intensity
	null:
		

    	li $v0,13           	# open_file syscall code = 13
    	la $a0,output     	# get the file name
    	li $a1,1           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	bltz $s1, Error
    
    	#Write the first part of file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,	headerbuff	# the first string that will be written
    	
    	#find headerbuff length:
    	li $t0, 0
    	la $t1, headerbuff
    	
    length2: lb $t2, 0($t1)
    		addi $t1, $t1, 1
    		addi $t0,  $t0, 1
    		bne $t2, $0, length2
    		addi $t0, $t0, -1
    	
 	addi $a2,$t0, 0		# length of the toWrite string
    	syscall
    	bltz $v0, Error
    	
    	#find buffer length:
    	li $t0, 0
    	la $t1, newbuff
    	
    	length3: lb $t2, 0($t1)
    		addi $t1, $t1, 1
    		addi $t0,  $t0, 1
    		bne $t2, $0, length3
    		addi $t0, $t0, -1
    	
    	#Write the buffer into the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,	newbuff		# writing the string stored in the buffer
 	move $a2, $t0		# length of the toWrite string
    	syscall
    	bltz $v0, Error
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall
    	
    	addi $sp, $sp, 24
    	jr $ra
    	
    	

#slightly different from Q1.   
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!

Error:		li $v0, 4
		la $a0, errorMsg
		syscall
	
		li $v0, 10
		syscall
	
		li $v0, 10
		syscall
