.data
	result:.space 4000
.macro printInteger(%val)
	li $v0,1
	add $a0,%val,$zero
	syscall
.end_macro
.text
	li $t0,1
	sw $t0,result($zero)
	li $s0,4
	li $s2,10
	li $v0,5
	syscall
	add $s1,$v0,$zero
	li $t0,1
	calculateOuterLoop:
		li $t1,0
		li $t3,0
		calculateInnerLoop:
			lw $t2,result($t1)
			mul $t2,$t2,$t0
			add $t2,$t2,$t3
			div $t2,$s2
			mfhi $t2
			mflo $t3
			sw $t2,result($t1)
			addi $t1,$t1,4
			blt $t1,$s0,calculateInnerLoop
		beqz $t3,calculateOuterLoopNext
		div $t3,$s2
		mflo $t2
		mfhi $t3
		sw $t3,result($t1)
		addi $s0,$s0,4
		beqz $t2,calculateOuterLoopNext
		addi $t1,$t1,4
		addi $s0,$s0,4
		sw $t2,result($t1)
	calculateOuterLoopNext:
		addi $t0,$t0,1
		ble $t0,$s1,calculateOuterLoop
	add $t0,$s0,$zero
	addi $t0,$t0,-4
	printLoop:
		lw $t1,result($t0)
		printInteger($t1)
		addi $t0,$t0,-4
		bgez $t0,printLoop
	li $v0,10
	syscall