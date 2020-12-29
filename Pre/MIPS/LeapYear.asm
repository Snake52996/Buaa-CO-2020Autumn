.text
	li $v0,5
	syscall
	add $s0,$zero,$v0
	li $s1,100
	div $s0,$s1
	mfhi $t0
	beq $t0,$zero,HRD
	j NHRD
	HRD:
	li $s1,400
	div $s0,$s1
	mfhi $t0
	beq $t0,$zero,IS
	j NOT
	NHRD:
	andi $t0,$s0,3
	beq $t0,$zero,IS
	j NOT
	IS:
	li $a0,1
	j END
	NOT:
	li $a0,0
	END:
	li $v0,1
	syscall
	li $v0,10
	syscall