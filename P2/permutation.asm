.data
	result:.space 30
	space:.asciiz " "
	nl:.asciiz "\n"
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
.macro exit()
	li $v0,10
	syscall
.end_macro
.macro saveValue(%value)
	addi $sp,$sp,-4
	sw %value,4($sp)
.end_macro
.macro loadValue(%value)
	addi $sp,$sp,4
	lw %value,0($sp)
.end_macro
.macro getVisited(%visited,%index,%value)
	srlv %value,%visited,%index
	andi %value,%value,1
.end_macro
.macro setVisited(%visited,%index,%temp)
	li %temp,1
	sllv %temp,%temp,%index
	or %visited,%visited,%temp
.end_macro
.macro setNotVisited(%visited,%index,%temp)
	li %temp,1
	sllv %temp,%temp,%index
	nor %temp,%temp,$zero
	and %visited,%visited,%temp
.end_macro
.macro appendResult(%addr,%index,%val)
	sll %index,%index,2
	sw %val,%addr(%index)
	srl %index,%index,2
.end_macro
.macro printResult(%addr,%length)
	sll %length,%length,2
	li $t8,4
	printLoop:
		lw $t9,%addr($t8)
		printInteger($t9)
		space()
		addi $t8,$t8,4
		ble $t8,%length,printLoop
	srl %length,%length,2
	endl()
.end_macro
.text
	readInteger($s0)
	li $s1,0
	li $s2,0
	jal Function
	exit()
	Function:
		beq $s2,$s0,FunctionConstructed
		li $t0,1
		FunctionLoop:
			getVisited($s1,$t0,$t1)
			bnez $t1,FunctionLoopNext
			setVisited($s1,$t0,$t1)
			saveValue($ra)
			saveValue($t0)
			addi $s2,$s2,1
			appendResult(result,$s2,$t0)
			jal Function
			loadValue($t0)
			loadValue($ra)
			setNotVisited($s1,$t0,$t1)
		FunctionLoopNext:
			addi $t0,$t0,1
			ble $t0,$s0,FunctionLoop
			j FunctionReturn
		FunctionConstructed:
			printResult(result,$s0)
			j FunctionReturn
		FunctionReturn:
			addi $s2,$s2,-1
			jr $ra