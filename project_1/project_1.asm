.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
w: .word 100
h: .word 50
d: .word 50
cr: .word 0x11
cg: .word 0x11
cb: .word 0x99
# DONOTMODIFYTHISLINE
# Your other variables go BELOW here only

.text
main:
    	la		$s0, frameBuffer	# load frame buffer address
    	li		$s1, 131072		# save 512 x 256 pixels (0x20000) 131072
	li		$s2, 0x00FFFF00		# load yellow color

background:
	sw		$s2, 0($s0)		
	addi		$s0, $s0, 4		# goes to next pixel
	addi		$s1, $s1, -1		# decreases total pixels left by 1
	bne		$s1, $0, background	# repeats while there are still pixels left

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
	
resetFaceWidth:
	beq		$s1, $0, topSet		# jumps to side part of the cube if there are no pixels left
	add		$s0, $s0, $t3		# skips to next row
faceWidth:
	add		$t5, $0, $t0		# $t5 <- width		

face:	
    	sw		$s2, 0($s0)		
	addi		$s0, $s0, 4		# goes to next pixel
	addi		$s1, $s1, -1		# decreases total pixels left by 1
	addi		$t5, $t5, -1		# decreases total width left by 1
	beq		$t5, $0, resetFaceWidth	# goes to next row
	bne		$s1, $0, face		# repeats while there are still pixels left

topSet:
	la		$s0, frameBuffer	# load frame buffer address
	li		$t6, 0xFF		# greater than max color allowed
	lw		$t5, cr			# loads the red
	sll		$t5, $t5, 2		# red * 4
	slt		$t7, $t6, $t5		# if $t6 > 0xFF
	beq		$t7, $0, skipRed	# skips set red to 0xFF
	li		$t5, 0xFF		# $t5 <- 0xFF
skipRed:
	addi		$s2, $t5, 0		# $s2 gets red
	sll		$s2, $s2, 8		# shift 2 bits left
	
	lw		$t5, cg			# loads green
	sll		$t5, $t5, 2		# green * 4
	slt		$t7, $t6, $t5		# if $t6 > 0xFF
	beq		$t7, $0, skipGreen	# skips set green to 0xFF
	li		$t5, 0xFF		# $t5 <- 0xFF
skipGreen:	
	or 		$s2, $s2, $t5		# $s2 gets green
	sll		$s2, $s2, 8		# shift 2 bits left
	
	lw		$t5, cb			# loads blue
	sll		$t5, $t5, 2		# blue * 4
	slt		$t7, $t6, $t5		# if $t6 > 0xFF
	beq		$t7, $0, skipBlue	# skips set blue to 0xFF	
	li		$t5, 0xFF		# $t5 <- 0xFF
skipBlue:
	or		$s2, $s2, $t5		# $s2 gets blue, making $s2 0x00(r)(g)(b)
	mult 		$t0, $t1		# Multiply w and h
	mflo 		$s1      		# Store the lower 32 bits of the result in $s1
	addi		$t5, $0, 512		# $t5 <- 512
	mult		$s6, $t5		# (256 - h - d) / 2 * 512
	mflo		$t5			# $s1 <- (256 - h - d) / 2 * 512
	add		$t5, $t5, $s5		# moves to the left side of the cube
	add		$t5, $t5, $t2		# moves d pixels to th right
	mult		$t5, $t4		# pixels * 4
	mflo		$t5			# $t5 <- pixels * 4
	add		$s0, $s0, $t5		# jumps to top left of top part
	addi		$t3, $t3, -4		# skips to one less pixel
	j		topWidth
	
resetTopWidth:
	beq		$s1, $0, sideSet	# jumps to top part of the cube if there are no pixels left
	add		$s0, $s0, $t3		# skips to next row	
	
topWidth:
	add		$t5, $0, $t0		# $t5 <- width		

top:	
    	sw		$s2, 0($s0)		
	addi		$s0, $s0, 4		# goes to next pixel
	addi		$s1, $s1, -1		# decreases total pixels left by 1
	addi		$t5, $t5, -1		# decreases total width left by 1
	beq		$t5, $0, resetTopWidth	# goes to next row
	bne		$s1, $0, top		# repeats while there are still pixels left
  	
sideSet:
	la		$s0, frameBuffer	# load frame buffer address
	li		$t6, 0xFF		# greater than max color allowed
	lw		$t5, cr			# loads the red
	sll		$t5, $t5, 1		# red * 2
	slt		$t7, $t6, $t5		# if $t6 > 0xFF
	beq		$t7, $0, skipSideRed	# skips set red to 0xFF
	li		$t5, 0xFF		# $t5 <- 0xFF
