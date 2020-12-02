.data
	map:.space 196
	visited:.space 196
.macro getElement(%array,%x,%y,%col,%val)
	multu %x,%col
	mflo $t8
	addu $t8,$t8,%y
	sll $t8,$t8,2
	lw %val,%array($t8)
.end_macro
.macro setElement(%array,%x,%y,%col,%val)
	multu %x,%col
	mflo $t8
	addu $t8,$t8,%y
	sll $t8,$t8,2
	sw %val,%array($t8)
.end_macro
.macro readInteger(%val)
	li $v0,5
	syscall
	add %val,$v0,$zero
.end_macro
.macro printInteger(%val)
	li $v0,1
	add $a0,%val,$zero
	syscall
.end_macro
.macro readMatrix(%array,%row,%col)
	li $t0,0
	readMatrixOuterLoop:
		li $t1,0
		readMatrixInnerLoop:
			readInteger($t2)
			setElement(%array,$t0,$t1,%col,$t2)
			addi $t1,$t1,1
			blt $t1,%col,readMatrixInnerLoop
		addi $t0,$t0,1
		blt $t0,%row,readMatrixOuterLoop
.end_macro
.macro saveValue(%value)
	addi $sp,$sp,-4
	sw %value,4($sp)
.end_macro
.macro loadValue(%value)
	addi $sp,$sp,4
	lw %value,0($sp)
.end_macro
.text
	readInteger($s0)
	readInteger($s1)
	readMatrix(map,$s0,$s1)
	readInteger($t0)
	readInteger($t1)
	readInteger($s2)
	readInteger($s3)
	addi $t0,$t0,-1
	addi $t1,$t1,-1
	addi $s2,$s2,-1
	addi $s3,$s3,-1
	li $s4,0
	jal dfs
	j result
	dfs:
		bne $t0,$s2,dfsEdgeFail
		bne $t1,$s3,dfsEdgeFail
		addi $s4,$s4,1
		j dfs_return
		dfsEdgeFail:
		li $t2,1
		setElement(visited,$t0,$t1,$s1,$t2)
			beqz $t0,dfsUpFail
			addi $t2,$t0,-1
			getElement(map,$t2,$t1,$s1,$t3)
			bnez $t3,dfsUpFail
			getElement(visited,$t2,$t1,$s1,$t3)
			bnez $t3,dfsUpFail
			saveValue($ra)
			addi $t0,$t0,-1
			jal dfs
			addi $t0,$t0,1
			loadValue($ra)
		dfsUpFail:
			addi $t2,$s0,-1
			beq $t0,$t2,dfsDownFail
			addi $t2,$t0,1
			getElement(map,$t2,$t1,$s1,$t3)
			bnez $t3,dfsDownFail
			getElement(visited,$t2,$t1,$s1,$t3)
			bnez $t3,dfsDownFail
			saveValue($ra)
			addi $t0,$t0,1
			jal dfs
			addi $t0,$t0,-1
			loadValue($ra)
		dfsDownFail:
			beqz $t1,dfsLeftFail
			addi $t2,$t1,-1
			getElement(map,$t0,$t2,$s1,$t3)
			bnez $t3,dfsLeftFail
			getElement(visited,$t0,$t2,$s1,$t3)
			bnez $t3,dfsLeftFail
			saveValue($ra)
			addi $t1,$t1,-1
			jal dfs
			addi $t1,$t1,1
			loadValue($ra)
		dfsLeftFail:
			addi $t2,$s1,-1
			beq $t1,$t2,dfsRightFail
			addi $t2,$t1,1
			getElement(map,$t0,$t2,$s1,$t3)
			bnez $t3,dfsRightFail
			getElement(visited,$t0,$t2,$s1,$t3)
			bnez $t3,dfsRightFail
			saveValue($ra)
			addi $t1,$t1,1
			jal dfs
			addi $t1,$t1,-1
			loadValue($ra)
		dfsRightFail:
		dfs_return:
			setElement(visited,$t0,$t1,$s1,$zero)
			jr $ra
	result:
	printInteger($s4)
	li $v0,10
	syscall
