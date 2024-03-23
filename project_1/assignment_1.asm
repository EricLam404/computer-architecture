.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
w: .word 200
h: .word 200
d: .word 200
cr: .word 0x00
cg: .word 0x22
cb: .word 0xFF
# DONOTMODIFYTHISLINE
# Your other variables go BELOW here only

.text
main:
    	la		$t0, frameBuffer	# load frame buffer address
    	li		$t1, 131072		# save 512 x 256 pixels (0x20000) 131072
	li		$t2, 0x00FFFF00		# load yellow color

background:
	sw		$t2, 0($t0)		
	addi		$t0, $t0, 4		# goes to next pixel
	addi		$t1, $t1, -1		# decreases total pixels left by 1
	bne		$t1, $0, background	# repeats while there are still pixels left

faceColor: 
    	lw		$t3, cr			# loads the red
	addi		$t2, $t3, 0		# $t2 gets red
	sll		$t2, $t2, 8		# shift 2 bits left
	lw		$t3, cg			# loads green
	or 		$t2, $t2, $t3		# $t2 gets green
	sll		$t2, $t2, 8		# shift 2 bits left
	lw		$t3, cb			# loads green
	or		$t2, $t2, $t3		# $t2 gets blue, making $t2 0x00(r)(g)(b)
	
	## top right of face to make the cube center is y = (256 - (d + h))/2 + d x = (512 - (d + w))/2 + d 
	## y_left = 256-d+h x_left = 512-d+w
	la		$t0, frameBuffer	# load frame buffer address
	lw 		$t3, w     		# Load value of w into $t3
	lw		$t4, h			# Load value of h into $t4
	lw		$t5, d			# Load value of d into $t5
	mult 		$t3, $t4		# Multiply w and h
	mflo 		$t1      		# Store the lower 32 bits of the result in $t1
	add		$t6, $t4, $t5		# h + d
	addi		$t7, $0, 256		# $t7 <- 256
	sub		$s0, $t7, $t6		# $t6 = 256 - h + d
	addi		$t7, $0, 2		# $t7 <- 2
	div		$s0, $t7		# (256 - h + d) /2
	mflo 		$t6      		# Store the lower 32 bits of the result in $t6
	add		$t6, $t6, $t5		# $t6 <- (256 - h + d) /2 + d
	addi		$t7, $0, 512		# $t7 <- 512
	mult		$t6, $t7		# $t6 * 512
	mflo		$t6			# Store the lower 32 bits of the result in $t6
	add		$t7, $t0, 4		# $t7 <- 4
	mult		$t6, $t7		# $t6 * 4
	mflo 		$t6
	add		$t0, $t0, $t6		# moves the frame buffer to the top left of the box
face:	
    	sw		$t2, 0($t0)		
	addi		$t0, $t0, 4		# goes to next pixel
	addi		$t1, $t1, -1		# decreases total pixels left by 1
	bne		$t1, $0, face		# repeats while there are still pixels left
    
  	li $v0,10 				# exit code
	syscall 				# exit to OS