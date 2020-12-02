.macro readInteger(%val)
	li $v0,5
	syscall
	add %val,$v0,$zero
.end_macro
.macro getChar()
	li $v0,12
	syscall
.end_macro
.macro exit()
	li $v0,10
	syscall
.end_macro
.text
	readInteger($s0)
	srl $s1,$s0,1
	andi $s0,$s0,1
	beqz $s1,success
	move $t0,$s1
	frontHalfLoop:
		getChar()
		addi $sp,$sp,-1
		sb $v0,1($sp)
		addi $t0,$t0,-1
		bgtz $t0,frontHalfLoop
	beqz $s0,skip
	getChar()
	skip:
	move $t0,$s1
	backHalfLoop:
		getChar()
		addi $sp,$sp,1
		lb $t1,0($sp)
		bne $v0,$t1,fail
		addi $t0,$t0,-1
		bgtz $t0,backHalfLoop
	success:
		li $v0,1
		li $a0,1
		syscall
		exit()
	fail:
		li $v0,1
		li $a0,0
		syscall
		exit()
