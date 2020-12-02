.data
	src:.space 400
	para:.space 400
	result:.space 400
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
.macro printMatrix(%array,%row,%col)
	li $t0,0
	readMatrixOuterLoop:
		li $t1,0
		readMatrixInnerLoop:
			getElement(%array,$t0,$t1,%col,$t2)
			printInteger($t2)
			space()
			addi $t1,$t1,1
			blt $t1,%col,readMatrixInnerLoop
		endl()
		addi $t0,$t0,1
		blt $t0,%row,readMatrixOuterLoop
.end_macro
.text
	readInteger($s0)
	readInteger($s1)
	readInteger($s2)
	readInteger($s3)
	readMatrix(src,$s0,$s1)
	readMatrix(para,$s2,$s3)
	sub $s4,$s0,$s2
	addi $s4,$s4,1
	sub $s5,$s1,$s3
	addi $s5,$s5,1
	li $t0,0
	beginRowLoop:
		li $t1,0
		beginColLoop:
			li $t2,0
			li $s6,0
			calculateOuterLoop:
				li $t3,0
				add $t4,$t0,$t2
				calculateInnerLoop:
					add $t5,$t1,$t3
					getElement(src,$t4,$t5,$s1,$t6)
					getElement(para,$t2,$t3,$s3,$t7)
					mul $t6,$t6,$t7
					addu $s6,$s6,$t6
					addi $t3,$t3,1
					blt $t3,$s3,calculateInnerLoop
				addi $t2,$t2,1
				blt $t2,$s2,calculateOuterLoop
			setElement(result,$t0,$t1,$s5,$s6)
			addi $t1,$t1,1
			blt $t1,$s5,beginColLoop
		addi $t0,$t0,1
		blt $t0,$s4,beginRowLoop
	printMatrix(result,$s4,$s5)
	li $v0,10
	syscall