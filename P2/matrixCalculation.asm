.data
	mat1:.space 256
	mat2:.space 256
	mat3:.space 256
	space:.asciiz " "
	nl:.asciiz "\n"
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
.macro space()
	li $v0,4
	la $a0,space
	syscall
.end_macro
.macro endl()
	li $v0,4
	la $a0,nl
	syscall
.end_macro
.macro readMatrix(%array,%n)
	li $t0,0
	readMatrixOuterLoop:
		li $t1,0
		readMatrixInnerLoop:
			readInteger($t2)
			setElement(%array,$t0,$t1,%n,$t2)
			addi $t1,$t1,1
			blt $t1,%n,readMatrixInnerLoop
		addi $t0,$t0,1
		blt $t0,%n,readMatrixOuterLoop
.end_macro
.macro printMatrix(%array,%n)
	li $t0,0
	readMatrixOuterLoop:
		li $t1,0
		readMatrixInnerLoop:
			getElement(%array,$t0,$t1,%n,$t2)
			printInteger($t2)
			space()
			addi $t1,$t1,1
			blt $t1,%n,readMatrixInnerLoop
		endl()
		addi $t0,$t0,1
		blt $t0,%n,readMatrixOuterLoop
.end_macro
.text
	readInteger($s0)
	readMatrix(mat1,$s0)
	readMatrix(mat2,$s0)
	li $t0,0
	outerLoop:
		li $t1,0
		middleLoop:
			li $t2,0
			li $s1,0
			innerLoop:
				getElement(mat1,$t0,$t2,$s0,$t3)
				getElement(mat2,$t2,$t1,$s0,$t4)
				mul $t3,$t3,$t4
				addu $s1,$s1,$t3
				addi $t2,$t2,1
				blt $t2,$s0,innerLoop
			setElement(mat3,$t0,$t1,$s0,$s1)
			addi $t1,$t1,1
			blt $t1,$s0,middleLoop
		addi $t0,$t0,1
		blt $t0,$s0,outerLoop
	printMatrix(mat3,$s0)
	li $v0,10
	syscall