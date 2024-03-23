.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
w: .word 200
h: .word 50
d: .word 50
cr: .word 0x00
cg: .word 0x22
cb: .word 0xFF
# DONOTMODIFYTHISLINE
# Your other variables go BELOW here only

.text
main:
    	la		$s0, frameBuffer	# load frame buffer address
    	li		$s1, 131072		# save 512 x 256 pixels (0x20000) 131072
	li		$s2, 0x00FFFF00		# load yellow color

background:
	#sw		$s2, 0($s0)		
	#addi		$s0, $s0, 4		# goes to next pixel
	#addi		$s1, $s1, -1		# decreases total pixels left by 1
	#bne		$s1, $0, background	# repeats while there are still pixels left

faceColor: 
    	lw		$t0, cr			# loads the red
	addi		$s2, $t0, 0		# $t0 gets red
	sll		$s2, $s2, 8		# shift 2 bits left
	lw		$t0, cg			# loads green
	or 		$s2, $s2, $t0		# $t2 gets green
	sll		$s2, $s2, 8		# shift 2 bits left
	lw		$t0, cb			# loads green
	or		$s2, $s2, $t0		# $s0 gets blue, making $t2 0x00(r)(g)(b)
	
	la		$s0, frameBuffer	# load frame buffer address
	lw 		$t0, w     		# Load value of w into $t0
	lw		$t1, h			# Load value of h into $t1
	lw		$t2, d			# Load value of d into $t2
	mult 		$t0, $t1		# Multiply w and h
	mflo 		$s1      		# Store the lower 32 bits of the result in $s1
	addi		$s3, $0, 512		# $s3 <- 512
	sub		$s3, $s3, $t0		# $s3 = 512 - w 
	sub		$s3, $s3, $t2		# $s3 = 512 - w - d
	add		$t3, $t1, $t2		# h + d
	addi		$s4, $0, 256		# $s4 <- 256
	sub		$s4, $s4, $t1		# $s4 = 256 - h 
	sub		$s4, $s4, $t2		# $s4 = 256 - h - d
	addi		$t3, $0, 2		# $t3 <- 2
	div		$s3, $t3		# (512 - w - d) / 2
	mflo 		$s5      		# $s5 <- (512 - w - d) / 2
	div		$s4, $t3		# (256 - h - d) / 2
	mflo 		$s6      		# $s6 <- (256 - h - d) / 2
	add		$t3, $s6, $t2		# $t3 <- (256 - h - d) / 2 + d
	addi		$t4, $0, 512		# $t4 <- 512
	mult		$t3, $t4		# ((256 - h - d) / 2 + d) * 512 
	mflo		$t3			# $t3 <- ((256 - h - d) / 2 + d) * 512 (pixels to jump)
	add		$t3, $t3, $s5		# $t3 <- moves the pixels to the middle
	addi		$t4, $0, 4		# $t4 <- 4
	mult		$t3, $t4		# pixels * 4
	mflo		$t3			# $t3 <- number to jump
	add		$s0, $s0, $t3		# $s0 <- top left of face
	add		$t5, $s3, $t2		# $t5 <- 512 - w
	mult		$t5, $t4		# (512-w ) * 4
	mflo		$t3			# $t3 <- (512-w ) * 4
	j		faceWidth
	
resetWidth:
	beq		$s1, $0, top		# jumps to top part of the cube if there are no pixels left
	add		$s0, $s0, $t3		# skips to next row
faceWidth:
	add		$t5, $0, $t0		# $t5 <- width		

face:	
    	sw		$s2, 0($s0)		
	addi		$s0, $s0, 4		# goes to next pixel
	addi		$s1, $s1, -1		# decreases total pixels left by 1
	addi		$t5, $t5, -1		# decreases total width left by 1
	beq		$t5, $0, resetWidth	# goes to next row
	bne		$s1, $0, face		# repeats while there are still pixels left

 top:     
  	li $v0,10 				# exit code
	syscall 				# exit to OS
