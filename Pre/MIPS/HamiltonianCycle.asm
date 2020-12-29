.data
	visited:.space 8
	matrix:.space 64
.macro clearMemory(%begin,%size)
	li $t0,0
	clearMemory_loop:
		sb $zero,%begin($t0)
		addi $t0,$t0,1
		bne $t0,%size,clearMemory_loop
.end_macro
.macro pushStack(%val)
	addi $sp,$sp,-4
	sw %val,4($sp)
.end_macro
.macro popStack(%reg)
	addi $sp,$sp,4
	lw %reg,0($sp)
.end_macro
.macro getMatrix(%i,%j,%reg)
	add $t0,$zero,%i
	sll $t0,$t0,3
	add $t0,$t0,%j
	lb %reg,matrix($t0)
.end_macro
.macro setMatrix(%i,%j,%val)
	add $t0,$zero,%i
	sll $t0,$t0,3
	add $t0,$t0,%j
	sb %val,matrix($t0)
.end_macro
.macro getInteger(%reg)
	li $v0,5
	syscall
	add %reg,$zero,$v0
.end_macro
.text
	clearMemory(matrix,64)
	clearMemory(visited,8)
	getInteger($s0)		# n -> s0
	getInteger($s1)		# m -> s1
	li $s2,0			# i
	li $s3,1
	read_loop:
		getInteger($s4)
		getInteger($s5)
		setMatrix($s4,$s5,$s3)
		setMatrix($s5,$s4,$s3)
		addi $s2,$s2,1
		blt $s2,$s1,read_loop
	li $s2,1		# current_index -> s2
	li $s3,0		# vn -> s3: global
	outer_search_loop:
		add $s6,$zero,$s2
		jal search
		addi $s2,$s2,1
		blt $s2,$s0,outer_search_loop
	li $a0,0
	j exit
	search:
		li $t0,1
		sb $t0,visited($s2)
		addi $s3,$s3,1
		beq $s3,$s0,final_check
		continue:
		li $s4,1
		search_loop:
			lb $t0,visited($s4)
			bnez $t0,search_loop_update
			getMatrix($s2,$s4,$t0)
			beq $t0,$zero,search_loop_update
			pushStack($s2)
			pushStack($s4)
			pushStack($ra)
			add $s2,$zero,$s4
			jal search
			popStack($ra)
			popStack($s4)
			popStack($s2)
		search_loop_update:
			addi $s4,$s4,1
			bgt $s4,$s0,search_loop_end
			j search_loop
		search_loop_end:
			add $s3,$s3,-1
			sb $zero,visited($s2)
			jr $ra
	final_check:
		getMatrix($s2,$s6,$t0)
		bnez $t0,exist
		j continue
	exist:
		li $a0,1
		j exit
	exit:
		li $v0,1
		syscall
		li $v0,10
		syscall