skipSideRed:
	addi		$s2, $t5, 0		# $s2 gets red
	sll		$s2, $s2, 8		# shift 2 bits left
	
	lw		$t5, cg			# loads green
	sll		$t5, $t5, 1		# green * 4
	slt		$t7, $t6, $t5		# if $t6 > 0xFF
	beq		$t7, $0, skipSideGreen	# skips set green to 0xFF
	li		$t5, 0xFF		# $t5 <- 0xFF
skipSideGreen:	
	or 		$s2, $s2, $t5		# $s2 gets green
	sll		$s2, $s2, 8		# shift 2 bits left
	
	lw		$t5, cb			# loads blue
	sll		$t5, $t5, 1		# blue * 4
	slt		$t7, $t6, $t5		# if $t6 > 0xFF
	beq		$t7, $0, skipSideBlue	# skips set blue to 0xFF	
	li		$t5, 0xFF		# $t5 <- 0xFF
skipSideBlue:
	or		$s2, $s2, $t5		# $s2 gets blue, making $s2 0x00(r)(g)(b)
	
	addi		$t4, $0, 2		# $t4 <- 2
	div		$t2, $t4		# d/2
	mflo		$t4			# $t4 <- d / 2
	mult 		$t2, $t4		# d * d/2
	mflo 		$s1      		# Store the lower 32 bits of the result in $s1
	sub		$s1, $s1, $t4		# subtract the covered part
	add		$s7, $s1, $0
	addi		$t5, $0, 512		# $t5 <- 512
	mult		$s6, $t5		# (256 - h - d) / 2 * 512
	mflo		$t5			# $s1 <- (256 - h - d) / 2 * 512
	add		$t5, $t5, $s5		# moves to the left side of the cube
	add		$t5, $t5, $t2		# moves d pixels to the right
	add		$t5, $t5, $t0		# moves w pixels to the right
	addi		$t4, $0, 4		# $t4 <- 4
	mult		$t5, $t4		# pixels * 4
	mflo		$t5			# $t5 <- pixels * 4
	add		$s0, $s0, $t5		# jumps to top left of top part
	addi		$t6, $0, 1		# $t6 <- 0

resetSideTopWidth:
	beq		$s1, $0, endSideTop	# jumps to top part of the cube if there are no pixels left
	addi		$t3, $0, 512		# $t3 <- 512
	sub		$t3, $t3, $t6		# $t3 - $t6
	mult		$t3, $t4		# $t3 * 4
	mflo		$t3			# $t3 <- $t3 * 4
	add		$s0, $s0, $t3		# skips to next row	
	
sideTopWidth:
	add		$t5, $0, $t6		# $t5 <- width	
	addi		$t6, $t6, 1		# $t6 <- $t6 + 1	

sideTop:	
    	sw		$s2, 0($s0)		
	addi		$s0, $s0, 4			# goes to next pixel
	addi		$s1, $s1, -1			# decreases total pixels left by 1
	addi		$t5, $t5, -1			# decreases total width left by 1
	beq		$t5, $0, resetSideTopWidth	# goes to next row
	bne		$s1, $0, sideTop		# repeats while there are still pixels left
	
endSideTop:	
	add		$s1, $s7, $t2		# loads total pixels
	add		$t6, $0, $t2		# $t6 <- d

resetSideBottomWidth:
	beq		$s1, $0, end		# jumps to top part of the cube if there are no pixels left
	addi		$t3, $0, 511		# $t3 <- 512 - 1(offset)
	sub		$t3, $t3, $t6		# $t3 - $t6
	mult		$t3, $t4		# $t3 * 4
	mflo		$t3			# $t3 <- $t3 * 4
	add		$s0, $s0, $t3		# skips to next row	
	
sideBottomWidth:
	add		$t5, $0, $t6		# $t5 <- width	
	addi		$t6, $t6, -1		# $t6 <- $t6 + 1	

sideBottom:	
    	sw		$s2, 0($s0)		
	addi		$s0, $s0, 4			# goes to next pixel
	addi		$s1, $s1, -1			# decreases total pixels left by 1
	addi		$t5, $t5, -1			# decreases total width left by 1
	beq		$t5, $0, resetSideBottomWidth	# goes to next row
	bne		$s1, $0, sideBottom		# repeats while there are still pixels left

end:
	li $v0,10 				# exit code
	syscall 				# exit to OS
